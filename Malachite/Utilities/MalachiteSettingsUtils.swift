//
//  MalachiteSettingsUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//  Assisted by Stella Luna's Battery Webhook code

import Foundation

public class MalachiteSettingsUtils : NSObject {
    /// A variable that initializes the standard UserDefaults for Malachite.
    public let defaults = UserDefaults.standard
    
    /// A variable that holds the amount of times the button was clicked.
    public var gameKitButton = 0
    
    /// A dictionary used for internal preferences that are not meant to be switched by end users, or miscellanous settings.
    private let internalPreferences: [ String : Any ] = [
        "internal.version"           : "1.0.0",                // Records the last version of Malachite to be run on this device, to be used later
        "internal.prefsVersion"      : 4,                      // Records the version of preferences that Malachite last saved to. Newer versions = incompatiblities
        "internal.firstLaunch"       : true,                   // Is this the first launch of the app?
        
        "internal.display.small"     : false,                  // Whether or not the display has a larger screen area. Used for moving things in the UI.
        "internal.photos.count"      : 0,                      // How many photos has the user taken with Malachite? Used for Game Center achievements.
        "internal.gamekit.alert"     : false,                  // :)
        "internal.gamekit.found"     : false,                  // :) x2
        "internal.gamekit.enabled"   : false,                  // Whether or not to enable Game Center support for Malachite.
    ]
    
    /// A dictionary used for image format preferences.
    private let formatPreferences: [ String : Any ] = [
        "format.preview.fill"        : false,                  // Whether or not the preview layer should fill the screen
        
        "format.hdr.enabled"         : true,                   // Whether or not HDR should be enabled for captured photos. Not supported on A9.
        
        "format.type.jpeg"           : false,                  // Whether or not to save photos as JPEG.
        "format.type.heif"           : true,                   // Whether or not to save photos as HEIF. Not supported on A9.
    ]
    
    /// A dictionary used for image capture preferences.
    private let capturePreferences: [ String : Any ] = [
        "capture.exposure.unlimited" : false,                  // Whether or not to enable absurdly bright exposure levels
        "capture.stblz.enabled"      : true,                   // Whether or not to enable image preview stabilization
    ]
    
    /// A dictionary used for watermarking preferences.
    private let watermarkingPreferences: [ String : Any ] = [
        "wtrmark.enabled"            : true,                   // Whether or not the watermarking feature is enabled
        "wtrmark.text"               : "Shot with Malachite"   // The text to display over captured images
    ]
    
    /**
     */
    public func runPhotoCounter() {
        let value = defaults.integer(forKey: "internal.photos.count")
        if value < UINT64_MAX { // I want to see someone reach this
            defaults.set(value + 1, forKey: "internal.photos.count")
        } else {
            MalachiteClassesObject().debugNSLog("[Preferences] what")
        }
    }
    
    /// Resets ``defaults``.
    public func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
    
    /// Returns ``defaults`` as a Dictionary object.
    public func settingsAsDictionary() -> Dictionary<String, Any> {
        return defaults.dictionaryRepresentation()
    }
    
    /// Checks if the preference passed is present in ``defaults``.
    public func checkIfPreferenceIsPresent(keyToCheck key: String) -> Bool {
        if settingsAsDictionary().keys.contains(key) {
            return true
        }
        
        return false
    }
    
    /// Ensures that preferences are synced on launch, and migrates/removes/updates any that are outdated.
    public func ensurePreferences() {
        if self.defaults.integer(forKey: "internal.prefsVersion") != internalPreferences["internal.prefsVersion"] as! Int {
            let availablePreferences = [ internalPreferences, formatPreferences, watermarkingPreferences, capturePreferences ]
            let userPreferences = settingsAsDictionary()
            let tempDictionary = NSMutableDictionary()
            resetAllSettings()
            
            for prefDict in availablePreferences {
                for key in prefDict.keys {
                    tempDictionary[key] = userPreferences.keys.contains(key) && key != "internal.prefsVersion" ? userPreferences[key] : prefDict[key]
                }
            }
            
            MalachiteClassesObject().internalNSLog("[Preferences] Dumping all synced keys and saving to UserDefaults")
            for (key, value) in tempDictionary {
                MalachiteClassesObject().internalNSLog("[Preferences] \(key) = \(value)")
                defaults.set(value, forKey: key as! String)
            }
        } else {
            let availablePreferences = [ internalPreferences, formatPreferences, watermarkingPreferences, capturePreferences ]
            for prefDict in availablePreferences {
                for key in prefDict.keys {
                    if !self.checkIfPreferenceIsPresent(keyToCheck: key) {
                        MalachiteClassesObject().debugNSLog("[Preferences] Setting default value for key pair: \(key) = \(String(describing: prefDict[key]))")
                        defaults.set(prefDict[key], forKey: key)
                    }
                }
            }
        }
    }
    
    /// Dumps ``defaults`` to log.
    public func dumpUserDefaults() {
        MalachiteClassesObject().internalNSLog("[Preferences] Dumping all UserDefaults keys!!!")
        let availablePreferences = [ internalPreferences, formatPreferences, watermarkingPreferences, capturePreferences ]
        for (key, value) in settingsAsDictionary() {
            for prefDict in availablePreferences {
                if prefDict.keys.contains(key) {
                    MalachiteClassesObject().internalNSLog("[Preferences] \(key) = \(value)")
                }
            }
        }
    }
    
    /// Shows the GameKit enable switch in About settings.
    @objc public func showGameKitOptionInAbout() -> Void {
        MalachiteClassesObject().debugNSLog("04F807A163D50211A2456C3460EACFACCBC5BF436AFC268F0DBAA529")
        if gameKitButton < 7 {
            gameKitButton += 1
        } else {
            defaults.set(true, forKey: "internal.gamekit.alert")
            exit(11)
        }
    }
}
