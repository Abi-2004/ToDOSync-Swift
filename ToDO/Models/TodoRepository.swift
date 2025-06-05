//
//  TodoRepository.swift
//  ToDO
//
//  Repository pattern for data management
//

import Foundation
import Combine

protocol TodoRepositoryProtocol {
    var todos: Published<[TodoItem]>.Publisher { get }
    func addTodo(_ todo: TodoItem)
    func deleteTodo(_ todo: TodoItem)
    func updateTodo(_ todo: TodoItem)
    func toggleCompletion(for todo: TodoItem)
}

class TodoRepository: ObservableObject, TodoRepositoryProtocol {
    @Published private var _todos: [TodoItem] = []
    
    var todos: Published<[TodoItem]>.Publisher { $_todos }
    
    // Use TodoDataManager as the single source of truth
    private let dataManager: TodoDataManager
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Create TodoDataManager if shared instance doesn't exist
        if TodoDataManager.shared == nil {
            self.dataManager = TodoDataManager()
        } else {
            self.dataManager = TodoDataManager.shared
        }
        
        // Subscribe to TodoDataManager's todos
        dataManager.$todos
            .sink { [weak self] todos in
                self?._todos = todos
            }
            .store(in: &cancellables)
    }
    
    func addTodo(_ todo: TodoItem) {
        dataManager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: TodoItem) {
        dataManager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: TodoItem) {
        dataManager.updateTodo(todo)
    }
    
    func toggleCompletion(for todo: TodoItem) {
        dataManager.toggleCompletion(for: todo)
    }
}
