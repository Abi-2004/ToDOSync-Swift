//
//  SyncConstants.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import Foundation

struct SyncConstants {
    // App Group identifier
    static let appGroupIdentifier = "group.com.yourcompany.app"
    
    // UserDefaults keys for todos
    static let iPhoneTodosKey = "iPhoneTodos"
    static let watchTodosKey = "WatchTodos"
    
    // UserDefaults keys for timestamps
    static let iPhoneLastUpdatedKey = "iPhoneLastUpdated"
    static let watchLastUpdatedKey = "WatchLastUpdated"
    
    // Sync timing
    static let syncInterval: TimeInterval = 2.0
}
