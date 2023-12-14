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
    public func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }

    /// Returns the entire UserDefaults (Settings) as a Dictionary object
    public func settingsAsDictionary() -> Dictionary<String, Any> {
        return defaults.dictionaryRepresentation()
    }
    
    public func checkIfPreferenceIsPresent(keyToCheck key: String) -> Bool {
        if settingsAsDictionary().keys.contains(key) {
            return true
        }
        
        return false
    }
    
    public func ensurePreferencesOnLaunch() {
        if !self.checkIfPreferenceIsPresent(keyToCheck: "isFirstLaunch") { defaults.set(true, forKey: "isNotFirstLaunch") }
        if !self.checkIfPreferenceIsPresent(keyToCheck: "enableWatermark") { defaults.set(false, forKey: "enableWatermark") }
        if !self.checkIfPreferenceIsPresent(keyToCheck: "textForWatermark") { defaults.set("Shot with Malachite", forKey: "textForWatermark") }
        if !self.checkIfPreferenceIsPresent(keyToCheck: "shouldUseHDR") { defaults.set(false, forKey: "shouldUseHDR") }
        if !self.checkIfPreferenceIsPresent(keyToCheck: "shouldUseHEIF") { defaults.set(false, forKey: "shouldUseHEIF") }
        if !self.checkIfPreferenceIsPresent(keyToCheck: "shouldUseHEIF10Bit") { defaults.set(false, forKey: "shouldUseHEIF10Bit") }
    }
}
