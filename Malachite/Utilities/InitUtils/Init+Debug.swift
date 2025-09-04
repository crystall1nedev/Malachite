//
//  Init+Debug.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 9/4/25.
//

extension Init {
    class Debug {
        private var utilities: MalachiteClassesObject
        
        init( utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        /// Prints the contents of preferences.plist at app launch.
        public func printPreferences() {
             if utilities.preferences.debug.logging.preferences { MalachitePreferencesUtils().printPreferences() }
        }
        
        /// Runs all of the initialization functions defined in this class.
        public func initMalachite() {
            printPreferences()
        }
    }
}
