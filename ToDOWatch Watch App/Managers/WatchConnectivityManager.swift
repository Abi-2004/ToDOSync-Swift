//  WatchConnectivityManager.swift
//  ToDOWatch Watch App

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable = false
    
    // Callbacks
    var onTodosReceived: (([TodoItem]) -> Void)?
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
    
    func requestTodosFromiPhone() {
        if session.isReachable {
            session.sendMessage(["request": "todos"], replyHandler: { reply in
                if let todosData = reply["todos"] as? Data,
                   let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
                    DispatchQueue.main.async {
                        self.onTodosReceived?(todos)
                    }
                }
            }, errorHandler: { error in
            })
        } else {
            // Check if there's data in application context
            if let context = session.receivedApplicationContext as? [String: Any],
               let todosData = context["todos"] as? Data,
               let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
                DispatchQueue.main.async {
                    self.onTodosReceived?(todos)
                }
            }
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("⌚ Watch: Session activation failed: \(error.localizedDescription)")
            return
        }
        
        print("⌚ Watch: Session activated with state: \(activationState.rawValue)")
        print("⌚ Watch: isReachable = \(session.isReachable)")
        
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        
        // Check for any pending data in application context
        if let context = session.receivedApplicationContext as? [String: Any],
           let todosData = context["todos"] as? Data,
           let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            print("⌚ Watch: Found \(todos.count) todos in initial application context")
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
        } else {
            print("⌚ Watch: No todos found in initial application context")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("⌚ Watch: Reachability changed to: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        
        // When iPhone becomes reachable, request latest todos
        if session.isReachable {
            print("⌚ Watch: iPhone became reachable, requesting todos")
            requestTodosFromiPhone()
        }
    }
    
    // Handle messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("⌚ Watch: Received message without reply: \(message.keys)")
        
        if message["request"] as? String == "todos" {
            // iPhone is requesting todos - this is handled in replyHandler version
            print("⌚ Watch: iPhone requesting todos (no reply expected)")
            return
        }
        
        if let todosData = message["todos"] as? Data,
           let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            print("⌚ Watch: Received \(todos.count) todos from iPhone")
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
        } else {
            print("⌚ Watch: Could not decode todos from message")
        }
    }
    
    // Handle messages with reply
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("⌚ Watch received message with reply: \(message.keys)")
        
        if message["request"] as? String == "todos" {
            // iPhone is requesting our todos
            print("⌚ Watch: iPhone requesting todos")
            if let todos = onTodosRequested?() {
                do {
                    let todosData = try JSONEncoder().encode(todos)
                    replyHandler(["todos": todosData])
                    print("⌚ Watch: Sent \(todos.count) todos to iPhone")
                } catch {
                    print("⌚ Watch: Error encoding todos: \(error)")
                    replyHandler(["error": "Failed to encode todos"])
                }
            } else {
                print("⌚ Watch: No todos callback available")
                replyHandler(["todos": try! JSONEncoder().encode([TodoItem]())]) // Return empty array instead of error
            }
        } else if message["todos"] != nil {
            // iPhone is sending todos to us - process them and acknowledge
            print("⌚ Watch: iPhone is sending todos to us")
            if let todosData = message["todos"] as? Data,
               let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
                print("⌚ Watch: Successfully received \(todos.count) todos from iPhone")
                DispatchQueue.main.async {
                    self.onTodosReceived?(todos)
                }
                replyHandler(["status": "received", "count": todos.count])
            } else {
                print("⌚ Watch: Failed to decode todos from iPhone")
                replyHandler(["error": "Failed to decode todos"])
            }
        } else {
            print("⌚ Watch: Unknown message type: \(message.keys)")
            replyHandler(["error": "Unknown message type"])
        }
    }
    
    // Handle application context updates
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("⌚ Watch: Received application context: \(applicationContext.keys)")
        
        if let todosData = applicationContext["todos"] as? Data,
           let todos = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            print("⌚ Watch: Successfully decoded \(todos.count) todos from application context")
            DispatchQueue.main.async {
                self.onTodosReceived?(todos)
            }
        } else {
            print("⌚ Watch: Could not decode todos from application context")
        }
    }
}
