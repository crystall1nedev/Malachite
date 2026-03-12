//
//  Watch.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/11/26.
//

import Foundation
import WatchConnectivity

public class Watch: NSObject, WCSessionDelegate {
    var isForegrounded = false
    
    public func bringUpCompanionConnection() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        guard activationState == .activated else { return }
        handle(session.receivedApplicationContext)
        sendForegroundState()
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // stub
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        // stub
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handle(applicationContext)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(message)
    }
    
    public func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable { sendForegroundState() }
    }
    
    private func handle(_ dict: [String: Any]) {
        if dict["watchLoaded"] as? Bool == true { sendForegroundState() }
        
        switch dict["pressed"] as? String {
        case "capture":     NotificationCenter.default.post(name: Notifications.buttonPressed.capture.name, object: nil)
        case "cameras":     NotificationCenter.default.post(name: Notifications.buttonPressed.cameras.name, object: nil)
        case "flashlight":  NotificationCenter.default.post(name: Notifications.buttonPressed.flashlight.name, object: nil)
        case "settings":    NotificationCenter.default.post(name: Notifications.buttonPressed.settings.name, object: nil)
        default: print("bruh")
        }
        
    }
    
    public func notifyOfForegroundChange() {
        isForegrounded = !isForegrounded
        sendForegroundState()
    }
    
    public func sendForegroundState() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage([ "isForeground": isForegrounded ], replyHandler: nil, errorHandler: nil)
        } else {
            do {
                try WCSession.default.updateApplicationContext([ "isForeground": isForegrounded ])
            } catch {
                print(error)
            }
        }
    }
}

extension Watch {
    class Notifications {
        enum buttonPressed: String, NotificationName {
            case capture
            case cameras
            case flashlight
            case settings
        }
    }
}
