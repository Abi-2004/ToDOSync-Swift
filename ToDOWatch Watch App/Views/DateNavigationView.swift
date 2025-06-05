//
//  DateNavigationView.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct DateNavigationView: View {
    let selectedDate: Date
    
    private var dateText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: selectedDate)
        }
    }
    
    private var weekdayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 1) {
            Text(dateText)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if !Calendar.current.isDateInToday(selectedDate) {
                Text(weekdayText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DateNavigationView(selectedDate: Date())
        DateNavigationView(selectedDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        DateNavigationView(selectedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }
    .padding()
}
