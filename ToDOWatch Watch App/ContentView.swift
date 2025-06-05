//

//  Created by Abi on 29/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dataManager: TodoDataManager
    @State private var selectedDate = Date()
    @State private var selectedCategory: TodoCategory? = nil
    @State private var showingAddTodo = false
    
    private var filteredTodos: [TodoItem] {
        dataManager.todosForCategory(selectedCategory, date: selectedDate)
    }
    
    private var currentDateText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: -10) {
                    // Header with date and category filter
                    VStack(spacing: 1) {
                        // Date display with navigation indicator
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                                .opacity(0.6)
                            
                            Spacer()
                            
                            DateNavigationView(selectedDate: selectedDate)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                                .opacity(0.6)
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    if value.translation.width > threshold {
                                        // Swipe right - previous day
                                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                    } else if value.translation.width < -threshold {
                                        // Swipe left - next day
                                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                    }
                                }
                        )
                        
                        // Category filter
                        CategoryFilterScrollView(selectedCategory: $selectedCategory)
                        
                        // Task count and stats - combined
                        if !filteredTodos.isEmpty {
                            let dayTodos = dataManager.todosForDate(selectedDate)
                            let completed = dayTodos.filter { $0.isCompleted }.count
                            let total = dayTodos.count
                            let remaining = filteredTodos.filter { !$0.isCompleted }.count
                            
                            HStack(spacing: 8) {
                                Text("\(remaining) remaining")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                if total > 0 {
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        HStack(spacing: 2) {
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 4, height: 4)
                                            Text("\(completed)")
                                                .font(.system(size: 9, weight: .medium))
                                        }
                                        
                                        HStack(spacing: 2) {
                                            Circle()
                                                .fill(.orange)
                                                .frame(width: 3, height: 3)
                                            Text("\(total - completed)")
                                                .font(.system(size: 9, weight: .medium))
                                        }
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                        } else if !dataManager.todosForDate(selectedDate).isEmpty {
                            Text("All tasks completed!")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)
                    
                    // Content area
                    if filteredTodos.isEmpty && dataManager.todosForDate(selectedDate).isEmpty {
                        // Empty state - no tasks for this day
                        VStack(spacing: 6) {
                            Image(systemName: "party.popper.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Hurray!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Nothing to do today")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                    } else if filteredTodos.isEmpty {
                        // Category filtered - no tasks in this category
                        VStack(spacing: 6) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("No tasks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let category = selectedCategory {
                                HStack(spacing: 2) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 8))
                                    Text(category.rawValue)
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(category.color)
                            }
                        }
                        .padding(.top, 20)
                    } else {
                        // Task list with add button at top
                        List {
                            // Add button as first item in list
                            Button(action: {
                                showingAddTodo = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.blue)
                                    
                                    Text("Add Todo")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 9.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                            
                            // Todo items
                            ForEach(filteredTodos) { todo in
                                TodoRowView(todo: todo, dataManager: dataManager)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                // Floating Add Button - only show when no tasks exist
                if filteredTodos.isEmpty {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showingAddTodo = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(.blue)
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.2), value: filteredTodos.isEmpty)
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView(dataManager: dataManager, selectedDate: selectedDate)
        }
    }
}

struct CategoryFilterScrollView: View {
    @Binding var selectedCategory: TodoCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All filter - just a circle
                CategoryChip(
                    title: "",
                    icon: "circle.grid.2x2",
                    color: .gray,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // Category filters - only icons
                ForEach(TodoCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: "",
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String?
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : color)
                }
                
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 8, weight: .medium))
                }
            }
            .frame(width: 25, height: 24)
            .background(
                Circle()
                    .fill(isSelected ? color : color.opacity(0.2))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
