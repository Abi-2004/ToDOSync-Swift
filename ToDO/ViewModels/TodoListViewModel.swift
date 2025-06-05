//
//  TodoListViewModel.swift
//  ToDO
//
//  ViewModel for TodoListView
//

import Foundation
import SwiftUI
import Combine
import SwiftUI

class TodoListViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var selectedCategory: TodoCategory? = nil
    @Published var searchText = ""
    @Published var selectedDate = Date()
    @Published var showingAddTodo = false
    
    private let repository: TodoRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: TodoRepositoryProtocol) {
        self.repository = repository
        setupBindings()
    }
    
    // MARK: - Public Interface
    
    var dateRange: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var dates: [Date] = []
        
        // Add past 7 days
        for i in (1...7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        
        // Add today
        dates.append(today)
        
        // Add next 14 days
        for i in 1...14 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var canAddTodoForSelectedDate: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        return selectedDay >= today // Can add todos for today and future dates
    }
    
    var filteredTodos: [TodoItem] {
        var filtered = todos
        
        // Filter by selected date
        filtered = filtered.filter { todo in
            Calendar.current.isDate(todo.scheduledDate, inSameDayAs: selectedDate)
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                (todo.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Sort by priority and completion status
        return filtered.sorted { todo1, todo2 in
            if todo1.isCompleted != todo2.isCompleted {
                return !todo1.isCompleted // Incomplete tasks first
            }
            return todo1.priority.sortOrder > todo2.priority.sortOrder
        }
    }
    
    var completedTodosCount: Int {
        filteredTodos.filter(\.isCompleted).count
    }
    
    var incompleteTodosCount: Int {
        filteredTodos.filter { !$0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !filteredTodos.isEmpty else { return 0 }
        return Double(completedTodosCount) / Double(filteredTodos.count)
    }
    
    // MARK: - Actions
    
    func addTodo(title: String, description: String? = nil, priority: TodoPriority = .medium, category: TodoCategory = .personal) {
        let todo = TodoItem(
            title: title,
            description: description,
            priority: priority,
            category: category,
            scheduledDate: selectedDate
        )
        repository.addTodo(todo)
    }
    
    func deleteTodo(_ todo: TodoItem) {
        repository.deleteTodo(todo)
    }
    
    func deleteTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { filteredTodos[$0] }
        todosToDelete.forEach { repository.deleteTodo($0) }
    }
    
    func toggleCompletion(for todo: TodoItem) {
        repository.toggleCompletion(for: todo)
    }
    
    func selectCategory(_ category: TodoCategory?) {
        selectedCategory = category
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
    }
    
    func toggleAddTodoSheet() {
        showingAddTodo.toggle()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        repository.todos
            .receive(on: DispatchQueue.main)
            .assign(to: \.todos, on: self)
            .store(in: &cancellables)
    }
}
