//
//  MalachitePreferencesUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/5/24.
//

import Foundation

class MalachitePreferencesUtils {
    static let shared = MalachitePreferencesUtils()
    private var _preferences: MalachitePreferences?
    var preferences: MalachitePreferences {
        get {
            if _preferences == nil { _preferences = readPreferences() }
            return _preferences ?? initPreferences()
        }
        
        set { _preferences = newValue }
    }
    
    public init() { }
    
    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let directory = paths.first else { return nil }
        
        return directory
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
    
    func readPreferences() -> MalachitePreferences {
        let defaults = initPreferences()
        guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return defaults }
        
        do {
            let data = try Data(contentsOf: url)
            let plist = try PropertyListDecoder().decode(MalachitePreferences.self, from: data)
            return plist
        } catch {
            print("[Preferences] Error reading plist: \(error.localizedDescription)")
            do {
                let data = try Data(contentsOf: url)
                if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject] {
                    let migrated = migratePreferences(oldPreferences: plist)
                    if writePreferences(migrated) { print("[Preferences] Initialized migrated preferences")}
                    return migrated
                }
            } catch {
                print("[Preferences] Error reading plist: \(error.localizedDescription)")
            }
            
            if writePreferences(defaults) { print("[Preferences] Initialized default preferences")}
            return defaults
        }
    }
    
    func writePreferences(_ preferences: MalachitePreferences) -> Bool {
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
    
    func resetPreferences() {
        if writePreferences(initPreferences()) { print("[Preferences] Successfully wiped preferences. Relaunch to ensure.") }
    }
    
    func migratePreferences(oldPreferences: [ String: AnyObject ]) -> MalachitePreferences {
        var currentPreferences = initPreferences()
        
        if let compatibilityPreferences = oldPreferences["compatibility"] as? [ String: AnyObject ] {
            currentPreferences.compatibility.ultrawide = compatibilityPreferences["ultrawide"] as? [ String: Bool ] ?? [ "invalid" : false]
            currentPreferences.compatibility.wideangle = compatibilityPreferences["wideangle"] as? [ String: Bool ] ?? [ "invalid" : false]
            currentPreferences.compatibility.telephoto = compatibilityPreferences["telephoto"] as? [ String: Bool ] ?? [ "invalid" : false]
            currentPreferences.compatibility.jpeg = compatibilityPreferences["jpeg"] as? Bool ?? false
            currentPreferences.compatibility.heic = compatibilityPreferences["heic"] as? Bool ?? false
            currentPreferences.compatibility.raw = compatibilityPreferences["raw"] as? Bool ?? false
            currentPreferences.compatibility.proraw = compatibilityPreferences["proraw"] as? Bool ?? false
            currentPreferences.compatibility.hdr = compatibilityPreferences["hdr"] as? Bool ?? false
        }
        
        if let generalPreferences = oldPreferences["general"] as? [ String: AnyObject ] {
            currentPreferences.general.firstLaunch = generalPreferences["firstLaunch"] as? Bool ?? false
            currentPreferences.general.deviceModel = generalPreferences["deviceModel"] as? String ?? "Eva1,1"
            currentPreferences.general.photoCount = generalPreferences["photoCount"] as? Int ?? 0
            currentPreferences.general.gamekit.alerted = generalPreferences["gamekit"]?["alerted"] as? Bool ?? false
            currentPreferences.general.gamekit.found = generalPreferences["gamekit"]?["found"] as? Bool ?? false
            currentPreferences.general.gamekit.enabled = generalPreferences["gamekit"]?["enabled"] as? Bool ?? false
        }
        
        if let previewPreferences = oldPreferences["preview"] as? [ String: AnyObject ] {
            currentPreferences.preview.aspect = previewPreferences["aspect"] as? Bool ?? false
            currentPreferences.preview.stablize = previewPreferences["stabilize"] as? Bool ?? false
            currentPreferences.preview.fastPath = true
        }
        
        if let capturePreferences = oldPreferences["capture"] as? [ String: AnyObject ] {
            currentPreferences.capture.unlimitedISO = capturePreferences["unlimitedISO"] as? Bool ?? false
            currentPreferences.capture.hdr = capturePreferences["hdr"] as? Bool ?? false
            currentPreferences.capture.format.jpeg = capturePreferences["format"]?["jpeg"] as? Bool ?? false
            currentPreferences.capture.format.heic = capturePreferences["format"]?["heic"] as? Bool ?? false
            currentPreferences.capture.format.raw = capturePreferences["format"]?["raw"] as? Bool ?? false
            currentPreferences.capture.format.proraw = capturePreferences["format"]?["proraw"] as? Bool ?? false
            currentPreferences.capture.continuous = capturePreferences["continuous"] as? [ String ] ?? [ "off" ]
            currentPreferences.capture.mp.ultrawide = capturePreferences["mp"]?["ultrawide"] as? Int ?? 12
            currentPreferences.capture.mp.wideangle = capturePreferences["mp"]?["wideangle"] as? Int ?? 12
            currentPreferences.capture.mp.telephoto = capturePreferences["mp"]?["telephoto"] as? Int ?? 12
            currentPreferences.capture.maximumZoom = capturePreferences["maximumZoom"] as? Int ?? 5
        }
        
        if let watermarkPreferences = oldPreferences["watermark"] as? [ String: AnyObject ] {
            currentPreferences.watermark.enabled = watermarkPreferences["enabled"] as? Bool ?? false
            currentPreferences.watermark.text = watermarkPreferences["text"] as? String ?? "Shot with Malachite"
        }
        
        if let userInterfacePreferences = oldPreferences["userInterface"] as? [ String: AnyObject ] {
            currentPreferences.userInterface.pinchZoom = userInterfacePreferences["pinchZoom"] as? Bool ?? false
            currentPreferences.userInterface.tapAndHold = userInterfacePreferences["tapAndHold"] as? [ String ] ?? [ "ae", "af" ]
            currentPreferences.userInterface.hiddenControls = userInterfacePreferences["hiddenControls"] as? [ String ] ?? [ "off" ]
            currentPreferences.userInterface.idleTimerDisabled = userInterfacePreferences["idleTimer"] as? Bool ?? false
            currentPreferences.userInterface.appLaunch = userInterfacePreferences["appLaunch"] as? Bool ?? false
            currentPreferences.userInterface.hapticFeedback = userInterfacePreferences["hapticFeedback"] as? Bool ?? false
        }
        
        if let debugPreferences = oldPreferences["debug"] as? [ String: AnyObject ] {
            currentPreferences.debug.logging.preferences = debugPreferences["logging"]?["preferences"] as? Bool ?? false
        }
        
        if let evaintrnlPreferences = oldPreferences["evaintrnl"] as? [ String: AnyObject ] {
            currentPreferences.evaintrnl.settingsGesture = evaintrnlPreferences["settingsGesture"] as? Int ?? 2
        }
        
        return currentPreferences
    }
    
    func initPreferences() -> MalachitePreferences {
        return MalachitePreferences(
            compatibility: MalachitePreferences.compatibilityPreferences(
                ultrawide: [ "invalid" : false ],
                wideangle: [ "invalid" : false ],
                telephoto: [ "invalid" : false ],
                jpeg: false,
                heic: false,
                raw: false,
                proraw: false,
                hdr: false
            ),
            general: MalachitePreferences.generalPreferences(
                version: Bundle.main.infoDictionary?["CFBundleVersion"] as! String,
                prefsVersion: 6,
                firstLaunch: false,
                deviceModel: "Eva1,1",
                photoCount: 0,
                gamekit: MalachitePreferences.generalPreferences.gamekitPreferences(
                    alerted: false,
                    found: false,
                    enabled: false)
            ),
            preview: MalachitePreferences.previewPreferences(
                aspect: false,
                stablize: true,
                fastPath: true
            ),
            capture: MalachitePreferences.capturePreferences(
                unlimitedISO: false,
                hdr: true,
                format: MalachitePreferences.capturePreferences.formatPreferences(
                    jpeg: false,
                    heic: true,
                    raw: false,
                    proraw: false
                ),
                continuous: [ "off" ],
                mp: MalachitePreferences.capturePreferences.mpPreferences(
                    ultrawide: 12,
                    wideangle: 12,
                    telephoto: 12
                ),
                maximumZoom: 5
            ),
            watermark: MalachitePreferences.watermarkPreferences(
                enabled: false,
                text: "Shot with Malachite"
            ),
            userInterface: MalachitePreferences.userInterfacePreferences(
                pinchZoom: true,
                tapAndHold: [ "ae", "af" ],
                hiddenControls: [ "" ],
                idleTimerDisabled: false,
                appLaunch: false,
                hapticFeedback: false
            ),
            debug: MalachitePreferences.debugPreferences(
                logging: MalachitePreferences.debugPreferences.debug_loggingPreferences(
                    preferences: false
                )
            ),
            evaintrnl: MalachitePreferences.evaintrnlPreferences(
                settingsGesture: 2
            )
        )
    }
}
