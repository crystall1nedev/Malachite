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
    
    /// A dictionary used for compatibility checks on the current device.
    private let compatibilityPreferences: [ String : Any ] = [:
    ]
    
    /// A dictionary used for general preferences that are not meant to be switched by end users, or miscellanous settings.
    private let generalPreferences: [ String : Any ] = [
        // Records the last version of Malachite to be run on this device, to be used later
        "general.version"            : Bundle.main.infoDictionary?["CFBundleVersion"] as? String as Any,
        // Records the version of preferences that Malachite last saved to. Newer versions = incompatiblities
        "general.prefsVersion"       : 5,
        // Is this the first launch of the app?
        "general.firstLaunch"        : true,
        
        // Get and save this device's identifier. Used for compabilityPreferences.
        "general.device.model"       : "Eva1,1",
        
        // Whether or not the display has a larger screen area. Used for moving things in the UI.
        "general.display.small"      : false,
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
        
        // Whether or not to enable auto focus and/or auto exposure with the tap and hold gesture.
        "capture.tapgesture.elements" : [ String() ],
        // Whether or not to enable continuous auto focus and/or auto exposure
        "capture.continuous.elements" : [ String() ],
    ]
    
    /// A dictionary used for watermarking preferences.
    private let watermarkingPreferences: [ String : Any ] = [
        // Whether or not the watermarking feature is enabled
        "wtrmark.enabled"            : true,
        // The text to display over captured images
        "wtrmark.text"               : "Shot with Malachite",
    ]
    
    /// A dictionary used for debugging the app
    private let debugPreferences: [ String : Any ] = [:
    ]
    
    /// A dictionary used for INTERNAL build preferences.
    private let internalPreferences: [ String: Any ] = [
        // What size to capture photos in
        // Can be "8", "12", "48"
        // 8MP is supported on all devices.
        // 12MP is supported on the following:
        // iPhone 6s and later (including iPhone SE), iPad (10th generation) and later, iPad mini (6th generation) and later, iPad Air (4th generation) and later
        // iPad Pro (9.7-inch), iPad Pro (10.5-inch), or iPad Pro (12.9-inch, 2nd generation) and later
        // 48MP is supported on the following:
        // iPhone 14 Pro, iPhone 14 Pro Max, or iPhone 15 and later
        "capture.mp.wide"                   : 12,
        // What size to capture photos in
        // Can be "12" or "48"
        // 12MP is supported on all devices.
        // 48MP is supported on the following:
        // iPhone 16 Pro and iPhone 16 Pro Max
        "capture.mp.ultrawide"              : 12,
        // What size to capture photos in
        // Can be "12"
        // 12MP is supported on all devices.
        "capture.mp.telephoto"              : 12,
        
        
        // The list of supported resolutions from the ultrawide camera.
        "compatibility.dimensions.ultrawide"    : [ "invalid" : 1 ],
        // The list of supported resolutions from the wide angle camera.
        "compatibility.dimensions.wide"         : [ "invalid" : 1 ],
        // The list of supported resolutions from the telephoto camera.
        "compatibility.dimensions.telephoto"    : [ "invalid" : 1 ],
        // Whether or not the current device supports JPEG.
        "compatibility.jpeg"                    : false,
        // Whether or not the current device supports HEIF.
        "compatibility.heif"                    : false,
        // Whether or not the current device supports high dynamic range.
        "compatibility.hdr"                     : false,
        
        // Whether or not to dump UserDefaults on launch.
        "debug.logging.userdefaults"           : false,
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
            availablePreferences = [ internalPreferences, compatibilityPreferences, generalPreferences, watermarkingPreferences, capturePreferences ]
        } else {
            availablePreferences = [ compatibilityPreferences, generalPreferences, watermarkingPreferences, capturePreferences ]
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
        MalachiteClassesObject().internalNSLog("[Preferences] Dumping all UserDefaults keys")
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
    
    public func getCountOfDictionary(dictionary: String) -> Int {
        guard let value = self.defaults.dictionary(forKey: dictionary) else { return 0 }
        if (value["invalid"] != nil) { return 0 }
        return value.count
    }
    
    public func getBoolInsideDictionary(dictionary: String, key: String) -> Bool {
        guard let value = self.defaults.dictionary(forKey: dictionary) else { return false }
        return value[key] as? Bool ?? false
    }
    
    public func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
}
