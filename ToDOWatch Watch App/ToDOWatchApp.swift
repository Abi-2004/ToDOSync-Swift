//
//  ToDOWatchApp.swift
//  ToDOWatch Watch App
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

@main
struct ToDOWatch_Watch_AppApp: App {
    @StateObject private var todoManager = TodoDataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoManager)
        }
    }
}
