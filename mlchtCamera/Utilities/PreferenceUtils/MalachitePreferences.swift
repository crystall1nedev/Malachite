//
//  MalachitePreferences.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/27/24.
//

import Foundation
import AppIntents

struct MalachitePreferences_AppContext: Codable, IntentResult {
    var value: Never?
    
    var preferences: MalachitePreferences
}

struct MalachitePreferences: Codable {
    
    var compatibility:  compatibilityPreferences
    
    struct compatibilityPreferences: Codable {
        var device:     devicePreferences
        var ultrawide:      [ String : Bool ]
        var wideangle:      [ String : Bool ]
        var telephoto:      [ String : Bool ]
        var jpeg:           Bool
        var heic:           Bool
        var raw:            Bool
        var proraw:         Bool
        var hdr:            Bool
        
        struct devicePreferences: Codable {
            var model:         String
            var changed:       Bool
        }
    }
    
    var general:        generalPreferences
    
    struct generalPreferences: Codable {
        var version:               String
        var firstLaunch:           Bool
        var photoCount:            Int
        var gamekit:               gamekitPreferences
        
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
        var fastPath:       Bool
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
        var pinchZoom:              Bool
        var tapAndHold:             [ String ]
        var hiddenControls:         [ String ]
        var idleTimerDisabled:      Bool
        var appLaunch:              Bool
        var hapticFeedback:         Bool
    }
    
    var debug:         debugPreferences
    
    struct debugPreferences: Codable {
        var compatibility:  debug_compatibilityPreferences
        var logging:        debug_loggingPreferences
        var breakApp:       Bool
        
        struct debug_loggingPreferences: Codable {
            var preferences:    Bool
            var unified:        Bool
            var imageProps:     Bool
        }
        
        struct debug_compatibilityPreferences: Codable {
            var forcecheck:     Bool
        }
    }
    
    var evaintrnl:      evaintrnlPreferences
    
    struct evaintrnlPreferences: Codable {
        var blockAccidentalGestures: Bool
        var settingsGesture: Int
        var cameraControlEnabled: Bool
        var cameraControlOptions: [ String ]
        var locationEnabled: Bool
    }
}
