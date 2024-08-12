import Foundation
import SwiftUI

struct AddTodoListView: View {
    @Environment(PowerSync.self) private var powerSync
    
    @Binding var newTodo: NewTodo
    let listId: String
    let completion: (Result<Bool, Error>) -> Void
    
    var body: some View {
        Section {
            TextField("Description", text: $newTodo.description)
            Button("Save") {
                Task.detached {
                    do {
                        try await powerSync.insertTodo(newTodo, listId)
                        completion(.success(true))
                    } catch {
                        completion(.failure(error))
                        throw error
                    }
                }
            }
        }
    }
}

#Preview {
    AddTodoListView(
        newTodo: .constant(
            .init(
                listId: UUID().uuidString.lowercased(),
                isComplete: false,
                description: ""
            )
        ),
        listId: UUID().uuidString.lowercased()
    ){ _ in
    }.environment(PowerSync())
}
