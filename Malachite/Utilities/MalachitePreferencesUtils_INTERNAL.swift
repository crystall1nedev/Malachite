//
//  MalachitePreferencesUtils_INTERNAL.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/5/24.
//

import Foundation

class MalachitePreferencesUtils_INTERNAL {
    static let shared = MalachitePreferencesUtils_INTERNAL()
    private var _preferences: MalachitePreferences_INTERNAL?
    var preferences: MalachitePreferences_INTERNAL {
        get {
            if _preferences == nil { _preferences = readPreferences() }
            return _preferences!
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
    
    func readPreferences() -> MalachitePreferences_INTERNAL {
        let defaults = initPreferences()
        guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return defaults }
        
        do {
            let data = try Data(contentsOf: url)
            let plist = try PropertyListDecoder().decode(MalachitePreferences_INTERNAL.self, from: data)
            return plist
        } catch {
            print("[Preferences] Error reading plist: \(error.localizedDescription)")
            if writePreferences(defaults) { print("[Preferences] Initialized default preferences")}
            return defaults
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
    
    func initPreferences() -> MalachitePreferences_INTERNAL {
        // oldPreferences + migration will be removed at a later date!
        let oldPreferences = UserDefaults.standard
        return MalachitePreferences_INTERNAL(
            compatibility: MalachitePreferences_INTERNAL.compatibilityPreferences(
                ultrawide: oldPreferences.object(forKey: "compatibility.dimensions.ultrawide") as? [String : Int] ?? [ "" : 0 ],
                wideangle: oldPreferences.object(forKey: "compatibility.dimensions.wideangle") as? [String : Int] ?? [ "" : 0 ],
                telephoto: oldPreferences.object(forKey: "compatibility.dimensions.telephoto") as? [String : Int] ?? [ "" : 0 ],
                jpeg: oldPreferences.object(forKey: "compatibility.jpeg") as? Bool ?? false,
                heic: oldPreferences.object(forKey: "compatibility.heif") as? Bool ?? false,
                raw: false, // Key never existed in the old preferences system
                proraw: false, // Key never existed in the old preferences system
                hdr: oldPreferences.object(forKey: "compatibility.hdr") as? Bool ?? false
            ),
            general: MalachitePreferences_INTERNAL.generalPreferences(
                version: Bundle.main.infoDictionary?["CFBundleVersion"] as! String,
                prefsVersion: 6,
                firstLaunch: oldPreferences.object(forKey: "general.firstLaunch") as? Bool ?? false,
                deviceModel: oldPreferences.object(forKey: "general.device.model") as? String ?? "",
                photoCount: oldPreferences.object(forKey: "general.photos.count") as? Int ?? 0,
                gamekit: MalachitePreferences_INTERNAL.generalPreferences.gamekitPreferences(
                    alerted: oldPreferences.object(forKey: "general.gamekit.alert") as? Bool ?? false,
                    found: oldPreferences.object(forKey: "general.gamekit.found") as? Bool ?? false,
                    enabled: oldPreferences.object(forKey: "general.gamekit.enabled") as? Bool ?? false)
            ),
            preview: MalachitePreferences_INTERNAL.previewPreferences(
                aspect: oldPreferences.object(forKey: "preview.size.fill") as? Bool ?? false,
                stablize: oldPreferences.object(forKey: "preview.stblz.enabled") as? Bool ?? false
            ),
            capture: MalachitePreferences_INTERNAL.capturePreferences(
                unlimitedISO: oldPreferences.object(forKey: "capture.exposure.unlimited") as? Bool ?? false,
                hdr: oldPreferences.object(forKey: "capture.hdr.enabled") as? Bool ?? false,
                format: MalachitePreferences_INTERNAL.capturePreferences.formatPreferences(
                    jpeg: !(oldPreferences.object(forKey: "capture.type.heif") as? Bool ?? false),
                    heic: oldPreferences.object(forKey: "capture.type.heif") as? Bool ?? false,
                    raw: false, // Key never existed in the old preferences system
                    proraw: false // Key never existed in the old preferences system
                ),
                continuous: oldPreferences.object(forKey: "capture.continuous.elements") as? [ String ] ?? [ "" ],
                mp: MalachitePreferences_INTERNAL.capturePreferences.mpPreferences(
                    ultrawide: oldPreferences.object(forKey: "capture.mp.ultrawide") as? Int ?? 0,
                    wideangle: oldPreferences.object(forKey: "capture.mp.wide") as? Int ?? 0,
                    telephoto: oldPreferences.object(forKey: "capture.mp.telephoto") as? Int ?? 0
                ),
                maximumZoom: oldPreferences.object(forKey: "capture.zoom.maximum") as? Int ?? 0
            ),
            watermark: MalachitePreferences_INTERNAL.watermarkPreferences(
                enabled: oldPreferences.object(forKey: "wtrmark.enabled") as? Bool ?? false,
                text: oldPreferences.object(forKey: "wtrmark.text") as? String ?? ""
            ),
            userInterface: MalachitePreferences_INTERNAL.userInterfacePreferences(
                pinchZoom: oldPreferences.object(forKey: "ui.pinchzoom.enabled") as? Bool ?? false,
                tapAndHold: oldPreferences.object(forKey: "ui.tapgesture.elements") as? [ String ] ?? [ "" ],
                hiddenControls: oldPreferences.object(forKey: "ui.hiddengestures.elements") as? [ String ] ?? [ "" ],
                idleTimer: oldPreferences.object(forKey: "ui.idletimer.enabled") as? Bool ?? false,
                appLaunch: oldPreferences.object(forKey: "ui.applaunch.hiddenui") as? Bool ?? false,
                hapticFeedback: oldPreferences.object(forKey: "ui.haptics.enabled") as? Bool ?? false
            ),
            debug: MalachitePreferences_INTERNAL.debugPreferences(
                logging: MalachitePreferences_INTERNAL.debugPreferences.debug_loggingPreferences(
                    preferences: oldPreferences.object(forKey: "debug.logging.userdefaults") as? Bool ?? false
                )
            ),
            evaintrnl: MalachitePreferences_INTERNAL.evaintrnlPreferences(
                settingsGesture: oldPreferences.object(forKey: "ui.settingsgesture.fingers") as? Int ?? 0
            )
        )
    }
}
