//
//  QueryProperyWrapper.swift
//  QueryPropertyWrapper
//
//  Created by Angel de Jesús Sánchez Morales on 04/07/22.
//

import Foundation
import SwiftUI


/// A Property Wrapper type to make fetch async operations asynchronously. Returns the fetched object/struct as the wrappedValue and a tuple conformed by the isLoading, error, refetch and bindingValue properties.
@propertyWrapper
public struct Query<Value, Params>: DynamicProperty {
    @State private var isLoading: Bool = true
    @State private var error: Error? = nil
    @State private var isFetched = false
    public var params: Params
    
    @State public var wrappedValue: Value
    
    /// - Returns: A tuple conformed by the isLoading, error, refetch and bindingValue properties.
    public var projectedValue: (isLoading: Bool, error: Error?, refetch: () -> (), bindingValue: Binding<Value>) {
        Task {
            if (!isFetched) {
                do {
                    withAnimation {
                        isLoading = true
                    }
                    let result =  try await query(params)
                    withAnimation {
                        wrappedValue =  result
                        isLoading = false
                    }
                    isFetched = true
                }
                catch {
                    print("Error fetching Query: ", query.self, error)
                    self.error = error
                    isLoading = false
                    isFetched = true
                }
            }
        }
        return (isLoading, error, refetch, $wrappedValue)
    }
    
    /// Initializer for the Query property wrapper.
    /// - Parameters:
    ///   - wrappedValue: the default value in case the query fails.
    ///   - query: an async throws function responsible for fetching the data
    public init (wrappedValue: Value, query: @escaping (Params) async throws -> Value, params: Params = () as! Params) {
        self._wrappedValue = State(initialValue: wrappedValue)
        self.query = query
        self.params = params
    }
    
    /// Executes the given query to update the data
    func refetch() {
        error = nil
        isFetched = false
    }
    
    public var query: (Params) async throws -> Value
}
