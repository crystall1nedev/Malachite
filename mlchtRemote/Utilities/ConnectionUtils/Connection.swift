//
//  Connection.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/12/26.
//

import Foundation
import WatchConnectivity

class Connection: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        sendWatchLoaded()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable { sendWatchLoaded() }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handle(applicationContext)
    }

    private func handle(_ dict: [String: Any]) {
        if let isForeground = dict["isForeground"] as? Bool {
            isPhoneForeground = isForeground
            DispatchQueue.main.async { NotificationCenter.default.post(name: Connection.Notifications.phoneForegroundChanged.name, object: nil) }
        }
    }
    
    static let shared = Connection()
    var isPhoneForeground = false
    var isSupported = false

    public func bringUpWatchRemote() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    private func sendWatchLoaded() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["watchLoaded": true], replyHandler: nil) { error in
                print("Failed to send watchLoaded: \(error)")
            }
        } else {
            do {
                try session.updateApplicationContext(["watchLoaded": true])
            } catch {
                print("Failed to update context with watchLoaded: \(error)")
            }
        }
    }

    func sendButtonPress(key: String) {
        WCSession.default.sendMessage(["pressed": key], replyHandler: nil) { error in
            print("Failed to send: \(error)")
        }
    }
}
