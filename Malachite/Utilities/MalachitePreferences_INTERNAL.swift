//
//  MalachitePreferences_INTERNAL.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/27/24.
//

import Foundation

// TODO: Rename a bunch of these preferences to be more concise in their meaning

struct MalachitePreferences_INTERNAL: Codable {
    var compatibility:  compatibilityPreferences
    
    struct compatibilityPreferences: Codable {
        var ultrawide:      [ String : Bool ]
        var wideangle:      [ String : Bool ]
        var telephoto:      [ String : Bool ]
        var jpeg:           Bool
        var heic:           Bool
        var raw:            Bool
        var proraw:         Bool
        var hdr:            Bool
    }
    
    var general:        generalPreferences
    
    struct generalPreferences: Codable {
        var version:        String
        var prefsVersion:   Int
        var firstLaunch:    Bool
        var deviceModel:    String
        var photoCount:     Int
        var gamekit:        gamekitPreferences
        
        struct gamekitPreferences: Codable {
            var alerted:        Bool
            var found:          Bool
            var enabled:        Bool
        }
    }
    
    var preview:       previewPreferences
    
    struct previewPreferences: Codable {
        var aspect:         Bool
        var stablize:       Bool
    }
    
    var capture:       capturePreferences
    
    struct capturePreferences: Codable {
        var unlimitedISO:    Bool
        var hdr:            Bool
        var format:         formatPreferences
        var continuous:     [ String ]
        var mp:             mpPreferences
        var maximumZoom:     Int
        
        struct formatPreferences: Codable {
            var jpeg:           Bool
            var heic:           Bool
            var raw:            Bool
            var proraw:         Bool
        }
        
        struct mpPreferences: Codable {
            var ultrawide:      Int
            var wideangle:      Int
            var telephoto:      Int
        }
    }
    var watermark:     watermarkPreferences
    
    struct watermarkPreferences: Codable {
        var enabled:        Bool
        var text:           String
        
    }
    var userInterface:  userInterfacePreferences
    
    struct userInterfacePreferences: Codable {
        var pinchZoom:      Bool
        var tapAndHold:     [ String ]
        var hiddenControls: [ String ]
        var idleTimer:      Bool
        var appLaunch:       Bool
        var hapticFeedback:  Bool
    }
    
    var debug:         debugPreferences
    
    struct debugPreferences: Codable {
        var logging:        debug_loggingPreferences
        
        struct debug_loggingPreferences: Codable {
            var preferences:    Bool
        }
    }
    
    var evaintrnl:      evaintrnlPreferences
    
    struct evaintrnlPreferences: Codable {
        var settingsGesture: Int
    }
}

extension MalachitePreferences_INTERNAL {
    public func dictionary_isValid(dictionary: Dictionary<String, Any>) -> Bool {
        return !(dictionary["invalid"] != nil)
    }
    
    public func dictionary_getCount(dictionary: Dictionary<String, Any>) -> Int {
        return dictionary.count
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
    
    public func isSameDevice() -> Bool {
        if getDeviceModel() == general.deviceModel { return true }
        return false
    }
}

