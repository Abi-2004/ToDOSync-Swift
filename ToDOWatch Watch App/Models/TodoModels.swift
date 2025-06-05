//  TodoModels.swift
//  ToDOWatch Watch App

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

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var priority: TodoPriority
    var category: TodoCategory
    var scheduledDate: Date // The day this task is scheduled for
    var dueDate: Date?
    var createdAt: Date
    
    init(title: String, description: String? = nil, priority: TodoPriority = .medium, category: TodoCategory = .personal, scheduledDate: Date = Date(), dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.category = category
        self.scheduledDate = scheduledDate
        self.dueDate = dueDate
        self.createdAt = Date()
    }
    
    // Custom initializer with specific ID (for syncing)
    init(id: UUID, title: String, description: String? = nil, isCompleted: Bool = false, priority: TodoPriority = .medium, category: TodoCategory = .personal, scheduledDate: Date = Date(), dueDate: Date? = nil, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.category = category
        self.scheduledDate = scheduledDate
        self.dueDate = dueDate
        self.createdAt = createdAt
    }
    
    // Custom coding keys to handle UUID
    private enum CodingKeys: String, CodingKey {
        case id, title, description, isCompleted, priority, category, scheduledDate, dueDate, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        priority = try container.decode(TodoPriority.self, forKey: .priority)
        category = try container.decode(TodoCategory.self, forKey: .category)
        scheduledDate = try container.decode(Date.self, forKey: .scheduledDate)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encode(scheduledDate, forKey: .scheduledDate)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
