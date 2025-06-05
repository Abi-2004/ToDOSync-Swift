//
//  StatsView.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI
import Foundation

struct StatsView: View {
    @ObservedObject var dataManager: TodoDataManager
    let selectedDate: Date
    
    private var todayTodos: [TodoItem] {
        dataManager.todosForDate(selectedDate)
    }
    
    private var completedCount: Int {
        todayTodos.filter { $0.isCompleted }.count
    }
    
    private var pendingCount: Int {
        todayTodos.filter { !$0.isCompleted }.count
    }
    
    private var completionPercentage: Double {
        guard !todayTodos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todayTodos.count)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: completionPercentage)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: completionPercentage)
                
                VStack(spacing: 1) {
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("done")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats breakdown
            HStack(spacing: 12) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    count: completedCount,
                    label: "Done",
                    color: .green
                )
                
                StatItem(
                    icon: "circle",
                    count: pendingCount,
                    label: "Left",
                    color: .orange
                )
            }
        }
        .padding()
    }
}

struct StatItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
            
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StatsView(
        dataManager: TodoDataManager(),
        selectedDate: Date()
    )
}
