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
    /// An instance of ``MalachiteClassesObject`` for use in this class and its children.
    var utilities: MalachiteClassesObject
    
    /// A DispatchQueue for use in this class, interacting with its objects, and its children.
    var queue = DispatchQueue(label: "malachitekit.camera.sessionqueue")
    
    /// An instance of ``Bringup`` for use in this class.
    var bringup: Camera.Bringup!
    /// An instance of ``Input`` for use in this class.
    var input: Camera.Input!
    /// An instance of ``Permissions`` for use in this class.
    var permissions: Camera.Permissions!
    /// An instance of ``Compatibility`` for use in this class and its children.
    var compatibility: Compatibility!
    
    /**
     MalachiteKit's main capture session.
     
     This object provides the client with an `AVCaptureSession` that serves as the main interface for the application. It is stored
     in this variable for later referencing and usage.
     */
    var session = AVCaptureSession()
    /**
     MalachiteKit's main photo output object.
     
     During initalization of the ``Camera`` class, and after verifying that the application has permissions to use the camera and save
     to the user's library, this object is added to ``session`` and stored for later referencing and usage.
     */
    var output = AVCapturePhotoOutput()
    /**
     An array of `AVCaptureDevice` objects used for camera selection and switching.
     
     During initalization of the ``Camera`` class, and after verifying that the application has permissions to use the camera, this object
     will be populated by ``Bringup/createCameraArray()``.
     */
    var cameras: [ AVCaptureDevice ]!
    
    /**
     The device currently selected for use, or in use, by ``session``.
     
     During camera switching in ``Input/runInputSwitch()``, this variable is set to the `AVCaptureDevice` that MalachiteKit
     switches to. This variable enables the ability to read and write properties on the current camera device.
     
     > Warning: Don't replace the `AVCaptureDevice` object on this variable directly, and let ``Input/runInputSwitch()`` handle that action.
     Modifying this variable directly can lead to changes being lost when the user switches between cameras.
    */
    var device: AVCaptureDevice?
    
    /**
     An integer variable used to store the location of ``device`` in ``cameras``.
     
     This variable helps to keep the Camera Control in sync with ``CameraView/cameraButton``
     > Warning: Don't modify this variable directly, as switching cameras with the Camera Control will overwrite its value.
     */
    var index:  Int?
    
    
    /**
     Initailizer function for the ``Camera`` class.
     
     A quick rundown of the initialization happening in this class:
     - ``utilities`` is set to the ``MalachiteClassesObject`` passed in the initalizer.
     - An instance of the ``Permissions`` class is created to prepare for handling permission requests, and usage inside of children.
     - An instance of the ``Compatibility`` class is created for usage inside of children.
     
     Additionally, the initalizer for the ``Camera`` class has an async task in it:
     - Check and wait for the result of ``Permissions/requestPermissions()``.
     - If camera permissions are granted, run ``Camera/setupChildren()`` to finish bringing up cameras.
     - If photo library permissions are granted, run ``Camera/setupPhotoOutput()`` to finish bringing up the photo output.
     */
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
    
    /**
     Sets up child classes required for MalachiteKit's core functionality.
     
     > Warning: Don't call this function manually, as it's already called when initalizing the ``Camera`` class.
     > Info: To avoid race conditions, you can observe ``MalachiteFunctionUtils/Notifications/cameraClassNotification``
     and run code when a notification is posted to it.
     */
    public func setupChildren() {
        self.bringup       = Bringup(parent: self)
        self.setupCameraArray()
        self.input         = Input(parent: self)
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.cameraClassNotification.name, object: nil)
    }
    
    /// Assigns ``cameras`` to the output value of ``Bringup/createCameraArray()``
    public func setupCameraArray() { self.cameras = self.bringup.createCameraArray() }
    
    /// Assigns ``output`` using ``Bringup/addPhotoOutput(session:)``
    public func setupPhotoOutput() { self.bringup.addPhotoOutput(session: self.session) }
}
