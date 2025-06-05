//
//  AddTodoView.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct AddTodoView: View {
    let dataManager: TodoDataManager
    let selectedDate: Date
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedCategory: TodoCategory = .personal
    @State private var selectedPriority: TodoPriority = .medium
    
    private var dateText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "today"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "tomorrow"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title input at the top
                VStack(spacing: 8) {
                    Text("Adding task for \(dateText)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("Enter task...", text: $title)
                        .font(.system(size: 14))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 8)
                    
                    // Category selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(TodoCategory.allCases, id: \.self) { category in
                                CategorySelectChip(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Priority selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 6) {
                            ForEach(TodoPriority.allCases, id: \.self) { priority in
                                PrioritySelectChip(
                                    priority: priority,
                                    isSelected: selectedPriority == priority
                                ) {
                                    selectedPriority = priority
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    // Action buttons
                    VStack(spacing: 8) {
                        Button("Add Task") {
                            addTodo()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .padding(.top, 8)
            }
        .navigationTitle("New Task")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addTodo() {
        let newTodo = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: selectedPriority,
            category: selectedCategory,
            scheduledDate: selectedDate
        )
        
        dataManager.addTodo(newTodo)
        dismiss()
    }
}

struct CategorySelectChip: View {
    let category: TodoCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(category.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .lineLimit(1)
            }
            .frame(minWidth: 40, minHeight: 40)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? category.color : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrioritySelectChip: View {
    let priority: TodoPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 8, height: 8)
                Text(priority.rawValue)
                    .font(.system(size: 12, weight: .medium))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? priority.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? priority.color : Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .foregroundColor(isSelected ? priority.color : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddTodoView(
        dataManager: TodoDataManager(),
        selectedDate: Date()
    )
}
