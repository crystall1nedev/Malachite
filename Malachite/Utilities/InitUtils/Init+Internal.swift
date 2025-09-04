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
        
        /// Checks whether or not the current device is the same device as previously recorded in preferences.
        public func deviceCheck() {
            if !utilities.preferences.ext.deviceModel.isSameDevice(in: utilities.preferences) {
                utilities.internalNSLog("[Initialization] This is a new device, rechecking compatibility.")
                utilities.preferences.general.deviceModel = utilities.preferences.ext.deviceModel.get()
            } else {
                utilities.internalNSLog("[Initialization] This is the same device, can skip compatibility checks.")
            }
        }
        
        /// Runs all of the initialization functions defined in this class.
        public func initMalachite() {
            deviceCheck()
        }
    }
}
