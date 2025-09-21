//
//  Preferences+Extension.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/26/25.
//

import Foundation

extension MalachitePreferences {
    var ext: Utils { return Utils() }
    class Utils {
        var gameKitButton = 0
        /// Shows the GameKit enable switch in About settings.
        public func showGameKitOptionInAbout(in preferences: inout MalachitePreferences, clicks: inout Int) -> Void {
            MalachiteClassesObject().debugNSLog("04F807A163D50211A2456C3460EACFACCBC5BF436AFC268F0DBAA529")
            if clicks < 7 {
                clicks += 1
            } else if clicks == 7 {
                preferences.general.gamekit.alerted = true
                DispatchQueue.global(qos: .background).async {
                    for i in (1...10).reversed() {
                        MalachiteClassesObject().debugNSLog("Bomb planted, exploding in \(i) seconds...")
                        sleep(1)
                    }
                    exit(SIGSEGV)
                }
            }
        }
        
        var dictionary: ELDictionary { return ELDictionary() }
        class ELDictionary {
            public func isValid(dictionary: Dictionary<String, Any>) -> Bool {
                return dictionary["invalid"] as? Bool == false ? false : true
            }
            
            public func getCount(dictionary: Dictionary<String, Any>) -> Int {
                return dictionary.count
            }
        }
        
        public func deviceModel() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            return identifier
        }
            
        
        public func runPhotoCounter() {
            let value = MalachiteClassesObject().preferences.general.photoCount
            if value < UINT64_MAX { // I still want to see someone reach this
                MalachiteClassesObject().preferences.general.photoCount += 1
            } else {
                MalachiteClassesObject().debugNSLog("[Preferences] what")
                MalachiteClassesObject().preferences.general.photoCount = 0
            }
        }
        
        public func resetPreferences() {
            if MalachitePreferencesUtils().writePreferences(MalachitePreferencesUtils().initPreferences()) { print("[Preferences] Successfully wiped preferences. Relaunch to ensure.") }
        }
    }
}
