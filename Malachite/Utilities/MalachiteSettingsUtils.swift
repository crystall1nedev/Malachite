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
    
    /// A variable that tells Malachite what perferences dictionaries are available.
    public var availablePreferences = [ [ String : Any ] ]()
    
    /// A variable that holds the amount of times the button was clicked.
    public var gameKitButton = 0
    
    /// A dictionary used for general preferences that are not meant to be switched by end users, or miscellanous settings.
    private let generalPreferences: [ String : Any ] = [
        // Records the last version of Malachite to be run on this device, to be used later
        "general.version"            : Bundle.main.infoDictionary?["CFBundleVersion"] as? String as Any,
        // Records the version of preferences that Malachite last saved to. Newer versions = incompatiblities
        "general.prefsVersion"       : 5,
        // Is this the first launch of the app?
        "general.firstLaunch"        : true,
        
        // Whether or not the display has a larger screen area. Used for moving things in the UI.
        "general.display.small"      : false,
        // Whether or not the current device supports 8MP mode.
        "general.supports.8mp"       : false,
        // Whether or not the current device supports 12MP mode.
        "general.supports.12mp"       : false,
        // Whether or not the current device supports 48MP mode.
        "general.supports.48mp"      : false,
        // How many photos has the user taken with Malachite? Used for Game Center achievements.
        "general.photos.count"       : 0,
        // :)
        "general.gamekit.alert"      : false,
        // :) x2
        "general.gamekit.found"      : false,
        // Whether or not to enable Game Center support for Malachite.
        "general.gamekit.enabled"    : false,
    ]
    
    private let previewPreferences: [ String : Any ] = [
        // Whether or not the preview layer should fill the screen
        "preview.size.fill"           : false,
        // Whether or not to enable image preview stabilization
        "preview.stblz.enabled"       : true,
    ]
    
    /// A dictionary used for image capture preferences.
    private let capturePreferences: [ String : Any ] = [
        // Whether or not to enable absurdly bright exposure levels
        "capture.exposure.unlimited"  : false,
        
        // Whether or not HDR should be enabled for captured photos. Not supported on A9.
        "capture.hdr.enabled"         : true,
        
        // Whether or not to save photos as JPEG.
        "capture.type.jpeg"           : false,
        // Whether or not to save photos as HEIF. Not supported on A9.
        "capture.type.heif"           : true,
    ]
    
    /// A dictionary used for watermarking preferences.
    private let watermarkingPreferences: [ String : Any ] = [
        // Whether or not the watermarking feature is enabled
        "wtrmark.enabled"            : true,
        // The text to display over captured images
        "wtrmark.text"               : "Shot with Malachite"
    ]
    
    /// A dictionary used for INTERNAL build preferences.
    private let internalPreferences: [ String: Any ] = [
        // What size to capture photos in
        // Can be "8", "12", "48"
        // 8MP is supported on all devices.
        // 12MP is supported on the following:
        // iPhone 6s and later (including iPhone SE), iPad (10th generation) and later, iPad mini (6th generation) and later, iPad Air (4th generation) and later
        // iPad Pro (9.7-inch), iPad Pro (10.5-inch), or iPad Pro (12.9-inch, 2nd generation) and later
        // 48MP are supported on the following:
        // iPhone 14 Pro, iPhone 14 Pro Max, or iPhone 15 and later (wide angle only)
        // iPhone 16 Pro or iPhone 16 Pro Max (ultra wide and wide angle only)
        "capture.size.mp"            : 12
    ]
    
    /// Counts the number of photos that have been taken.
    public func runPhotoCounter() {
        let value = defaults.integer(forKey: "general.photos.count")
        if value < UINT64_MAX { // I want to see someone reach this
            defaults.set(value + 1, forKey: "general.photos.count")
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
    
    public func getPreferencesDictionariesForBuildType() {
        if MalachiteClassesObject().versionType == "INTERNAL" {
            availablePreferences = [ internalPreferences, generalPreferences, watermarkingPreferences, capturePreferences ]
        } else {
            availablePreferences = [ generalPreferences, watermarkingPreferences, capturePreferences ]
        }
    }
    
    /// Ensures that preferences are synced on launch, and migrates/removes/updates any that are outdated.
    public func ensurePreferences() {
        getPreferencesDictionariesForBuildType()
        if self.defaults.integer(forKey: "general.prefsVersion") != generalPreferences["general.prefsVersion"] as! Int {
            let userPreferences = settingsAsDictionary()
            let tempDictionary = NSMutableDictionary()
            resetAllSettings()
            
            for prefDict in availablePreferences {
                for key in prefDict.keys {
                    tempDictionary[key] = userPreferences.keys.contains(key) && key != "general.prefsVersion" ? userPreferences[key] : prefDict[key]
                }
            }
            
            MalachiteClassesObject().internalNSLog("[Preferences] Dumping all synced keys and saving to UserDefaults")
            for (key, value) in tempDictionary {
                MalachiteClassesObject().internalNSLog("[Preferences] \(key) = \(value)")
                defaults.set(value, forKey: key as! String)
            }
        } else {
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
        getPreferencesDictionariesForBuildType()
        MalachiteClassesObject().internalNSLog("[Preferences] Dumping all UserDefaults keys!!!")
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
            defaults.set(true, forKey: "general.gamekit.alert")
            exit(11)
        }
    }
}
