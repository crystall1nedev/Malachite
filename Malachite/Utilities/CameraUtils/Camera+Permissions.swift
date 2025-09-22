//
//  Camera+Permissions.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 9/21/25.
//

import AVFoundation
import Foundation
import Photos

extension Camera {
    class Permissions {
        private var utilities: MalachiteClassesObject
        
        init( utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        var cameraGranted = false
        var photosGranted = false
        
        /// Requests camera and photo library permissions and updates ``cameraGranted`` and ``photosGranted``
        @MainActor
        func requestPermissions() async {
            let cameraOK = await self.createRequestToUseCamera()
            self.cameraGranted = cameraOK

            let photosOK = await self.createRequestToAddPhotos()
            self.photosGranted = photosOK

            utilities.debugNSLog("[Camera Permissions] Results — camera=\(cameraOK), photos(add-only)=\(photosOK)")
        }
        
        /**
         Requests the ability to use the camera.
         */
        func createRequestToUseCamera() async -> Bool {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                utilities.debugNSLog("[Camera Permissions] Camera access requested: granted=\(granted)")
                return granted
            case .authorized:
                utilities.debugNSLog("[Camera Permissions] Camera access already authorized")
                return true
            case .restricted, .denied:
                utilities.debugNSLog("[Camera Permissions] Camera access restricted/denied")
                return false
            @unknown default:
                utilities.debugNSLog("[Camera Permissions] Camera access unknown status: \(status.rawValue)")
                return false
            }
        }
        
        /**
         Requests the ability to add photos to the user's library.
         */
        func createRequestToAddPhotos() async -> Bool {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .notDetermined:
                let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                let granted = (newStatus == .authorized)
                utilities.debugNSLog("[Camera Permissions] Photo library (add-only) requested: granted=\(granted)")
                return granted
            case .authorized:
                utilities.debugNSLog("[Camera Permissions] Photo library (add-only) already authorized")
                return true
            case .limited:
                utilities.debugNSLog("[Camera Permissions] Photo library (add-only) limited — treating as not granted")
                return false
            case .denied, .restricted:
                utilities.debugNSLog("[Camera Permissions] Photo library (add-only) restricted/denied")
                return false
            @unknown default:
                utilities.debugNSLog("[Camera Permissions] Photo library (add-only) unknown status: \(status.rawValue)")
                return false
            }
        }
    }
}
