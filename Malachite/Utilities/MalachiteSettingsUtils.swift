//
//  MalachiteSettingsUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//  Assisted by Stella Luna's Battery Webhook code

import Foundation

public class MalachiteSettingsUtils : NSObject {
    public let defaults = UserDefaults.standard
    
    private let internalPreferences: [ String : Any ] = [
        "internal.version"           : "1.0.0",                // Records the last version of Malachite to be run on this device, to be used later
        "internal.prefsVersion"      : 2,                      // Records the version of preferences that Malachite last saved to. Newer versions = incompatiblities
        "internal.firstLaunch"       : true,                   // Is this the first launch of the app?
        
        "internal.display.small"     : false,                  // Whether or not the display has a larger screen area. Used for moving things in the UI.
    ]
    
    private let formatPreferences: [ String : Any ] = [
        "format.preview.fill"        : false,                  // Whether or not the preview layer should fill the screen
        
        "format.hdr.enabled"         : true,                   // Whether or not HDR should be enabled for captured photos. Not supported on A9.
        
        "format.type.jpeg"           : false,                  // Whether or not to save photos as JPEG.
        "format.type.heif"           : true,                   // Whether or not to save photos as HEIF. Not supported on A9.
        "format.type.heif10"         : false,                  // Whether or not to save photos as HEIF 10-bit. Not supported on A9 or iOS 14.
        "format.type.raw"            : false                   // Whether or not to save photos as DNG. Not yet supported in Malachite :(
    ]
    
    private let watermarkingPreferences: [ String : Any ] = [
        "wtrmark.enabled"            : true,                   // Whether or not the watermarking feature is enabled
        "wtrmark.text"               : "Shot with Malachite"   // The text to display over captured images
    ]
    
    private let capturePreferences: [ String : Any ] = [
        "capture.exposure.unlimited" : false,                  // Whether or not to enable absurdly bright exposure levels
        "capture.stblz.enabled"      : true,                   // Whether or not to enable image preview stabilization
    ]
    
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
        if self.defaults.integer(forKey: "internal.prefsVersion") != internalPreferences["internal.prefsVersion"] as! Int {
            let availablePreferences = [ internalPreferences, formatPreferences, watermarkingPreferences, capturePreferences ]
            for prefDict in availablePreferences {
                for key in prefDict.keys {
                    print("[Preferences] Setting default value for key pair:", key, prefDict[key] as Any)
                    if !self.checkIfPreferenceIsPresent(keyToCheck: key) { defaults.set(prefDict[key], forKey: key) }
                }
            }
        } else {
            NSLog("[Preferences] Preferences version matches version includes here")
        }
    }
}
