//  TodoDataManager.swift
//  ToDOWatch Watch App

import Foundation
import Combine

class TodoDataManager: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    // Use JSON file persistence
    private let documentsURL: URL
    private let todosFileURL: URL

    // WatchConnectivity for syncing
    private let watchConnectivity = WatchConnectivityManager.shared
    
    // Timer for debouncing sync requests
    private var syncTimer: Timer?
    
    // Shared instance for WatchConnectivity access
    static var shared: TodoDataManager!

    init() {
        // Setup file URLs first
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        todosFileURL = documentsURL.appendingPathComponent("watch_todos.json")
        
        // Set shared instance for WatchConnectivity access
        TodoDataManager.shared = self
        
        loadTodos()
        setupWatchConnectivity()
    }

    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
        saveTodos()
        
        // Debounce sync to iPhone
        debouncedSync()
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
        
        // Debounce sync to iPhone
        debouncedSync()
    }

    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
            
            // Debounce sync to iPhone
            debouncedSync()
        }
    }
    
    func toggleCompletion(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            saveTodos()
            
            // Debounce sync to iPhone
            debouncedSync()
        }
    }

    private func loadTodos() {
        guard FileManager.default.fileExists(atPath: todosFileURL.path) else {
            todos = []
            return
        }
        
        do {
            let data = try Data(contentsOf: todosFileURL)
            todos = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            todos = []
        }
    }
    
    private func saveTodos() {
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: todosFileURL)
        } catch {
        }
    }
    
    private func debouncedSync() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.syncToiPhone()
        }
    }
    
    private func syncToiPhone() {
        watchConnectivity.sendTodos(todos)
    }

    // MARK: - Watch Connectivity Setup

    private func setupWatchConnectivity() {
        // Handle todos received from iPhone
        watchConnectivity.onTodosReceived = { [weak self] (iPhoneTodos: [TodoItem]) in
            self?.mergeTodosFromiPhone(iPhoneTodos)
        }

        // Provide our todos when iPhone requests them
        watchConnectivity.onTodosRequested = { [weak self] in
            return self?.todos ?? []
        }

        // Request initial sync from iPhone
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.watchConnectivity.requestTodosFromiPhone()
        }
    }

    private func mergeTodosFromiPhone(_ iPhoneTodos: [TodoItem]) {
        // Replace local todos with iPhone todos
        todos = iPhoneTodos
        saveTodos()
    }

    // MARK: - Stats and utility methods

    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }

    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }

    var todayTodos: [TodoItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        return todos.filter { todo in
            let todoDate = Calendar.current.startOfDay(for: todo.scheduledDate)
            return todoDate >= today && todoDate < tomorrow
        }
    }

    var overdueTodos: [TodoItem] {
        let today = Calendar.current.startOfDay(for: Date())

        return todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return dueDate < today && !todo.isCompleted
        }
    }

    // Filter todos for a specific date
    func todosForDate(_ date: Date) -> [TodoItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return todos.filter { todo in
            let todoDate = calendar.startOfDay(for: todo.scheduledDate)
            return todoDate >= startOfDay && todoDate < endOfDay
        }
    }

    // Filter todos for a specific category and date
    func todosForCategory(_ category: TodoCategory?, date: Date) -> [TodoItem] {
        var filtered = todosForDate(date)

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        return filtered.sorted { first, second in
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted
            }
            if first.priority.sortOrder != second.priority.sortOrder {
                return first.priority.sortOrder < second.priority.sortOrder
            }
            return first.scheduledDate < second.scheduledDate
        }
    }
}
