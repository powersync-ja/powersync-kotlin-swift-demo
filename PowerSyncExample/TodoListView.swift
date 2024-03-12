import IdentifiedCollections
import SwiftUI
import SwiftUINavigation

struct TodoListView: View {
    @Environment(PowerSync.self) var powerSync
    
    @State var todos: IdentifiedArrayOf<Todo> = []
    @State var error: Error?
    
    @State var newTodo: PartialTodo?
    
    var body: some View {
        List {
            if let error {
                ErrorText(error)
            }
            
            IfLet($newTodo) { $newTodo in
                AddTodoListView(newTodo: $newTodo) { result in
                    withAnimation {
                        print("Result \(result)")
                        //              newTodo = nil
                    }
                }
            }
            
            ForEach(todos) { todo in
                TodoListRow(todo: todo) {
                    Task {
                        await toggleCompletion(of: todo)
                    }
                }
            }
            .onDelete { indexSet in
                Task {
                    await delete(at: indexSet)
                }
            }
        }
        .animation(.default, value: todos)
        .navigationTitle("Todos")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if newTodo == nil {
                    Button {
                        withAnimation {
                            newTodo = .init(
                                description: "",
                                isComplete: false
                            )
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                } else {
                    Button("Cancel", role: .cancel) {
                        withAnimation {
                            newTodo = nil
                        }
                    }
                }
            }
        }
        .task {
            do {
                error = nil
                
                await powerSync.connect()
                
                let todos2 = try await powerSync.getTodos()
                
                print("Result: \(todos2)")
                
                
                todos = try await IdentifiedArrayOf(
                    uniqueElements: powerSync.connector.client.database.from("todos")
                        .select()
                        .execute()
                        .value as [Todo]
                )
            } catch {
                self.error = error
            }
        }
    }
    
    @MainActor
    func toggleCompletion(of todo: Todo) async {
        //    var updatedTodo = todo
        //    updatedTodo.isComplete.toggle()
        //    todos[id: todo.id] = updatedTodo
        //
        //    do {
        //      error = nil
        //
        //      let updateRequest = UpdateTodoRequest(
        //        isComplete: updatedTodo.isComplete
        //      )
        //      updatedTodo = try await supabase.database.from("todos")
        //        .update(updateRequest, returning: .representation)
        //        .eq("id", value: updatedTodo.id)
        //        .single()
        //        .execute()
        //        .value
        //      todos[id: updatedTodo.id] = updatedTodo
        //    } catch {
        //      // rollback old todo.
        //      todos[id: todo.id] = todo
        //
        //      self.error = error
        //    }
    }
    
    func delete(at offset: IndexSet) async {
        //    let oldTodos = todos
        //
        //    do {
        //      error = nil
        //      let todosToDelete = offset.map { todos[$0] }
        //
        //      todos.remove(atOffsets: offset)
        //
        //      try await supabase.database.from("todos")
        //        .delete()
        //        .in("id", value: todosToDelete.map(\.id))
        //        .execute()
        //    } catch {
        //      self.error = error
        //
        //      // rollback todos on error.
        //      todos = oldTodos
        //    }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodoListView()
        }
    }
}
