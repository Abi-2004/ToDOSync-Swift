//
//  TodoRowView.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let dataManager: TodoDataManager
    @State private var offset = CGSize.zero
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle - much larger and more accessible
            Button(action: {
                dataManager.toggleCompletion(todo)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 28, height: 28)
            
            // Content - much larger text and better spacing
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .strikethrough(todo.isCompleted)
                    .opacity(todo.isCompleted ? 0.6 : 1.0)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    // Category chip - larger and more readable
                    HStack(spacing: 4) {
                        Image(systemName: todo.category.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(todo.category.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(todo.category.color.opacity(0.3))
                    )
                    .foregroundColor(todo.category.color)
                    
                                        Spacer()
                    
                    // Priority indicator - much larger and more visible
                    Circle()
                        .fill(todo.priority.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Background indicators
                HStack {
                    // Left side - Complete action (green)
                    if offset.width > 0 {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                            Text("Done")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                                .opacity(min(abs(offset.width) / 60.0, 1.0))
                        )
                    }
                    
                    // Right side - Delete action (red)
                    if offset.width < 0 {
                        HStack {
                            Spacer()
                            Text("Delete")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                                .opacity(min(abs(offset.width) / 60.0, 1.0))
                        )
                    }
                }
                
                // Main todo content
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .opacity(todo.isCompleted ? 0.6 : 1.0)
            }
        )
        .offset(x: offset.width, y: 0) // Only allow horizontal movement
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow horizontal dragging
                    let horizontalTranslation = value.translation.width
                    
                    // Limit the drag distance to prevent over-stretching
                    let maxDrag: CGFloat = 100
                    if abs(horizontalTranslation) <= maxDrag {
                        offset = CGSize(width: horizontalTranslation, height: 0)
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    let horizontalTranslation = value.translation.width
                    
                    if horizontalTranslation > threshold {
                        // Swipe right - complete/uncomplete
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dataManager.toggleCompletion(todo)
                            offset = .zero
                        }
                    } else if horizontalTranslation < -threshold {
                        // Swipe left - delete
                        withAnimation(.easeInOut(duration: 0.2)) {
                            offset = .zero
                        }
                        showingDeleteAlert = true
                    } else {
                        // Snap back with smooth animation
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset = .zero
                        }
                    }
                }
        )
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    dataManager.deleteTodo(todo)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(todo.title)'?")
        }
    }
}

#Preview {
    TodoRowView(
        todo: TodoItem(
            title: "Sample Task",
            description: "This is a sample task",
            priority: .high,
            category: .work
        ),
        dataManager: TodoDataManager()
    )
    .padding()
}