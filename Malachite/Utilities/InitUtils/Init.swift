//
//  Init.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/31/25.
//

import AVFoundation
import Foundation

class Init {
    private var utilities: MalachiteClassesObject
    private var debug: Init.Debug
    private var intrnl: Init.Internal
    
    init( utilities: MalachiteClassesObject ) {
        self.utilities = utilities
        self.debug = Debug(utilities: utilities)
        self.intrnl = Internal(utilities: utilities)
    }
    
    /// Prints a message about Malachite starting.
    public func startupLog() { utilities.debugNSLog("[Initialization] Starting up Malachite") }
    
    /// Prints a message about what build type the current installation of Malachite was compiled with.
    public func versionTypeCheck() {
        if utilities.versionType == "INTERNAL" {
            utilities.internalNSLog("[Initialization] Running an INTERNAL build")
        } else if utilities.versionType == "DEBUG" {
            utilities.debugNSLog("[Initialization] Running a DEBUG build")
        } else if utilities.versionType == "RELEASE" {
            utilities.NSLog("[Initialization] Running a RELEASE build")
        }
    }
    
    /// Checks whether or not Malachite is initializing from the main app or an App Extension.
    public func appExtensionCheck() {
#if APP_EXTENSION
        utilities.debugNSLog("[Initialization] Running out of an app extension.")
#elseif MAIN_APP
        utilities.debugNSLog("[Initialization] Running out of the main app.")
#endif
    }
    
    /// Runs all of the initialization functions defined in this class.
    public func initMalachite() {
        startupLog()
        versionTypeCheck()
        appExtensionCheck()
        
        if utilities.versionType == "DEBUG" || utilities.versionType == "INTERNAL" { debug.initMalachite() }
        if utilities.versionType == "INTERNAL" { intrnl.initMalachite() }
    }
}
