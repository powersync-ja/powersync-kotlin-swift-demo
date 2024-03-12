import IdentifiedCollections
import SwiftUI
import SwiftUINavigation

struct TodoListView: View {
    @Environment(PowerSync.self) var powerSync
    
    @State var todos: IdentifiedArrayOf<Todo> = []
    @State var error: Error?
    
    @State var newTodo: NewTodo?
    @State var editing: Bool = false
    
    var body: some View {
        List {
            if let error {
                ErrorText(error)
            }
            
            if(editing){
                IfLet($newTodo) { $newTodo in
                    AddTodoListView(newTodo: $newTodo) { result in
                        withAnimation {
                            editing = false
                        }
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
                            editing = true
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
            await powerSync.connect()
            await powerSync.watchTodos { tds in
                todos = IdentifiedArrayOf(uniqueElements: tds)
            }
        }
    }
    
    @MainActor
    func toggleCompletion(of todo: Todo) async {
        var updatedTodo = todo
        updatedTodo.isComplete.toggle()
        do {
            error = nil
            try await powerSync.updateTodo(updatedTodo)
        } catch {
            self.error = error
        }
    }
    
    func delete(at offset: IndexSet) async {
        do {
            error = nil
            let todosToDelete = offset.map { todos[$0] }
            
            try await powerSync.deleteTodo(id: todosToDelete[0].id)
            
        } catch {
            self.error = error
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodoListView()
        }
    }
}
