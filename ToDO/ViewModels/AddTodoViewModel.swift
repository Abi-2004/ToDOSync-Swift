//
//  AddTodoViewModel.swift
//  ToDO
//
//  ViewModel for AddTodoView
//

import Foundation
import SwiftUI

class AddTodoViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedCategory: TodoCategory = .personal
    @Published var selectedPriority: TodoPriority = .medium
    
    private let repository: TodoRepositoryProtocol
    private let initialDate: Date
    
    init(repository: TodoRepositoryProtocol, initialDate: Date = Date()) {
        self.repository = repository
        self.initialDate = initialDate
    }
    
    // MARK: - Computed Properties
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var priorityGradient: LinearGradient {
        let priorityColor = selectedPriority.color
        return LinearGradient(
            colors: [priorityColor.opacity(0.8), priorityColor.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: initialDate)
    }
    
    // MARK: - Actions
    
    func saveTodo() -> Bool {
        guard canSave else { return false }
        
        let todo = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: selectedPriority,
            category: selectedCategory,
            scheduledDate: initialDate
        )
        
        repository.addTodo(todo)
        return true
    }
    
    func selectCategory(_ category: TodoCategory) {
        selectedCategory = category
    }
    
    func selectPriority(_ priority: TodoPriority) {
        selectedPriority = priority
    }
    
    func clearForm() {
        title = ""
        description = ""
        selectedCategory = .personal
        selectedPriority = .medium
    }
}
