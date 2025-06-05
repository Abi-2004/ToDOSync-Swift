//
//  TodoComplication.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI
import Foundation

// Vista simple para mostrar estadísticas de tareas
struct TodoStatsView: View {
    @ObservedObject var dataManager: TodoDataManager
    
    private var todayPendingCount: Int {
        let today = Date()
        let todosToday = dataManager.todosForDate(today)
        return todosToday.filter { !$0.isCompleted }.count
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("\(todayPendingCount)")
                .font(.caption2)
                .fontWeight(.bold)
            
            Text("pending")
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TodoStatsView(dataManager: TodoDataManager())
}
