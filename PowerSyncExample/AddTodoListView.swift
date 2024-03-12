import SwiftUI

struct AddTodoListView: View {
    @Environment(PowerSync.self) var powerSync
    @Binding var newTodo: PartialTodo
    let completion: (Result<Bool, Error>) -> Void
    
    var body: some View {
        Section {
            TextField("Description", text: $newTodo.description)
            Button("Save") {
                Task.detached {
                    do {
                        try await powerSync.insertTodo(newTodo)
                        completion(.success(true))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

struct AddTodoListView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoListView(
            newTodo: .constant(
                .init(
                    description: "",
                    isComplete: false
                )
            )
        ) { _ in
        }
    }
}
