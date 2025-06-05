//
//  TodoRowView.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggleCompletion: (TodoItem) -> Void
    
    // Backwards compatibility initializer
    init(todo: TodoItem, dataManager: TodoDataManager) {
        self.todo = todo
        self.onToggleCompletion = { todo in
            dataManager.toggleCompletion(for: todo)
        }
    }
    
    // MVVM compatible initializer
    init(todo: TodoItem, onToggleCompletion: @escaping (TodoItem) -> Void) {
        self.todo = todo
        self.onToggleCompletion = onToggleCompletion
    }
    
    var body: some View {
        HStack {
            Button(action: {
                onToggleCompletion(todo)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(todo.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(todo.category.color.opacity(0.2))
                        .foregroundColor(todo.category.color)
                        .cornerRadius(8)
                    
                    Text(todo.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(todo.priority.color.opacity(0.2))
                        .foregroundColor(todo.priority.color)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        // Show scheduled date
                        Text(todo.scheduledDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Show due date if exists
                        if let dueDate = todo.dueDate {
                            Text("Due: \(dueDate, style: .date)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.background)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}