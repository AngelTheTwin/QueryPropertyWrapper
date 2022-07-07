# QueryPropertyWrapper

A custom property wrapper to fetch data asynchronously in SwiftUI Views.
Inspired by the React useQuery hook, but with much less functionality.

## Why to use Query?

The query property wrapper allows you to extract your data fetching logic from your ui.

You should define the functions that fetch data in a separate module (i.e. using the DAO pattern), and in the view you won't need to add code to your onAppear modifier to update your state to be in sync with your online data. Just define a property using the `@Query` property wrapper and you can use almost as it it were State (i will explain the almost).

## What does @Query give me

As mentioned before, it works almost as if it was a `@State` property in the sense that you can mutate its value and the Views will update accordingly. This is because on the background `@Query` is using `@State` to keep track of its value.

**But** its difference with `@State` is the way you access to the `Binding` value of your property. While with `@State` you would only need to add `$` to the start of your property, with `@Query` this is different. Let’s see why...

### @Query projectedValue

When using the `$` at the start of your property name, `@Query` will return a tuple of useful propperties

- `isLoading: Bool`: is true while your fuction is fethcing and waiting for the data from the server.
- `error: Error?`: an optional Error. It’s value will be nil unless an error has occurred while fetching the data. In this case, the app will not crash, it'll print out the error on the console and you will be able to identify the error using this property.
- `refetch: () -> ()`: a function you can invoke to re-execute the query.
- `bindingValue: Binding<Value>`: the binding representation of your property. Use it to pass it to view that require a Binding as input, such as TextFields.

## Example

The following example demonstrates how easy it is to use the `@Query` property wrapper.

```swift
// The model to consult
struct User {
    var name: String
}

//In a real project this function would be on a different file as part of a DAO
func fetchData() async throws -> User {
    let fetchedUser = User() //this would be some asynchronous work
    return fetchedUser
}

//Now the view
struct QueryExample: View {
    @Query(query: fetchData) var user = User()
    
    var body: some View {
        VStack {
            if ($user.isLoading) { // through conditional rendering we can place progress views when our query is being fetched
                ProgressiveView()
            } else if let error = $user.error {
                Text("Ups! an error occurred!") // let the user know when there was an error
            } else {
                TextField("Edit name", text: $user.bindingValue.name) //This is how you access to the binding value of the user
                Text("The name now is \(user.name)") // will update as the user types on the textfield
                Button {
                    $user.refetch() // will execute the query again
                } label: {
                    Text("Fetch the data again")
                }
            }
        }
    }
}
```

## Usage

- To begin create a var with the `@Query` propperty wrapper.
Make sure to include the fetching function in the parameter `query:` of the initializer.

- The fetching function must be an `async throws` function and must return a value.

- Finally give it a name and a default value. (The default value type must be the same as the query function’s return type).

Your new property should look like this:

```swift
@Query(query: yourFetchingFunction) var result = aDefaultValue
```

And that’s it! You‘re ready to fetch data inside SwiftUI views with ease.
