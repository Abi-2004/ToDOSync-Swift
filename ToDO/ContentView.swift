//
//  ContentView.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: TodoDataManager
    
    var body: some View {
        TodoListView()
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoDataManager())
}
