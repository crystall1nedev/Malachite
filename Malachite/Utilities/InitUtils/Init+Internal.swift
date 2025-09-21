//
//  Init+Internal.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 9/4/25.
//

extension Init {
    class Internal {
        private var utilities: MalachiteClassesObject
        
        init( utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        /// Checks whether or not to print a small message about subscribing to Eva's Patreon in the logs.
        public func isEvaBuild() {
            if utilities.versionUser == "evaluna" || utilities.versionHost == "Xcode Cloud" { return }
            utilities.internalNSLog("[Initialization] plz subscribe to patreon: https://patreon.com/crystall1nedev")
        }
        
        /// Checks whether or not the current device is the same device as previously recorded in preferences.
        public func isSameDevice() {
            if utilities.preferences.general.deviceModelHasChanged { utilities.preferences.general.deviceModelHasChanged = false }
            if utilities.preferences.general.deviceModel == utilities.preferences.ext.deviceModel() {
                utilities.internalNSLog("[Initialization] This is the same device, can skip compatibility checks.")
                return
            }
            
            utilities.internalNSLog("[Initialization] This is a new device, rechecking compatibility.")
            utilities.preferences.general.deviceModel = utilities.preferences.ext.deviceModel()
            utilities.preferences.general.deviceModelHasChanged = true
        }
        
        /// Runs all of the initialization functions defined in this class.
        public func initMalachite() {
            isEvaBuild()
            isSameDevice()
        }
    }
}
