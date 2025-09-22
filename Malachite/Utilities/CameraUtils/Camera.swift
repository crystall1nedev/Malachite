//
//  Camera.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

import AVFoundation
import Foundation
import Photos

class Camera: NSObject {
    var utilities: MalachiteClassesObject
    
    var bringup: Camera.Bringup!
    var input: Camera.Input!
    var permissions: Camera.Permissions!
    var compatibility: Compatibility!
    
    var session = AVCaptureSession()
    var output = AVCapturePhotoOutput()
    var cameras: [ AVCaptureDevice ]!
    
    var currentDevice: AVCaptureDevice?
    var currentIndex:  Int?
    
    init(
        utilities: MalachiteClassesObject
    ) {
        self.utilities = utilities
        self.permissions = Permissions(utilities: utilities)
        self.compatibility = Compatibility(utilities: utilities)
        super.init()
        
        Task {
            @MainActor in await self.permissions.requestPermissions()
            if self.permissions.cameraGranted {
                setupChildren()
            } else {
                utilities.debugNSLog("[Permissions] Setup skipped due to no camera access.")
            }
            if self.permissions.photosGranted {
                setupPhotoOutput()
            } else {
                utilities.debugNSLog("[Permissions] Setup skipped due to no camera access.")
            }
        }
    }
    
    public func setupChildren() {
        self.bringup       = Bringup(parent: self)
        self.setupCameraArray()
        self.input         = Input(parent: self)
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.cameraClassNotification.name, object: nil)
    }
    
    public func setupCameraArray() { self.cameras = self.bringup.createCameraArray() }
    
    public func setupPhotoOutput() { self.bringup.addPhotoOutput(session: self.session) }
}
