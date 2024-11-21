//
//  MalachiteSettingsUtils_INTERNAL.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/5/24.
//

import Foundation

struct MalachitePreferences_INTERNAL: Codable {
    var wideangle: [String: Bool]
}

func getDocumentsDirectory() -> URL? {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    guard let directory = paths.first else { return nil }
    
    return directory
}

func readPreferencesFromPlist() -> MalachitePreferences_INTERNAL? {
    guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return nil }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let myData = try decoder.decode(MalachitePreferences_INTERNAL.self, from: data)
        return myData
    } catch {
        print("[Preferences] Error reading plist: \(error.localizedDescription)")
        return nil
    }
}

func writePreferencesToPlist(_ preferences: MalachitePreferences_INTERNAL) {
    guard let url = getDocumentsDirectory()?.appendingPathComponent("preferences.plist") else { return }
    
    do {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(preferences)
        try data.write(to: url)
    } catch {
        print("[Preferences] Error writing plist: \(error.localizedDescription)")
    }
}
