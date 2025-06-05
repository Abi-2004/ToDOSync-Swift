//  TodoModels.swift
//  ToDO

import SwiftUI
import Foundation

enum TodoCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health"
    case finance = "Finance"
    case study = "Study"
    
    var color: Color {
        switch self {
        case .work:
            return .blue
        case .personal:
            return .green
        case .shopping:
            return .orange
        case .health:
            return .red
        case .finance:
            return .purple
        case .study:
            return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .work:
            return "briefcase.fill"
        case .personal:
            return "person.fill"
        case .shopping:
            return "cart.fill"
        case .health:
            return "heart.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .study:
            return "book.fill"
        }
    }
}

enum TodoPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
