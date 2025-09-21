//
//  Camera.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

import AVFoundation
import Foundation

class Camera: NSObject {
    var utilities: MalachiteClassesObject
    
    var bringup: Camera.Bringup!
    var input: Camera.Input!
    var compatibility: Compatibility!
    
    var session: AVCaptureSession!
    var output: AVCapturePhotoOutput!
    var cameras: [ AVCaptureDevice ]!
    
    var currentDevice: AVCaptureDevice?
    var currentIndex:  Int?
    
    var cameraGranted = false
    var photosGranted = false
    
    init(
        utilities: MalachiteClassesObject
    ) {
        self.utilities = utilities
        super.init()
        setupChildClasses()
        setupSession()
        setupPhotoOutput()
    }
    
    public func setupChildClasses() {
        self.bringup       = Bringup(parent: self)
        self.setupCameraArray()
        self.input         = Input(parent: self)
        self.compatibility = Compatibility(utilities: utilities)
    }
    
    public func setupCameraArray() { self.cameras = self.bringup.createCameraArray() }
    
    public func setupSession() { self.session = self.bringup.createAVCaptureSession(session: self.session) }
    
    public func setupPhotoOutput() {
        self.output = self.bringup.createAndAddPhotoOutput(photoOutput: output, session: self.session)
    }
}
