//
//  Camera+Bringup.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/30/25.
//

import AVFoundation
import Foundation

extension Camera {
    class Bringup {
        private var utilities: MalachiteClassesObject
        
        init( utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        func checkForHEICCompatibility() {
            if !utilities.function.supportsHEIC() {
                utilities.debugNSLog("[Initialization] HEIF enabled on a device that doesn't support it, disabling")
                utilities.preferences.capture.format.heic = false
                utilities.preferences.capture.format.jpeg = true
            }
        }
        
        func createAVCaptureSession(session: AVCaptureSession?) -> AVCaptureSession {
            guard let session = session else { return AVCaptureSession() }
            return session
        }
    }
}
