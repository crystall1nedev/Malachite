//
//  MalachitePreferencesUtils_INTERNAL.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/5/24.
//

import Foundation

class MalachitePreferencesUtils_INTERNAL {
    static let shared = MalachitePreferencesUtils_INTERNAL()
    var preferences: MalachitePreferences_INTERNAL?
    
    private init() {
        self.preferences = readPreferences()
    }
    
    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let directory = paths.first else { return nil }
        
        return directory
    }
    
    func readPreferences() -> MalachitePreferences_INTERNAL? {
        guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let top = try decoder.decode(MalachitePreferences_INTERNAL.self, from: data)
            return top
        } catch {
            print("Error reading plist: \(error.localizedDescription)")
            let defaults = initDefaultPreferences()
            if writePreferences(defaults) { return defaults }
            return nil
        }
    }
    
    func writePreferences(_ preferences: MalachitePreferences_INTERNAL) -> Bool {
        guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return false }
        
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(preferences)
            try data.write(to: url)
            return true
        } catch {
            print("[Preferences] Error writing plist: \(error.localizedDescription)")
            return false
        }
    }
    
    func printPreferences() {
        guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return }
        do {
            let data = try Data(contentsOf: url)
            if let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                print(dictionary) }
            else {
                print("Failed to convert plist to dictionary.")
            }
        } catch {
            print("Error reading plist: \(error)")
        }
    }
    
    func initDefaultPreferences() -> MalachitePreferences_INTERNAL {
        return MalachitePreferences_INTERNAL(
            compatibility: MalachitePreferences_INTERNAL.compatibilityPreferences(
                ultrawide: [ "" : 0 ],
                wideangle: [ "" : 0 ],
                telephoto: [ "" : 0 ],
                jpeg: false,
                heic: false,
                raw: false,
                proraw: false
            ),
            general: MalachitePreferences_INTERNAL.generalPreferences(
                version: "",
                prefsVersion: 0,
                firstLaunch: false,
                deviceModel: "",
                photoCount: 0,
                gamekit: MalachitePreferences_INTERNAL.generalPreferences.gamekitPreferences(
                    alerted: false,
                    found: false,
                    enabled: false)
            ),
            preview: MalachitePreferences_INTERNAL.previewPreferences(
                aspect: false,
                stablize: false
            ),
            capture: MalachitePreferences_INTERNAL.capturePreferences(
                unlimitedISO: false,
                hdr: false,
                format: MalachitePreferences_INTERNAL.capturePreferences.formatPreferences(
                    jpeg: false,
                    heic: false,
                    raw: false,
                    proraw: false
                ),
                continuous: [ "" ],
                mp: MalachitePreferences_INTERNAL.capturePreferences.mpPreferences(
                    ultrawide: 0,
                    wideangle: 0,
                    telephoto: 0
                ),
                maximumZoom: 0
            ),
            watermark: MalachitePreferences_INTERNAL.watermarkPreferences(
                enabled: false,
                text: ""
            ),
            userInterface: MalachitePreferences_INTERNAL.userInterfacePreferences(
                pinchZoom: false,
                tapAndHold: false,
                hiddenControls: false,
                idleTimer: false,
                appLaunch: false,
                hapticFeedback: false),
            debug: MalachitePreferences_INTERNAL.debugPreferences(
                logging: MalachitePreferences_INTERNAL.debugPreferences.debug_loggingPreferences(
                    preferences: false
                )
            ),
            evaintrnl: MalachitePreferences_INTERNAL.evaintrnlPreferences(
                settingsGesture: 0
            )
        )
    }
    
    struct MalachitePreferences_INTERNAL: Codable {
        var compatibility:  compatibilityPreferences
        
        struct compatibilityPreferences: Codable {
            var ultrawide:      [ String : Int ]
            var wideangle:      [ String : Int ]
            var telephoto:      [ String : Int ]
            var jpeg:           Bool
            var heic:           Bool
            var raw:            Bool
            var proraw:         Bool
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
            var tapAndHold:     Bool
            var hiddenControls: Bool
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
    
}
