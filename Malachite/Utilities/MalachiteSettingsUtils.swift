//
//  MalachiteSettingsUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//  Assisted by Stella Luna's Battery Webhook code

import Foundation

public class MalachiteSettingsUtils : NSObject {
    public let defaults = UserDefaults.standard

    /// Resets all user settings. (Clears UserDefaults)
    public func resetAllSettings() -> Void {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }

    /// Returns the entire UserDefaults (Settings) as a Dictionary object
    public func settingsAsDictionary() -> Dictionary<String, Any> {
        return UserDefaults.standard.dictionaryRepresentation()
    }

    /**
     Does internal first time launch housekeeping tasks.
     
     For now this sets `IsFirstLaunch` in UserDefaults to `true`.
    */
    public func doAppFirstTimeLaunch() -> Void {
        defaults.set(true, forKey: "isNotFirstLaunch")
    }
}
