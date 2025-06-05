//  TodoDataManager.swift
//  ToDO

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
        todosFileURL = documentsURL.appendingPathComponent("todos.json")
        
        // Set shared instance for WatchConnectivity access
        TodoDataManager.shared = self
        
        loadTodos()
        setupWatchConnectivity()
    }
    
    func addTodo(_ todo: TodoItem) {
        print("🍎 iOS Adding new todo: '\(todo.title)' (ID: \(todo.id))")
        print("🍎 iOS Todos before add: \(todos.count)")
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.todos.append(todo)
            print("🍎 iOS Todos after add: \(self.todos.count)")
            self.saveTodos()
            
            // Send to watch with debouncing
            self.scheduleSyncWithWatch()
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        print("🍎 iOS Deleting todo: \(todo.title)")
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.todos.removeAll { $0.id == todo.id }
            self.saveTodos()
            
            // Send to watch with debouncing
            self.scheduleSyncWithWatch()
        }
    }
    
    func updateTodo(_ todo: TodoItem) {
        print("🍎 iOS Updating todo: \(todo.title)")
        DispatchQueue.main.async {
            if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                self.objectWillChange.send()
                self.todos[index] = todo
                self.saveTodos()
                
                // Send to watch with debouncing
                self.scheduleSyncWithWatch()
            }
        }
    }
    
    func toggleCompletion(for todo: TodoItem) {
        print("🍎 iOS Toggling completion for todo: \(todo.title)")
        DispatchQueue.main.async {
            if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                self.objectWillChange.send()
                self.todos[index].isCompleted.toggle()
                self.saveTodos()
                
                // Send to watch with debouncing
                self.scheduleSyncWithWatch()
            }
        }
    }
    
    private func saveTodos() {
        print("🍎 iOS Saving \(todos.count) todos to JSON file")
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: todosFileURL)
            print("🍎 iOS Successfully saved \(todos.count) todos to file storage")
        } catch {
            print("🍎 iOS ERROR: Failed to save todos: \(error)")
        }
    }
    
    private func loadTodos() {
        print("🍎 iOS Loading todos from JSON file")
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: self.todosFileURL)
                self.objectWillChange.send()
                self.todos = try JSONDecoder().decode([TodoItem].self, from: data)
                print("🍎 iOS Loaded \(self.todos.count) todos successfully from file storage")
            } catch {
                print("🍎 iOS No existing todos found or failed to decode: \(error)")
                self.todos = []
            }
        }
    }
    
    // MARK: - Watch Connectivity Setup
    private func setupWatchConnectivity() {
        print("🍎 iOS Setting up WatchConnectivity...")
        
        // Provide todos when watch requests them
        watchConnectivity.onTodosRequested = { [weak self] in
            guard let self = self else { return [] }
            print("🍎 iOS Watch requested todos, sending \(self.todos.count) todos")
            return self.todos
        }
        
        // Handle todos received from watch
        watchConnectivity.onTodosReceived = { [weak self] watchTodos in
            print("🍎 iOS Received \(watchTodos.count) todos from watch")
            self?.mergeTodosFromWatch(watchTodos)
            // DON'T sync back to watch immediately to avoid loops
        }
        
        // Send initial todos to watch after a delay to ensure watch is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🍎 iOS Sending initial \(self.todos.count) todos to watch")
            self.watchConnectivity.sendTodos(self.todos)
            print("🍎 iOS Sent initial todos to watch")
        }
        
        // Observe reachability changes
        watchConnectivity.$isReachable
            .sink { [weak self] (isReachable: Bool) in
                if isReachable {
                    print("🍎 iOS Watch became reachable, syncing todos")
                    // Small delay to avoid conflicts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.watchConnectivity.sendTodos(self?.todos ?? [])
                    }
                }
            }
            .store(in: &cancellables)
        
        print("🍎 iOS WatchConnectivity setup completed")
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func scheduleSyncWithWatch() {
        // Cancel any existing timer
        syncTimer?.invalidate()
        
        print("🍎 iOS Scheduling sync with watch (current todos: \(todos.count))")
        
        // Schedule a new sync after a short delay to batch multiple changes
        syncTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("🍎 iOS Executing scheduled sync - sending \(self.todos.count) todos to watch")
            self.watchConnectivity.sendTodos(self.todos)
            print("🍎 iOS Synced todos to watch after debounce")
        }
    }
    
    private func mergeTodosFromWatch(_ watchTodos: [TodoItem]) {
        print("🍎 iOS MERGE START: Received \(watchTodos.count) todos from watch. Current iOS todos: \(todos.count)")
        print("🍎 iOS MERGE: Watch todos: \(watchTodos.map { "\($0.title) (id: \($0.id.uuidString.prefix(8)))" })")
        print("🍎 iOS MERGE: Current iOS todos: \(todos.map { "\($0.title) (id: \($0.id.uuidString.prefix(8)))" })")
        
        DispatchQueue.main.async {
            // Don't ignore empty watch todos - this prevents sync issues
            // Instead, use a timestamp-based or more sophisticated merge
            
            print("🍎 iOS MERGE: About to update todos...")
            self.objectWillChange.send()
            
            // Simple but effective merge: combine all unique todos
            var mergedTodos: [TodoItem] = []
            var seenIds = Set<UUID>()
            
            // Add all watch todos first (they have priority)
            for watchTodo in watchTodos {
                if !seenIds.contains(watchTodo.id) {
                    mergedTodos.append(watchTodo)
                    seenIds.insert(watchTodo.id)
                    print("🍎 iOS MERGE: Added from watch: \(watchTodo.title)")
                }
            }
            
            // Add iOS todos that aren't already included
            for iosTodo in self.todos {
                if !seenIds.contains(iosTodo.id) {
                    mergedTodos.append(iosTodo)
                    seenIds.insert(iosTodo.id)
                    print("🍎 iOS MERGE: Added from iOS: \(iosTodo.title)")
                }
            }
            
            print("🍎 iOS MERGE: Before update - todos count: \(self.todos.count)")
            self.todos = mergedTodos
            print("🍎 iOS MERGE: After update - todos count: \(self.todos.count)")
            print("🍎 iOS MERGE: Final todos: \(self.todos.map { "\($0.title) (id: \($0.id.uuidString.prefix(8)))" })")
            
            self.saveTodos()
            print("🍎 iOS MERGE COMPLETED: Final todo count: \(self.todos.count)")
            
            // Force UI update
            DispatchQueue.main.async {
                self.objectWillChange.send()
                print("🍎 iOS MERGE: Forced additional UI update")
            }
        }
    }
    
    // MARK: - Utility methods for filtering
    
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
