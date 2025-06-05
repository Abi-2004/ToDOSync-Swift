//
//  DateChip.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .secondary))
                
                Text(date.formatted(.dateTime.day()))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                Text(date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .secondary))
            }
            .frame(width: 60, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .blue : (isToday ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? .blue : (isToday ? .blue : Color.gray.opacity(0.3)), lineWidth: isSelected || isToday ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        DateChip(date: Date(), isSelected: false, isToday: true) { }
        DateChip(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, isSelected: true, isToday: false) { }
        DateChip(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, isSelected: false, isToday: false) { }
    }
}
