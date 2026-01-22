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
        
        /// Runs all of the initialization functions defined in this class.
        public func initMalachite() {
            isEvaBuild()
        }
    }
}
