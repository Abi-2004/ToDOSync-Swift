//
//  ToDOApp.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

@main
struct ToDOApp: App {
    @StateObject private var dataManager = TodoDataManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        // Trigger sync when app becomes active
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Small delay to ensure the sync happens after the app is fully active
                        }
                    }
                }
        }
    }
}
