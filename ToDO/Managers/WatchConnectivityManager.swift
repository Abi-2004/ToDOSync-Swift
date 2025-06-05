//
//  WatchConnectivityManager.swift
//  ToDO
//
//  Created by Abi on 29/5/25.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable = false
    @Published var isPaired = false
    @Published var isWatchAppInstalled = false
    
    // Callback for when todos are received from watch
    var onTodosReceived: (([TodoItem]) -> Void)?
    
    // Callback for when watch requests todos from iPhone
    var onTodosRequested: (() -> [TodoItem])?
    
    private let session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func sendTodos(_ todos: [TodoItem]) {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            return
        }
        
        do {
            let todosData = try JSONEncoder().encode(todos)
            let message = ["todos": todosData, "timestamp": Date().timeIntervalSince1970] as [String : Any]
            
            // Try to send via message if reachable, otherwise use updateApplicationContext
            if session.isReachable {
                session.sendMessage(message, replyHandler: { reply in
                }, errorHandler: { error in
                    // Fallback to application context
                    self.updateApplicationContext(message)
                })
            } else {
                updateApplicationContext(message)
            }
        } catch {
        }
    }
    
    private func updateApplicationContext(_ message: [String: Any]) {
        do {
            try session.updateApplicationContext(message)
        } catch {
        }
    }
    
    func requestTodosFromWatch() {
        guard session.isReachable else {
            return
        }
        
        session.sendMessage(["request": "todos"], replyHandler: { reply in
            if let todosData = reply["todos"] as? Data,
               let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
                DispatchQueue.main.async {
                    self.onTodosReceived?(todos)
                }
            }
        }, errorHandler: { error in
        })
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            return
        }
        
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    // Handle messages from watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["request"] as? String == "todos" {
            // Watch is requesting todos - this is handled in replyHandler version
            return
        }
        
        if let todosData = message["todos"] as? Data,
           let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
        }
    }
    
    // Handle messages with reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "todos" {
            // Watch is requesting our todos
            if let todos = onTodosRequested?() {
                do {
                    let todosData = try JSONEncoder().encode(todos)
                    replyHandler(["todos": todosData])
                } catch {
                    replyHandler(["error": "Failed to encode todos"])
                }
            } else {
                replyHandler(["error": "No todos available"])
            }
        } else if let todosData = message["todos"] as? Data,
                  let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            // Watch is sending us updated todos
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
            // Reply with our current todos to confirm receipt
            if let currentTodos = onTodosRequested?() {
                do {
                    let currentTodosData = try JSONEncoder().encode(currentTodos)
                    replyHandler(["todos": currentTodosData])
                } catch {
                    replyHandler(["error": "Failed to encode current todos"])
                }
            } else {
                replyHandler(["error": "No current todos available"])
            }
        } else {
            replyHandler(["error": "Unknown message format"])
        }
    }
    
    // Handle application context updates
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("🍎 iOS WatchConnectivity: Received application context: \(applicationContext.keys)")
        
        if let todosData = applicationContext["todos"] as? Data,
           let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            print("🍎 iOS WatchConnectivity: Received \(todos.count) todos from watch context")
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
        }
    }
}
