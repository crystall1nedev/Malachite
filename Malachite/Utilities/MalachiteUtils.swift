//
//  MalachiteUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/10/23.
//

import Foundation
import UIKit

public class MalachiteClassesObject : NSObject {
    /// An instance of ``MalachiteHapticUtils``
    public let haptics   = MalachiteHapticUtils()
    /// An instance of ``MalachiteViewUtils``
    public let views     = MalachiteViewUtils()
    /// An instance of ``MalachiteFunctionUtils``
    public let function  = MalachiteFunctionUtils()
    /// An instance of the shared `MalachitePreferencesUtils` class
    var preferences: MalachitePreferences {
        get { return MalachitePreferencesUtils.shared.preferences }
        set {
            MalachitePreferencesUtils.shared.preferences = newValue
            if MalachitePreferencesUtils().writePreferences(newValue) { internalNSLog("[Preferences] Updated preferences successfully.") }
        }
    }
    /// An instance of ``MalachiteTooltipUtils``
    public let tooltips  = MalachiteTooltipUtils()
    /// An instance of ``MalachiteGameUtils``
    public let games     = MalachiteGameUtils()
    
    /// Private static storage for the session queue.
    @available(iOS 17.0, *)
    private static var _sessionQueue: DispatchSerialQueue = DispatchSerialQueue(label: "dev.crystll1ne.Malachite.controlsSessionQueue")
    /// A session queue used to absorb Camera Control states.
    @available(iOS 18.0, *)
    public var sessionQueue: DispatchSerialQueue {
        return Self._sessionQueue
    }
    
    /// A variable that denotes the major version of Malachite.
    public let versionMajor    = "1"
    /// A variable that denotes the minor version of Malachite.
    public let versionMinor    = "0"
    /// A variable that denotes the bugfix version of Malachite.
    public let versionFixer    = "0"
    /// A variable that can be used to pull the git commit hash from the Info.plist
    public let versionHash     = Bundle.main.object(forInfoDictionaryKey: "CFBuildHash") as? String ?? "undefined"
    /// A variable that can be used to pull the git branch from the Info.plist
    public let versionBranch   = Bundle.main.object(forInfoDictionaryKey: "CFBuildBran") as? String ?? "undefined"
    /// A variable that can be used to pull the build time from the Info.plist
    public let versionDate     = Bundle.main.object(forInfoDictionaryKey: "CFBuildDate") as? String ?? "undefined"
    /// A variable that can be used to identify the variant of the build from the Info.plist
    public let versionType     = Bundle.main.object(forInfoDictionaryKey: "CFBuildType") as? String ?? "undefined"
    /// A variable that can be used to identify the username of the account that built the app from the Info.plist
    public let versionUser     = Bundle.main.object(forInfoDictionaryKey: "CFBuildUser") as? String ?? "undefined"
    /// A variable that can be used to identify the hostname of the computer that built the app from the Info.plist
    public let versionHost     = Bundle.main.object(forInfoDictionaryKey: "CFBuildHost") as? String ?? "undefined"
    
    /// A variable that determines the type of device Malachite is running on.
    public let idiom     = UIDevice.current.userInterfaceIdiom
    
    /// A function to only log in INTERNAL builds
    public func internalNSLog(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        if self.versionType == "INTERNAL" {
            Foundation.NSLog("[\(file):\(line)] [\(function)] [INTERNAL] \(format)")
        }
    }
    
    /// A function to only log in DEBUG and INTERNAL builds
    public func debugNSLog(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        if self.versionType == "DEBUG" || self.versionType == "INTERNAL" {
            Foundation.NSLog("[\(NSString(string: file).lastPathComponent):\(line)] [\(function)] \(format)")
        }
    }
    
    /// Literally just regular NSLog, here for consistency
    public func NSLog(_ format: String) {
        Foundation.NSLog(format)
    }
}

