//
//  DateChip.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var dayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var weekdayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Text(weekdayText)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dayText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
            }
            .frame(width: 28, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        DateChip(date: Date(), isSelected: false) { }
        DateChip(date: Date(), isSelected: true) { }
    }
    .padding()
}