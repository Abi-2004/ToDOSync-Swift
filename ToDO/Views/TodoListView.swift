//
//  TodoListView.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var dataManager: TodoDataManager
    @State private var selectedCategory: TodoCategory? = nil
    @State private var selectedDate = Date()
    @State private var showingAddTodo = false
    @State private var searchText = ""
    
    private var filteredTodos: [TodoItem] {
        var todos = dataManager.todosForCategory(selectedCategory, date: selectedDate)
        
        if !searchText.isEmpty {
            todos = todos.filter { todo in
                todo.title.localizedCaseInsensitiveContains(searchText) ||
                ((todo.description?.localizedCaseInsensitiveContains(searchText)) != nil)
            }
        }
        
        return todos
    }
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dates: [Date] = []
        
        // Add 7 days before today
        for i in (1...7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(date)
            }
        }
        
        // Add today
        dates.append(today)
        
        // Add 7 days after today
        for i in 1...7 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterChip(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            color: .gray,
                            icon: nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(TodoCategory.allCases, id: \.self) { category in
                            CategoryFilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                color: category.color,
                                icon: category.icon
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Date Selector ScrollView
                VStack(spacing: 12) {
                    HStack {
                        Text("Select Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            selectedDate = Calendar.current.startOfDay(for: Date())
                        }) {
                            Text("Today")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            HStack(spacing: 12) {
                                ForEach(dateRange, id: \.self) { date in
                                    DateChip(
                                        date: date,
                                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                        isToday: Calendar.current.isDate(date, inSameDayAs: Date())
                                    ) {
                                        selectedDate = date
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .onAppear {
                                // Scroll to today on appear
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    proxy.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Enhanced Search Bar
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Search your tasks...", text: $searchText)
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Date Display
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(selectedDate.formatted(.dateTime.day().month(.wide).year()))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Task count
                        if !filteredTodos.isEmpty {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(filteredTodos.filter { !$0.isCompleted }.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("remaining")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Todo List or Empty State
                if filteredTodos.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        let isToday = Calendar.current.isDate(selectedDate, inSameDayAs: Date())
                        let isPast = selectedDate < Calendar.current.startOfDay(for: Date())
                        
                        Image(systemName: isToday ? "checkmark.circle" : (isPast ? "clock" : "calendar"))
                            .font(.system(size: 60))
                            .foregroundColor(isToday ? .green : (isPast ? .orange : .blue))
                        
                        if isToday {
                            Text("Hurray! Nothing to do today")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Enjoy your free time or add a new task")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        } else if isPast {
                            Text("No tasks on \(selectedDate.formatted(.dateTime.month(.wide).day()))")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("This day has passed")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("No tasks on \(selectedDate.formatted(.dateTime.month(.wide).day()))")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("Add a task for this day")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTodos) { todo in
                            TodoRowView(todo: todo, onToggleCompletion: { todo in
                                dataManager.toggleCompletion(for: todo)
                            })
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                dataManager.deleteTodo(filteredTodos[index])
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("ToDO")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(dataManager: dataManager, initialDate: selectedDate)
            }
        }
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TodoListView()
        .environmentObject(TodoDataManager())
}
