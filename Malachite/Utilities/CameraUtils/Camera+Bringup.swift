//
//  Camera+Bringup.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/30/25.
//

import AVFoundation
import Foundation
import Photos

extension Camera {
    class Bringup {
        private var parent: Camera
        
        init( parent: Camera ) { self.parent = parent }
        
        /**
         Returns an array of ``AVCaptureDevice`` objects to use when attaching cameras to Malachite's ``AVCaptureSession``.
         */
        func createCameraArray() -> [AVCaptureDevice] {
            if !parent.permissions.cameraGranted { return [] }
            parent.utilities.debugNSLog("[Camera Initialization] Discovering available cameras")
            var camerasToDiscover: [AVCaptureDevice.DeviceType] = []
            var camerasFound: [AVCaptureDevice] = []
            if #available(iOS 17.0, *) { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera ] }
            else { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera] }
            
            let currentProcess = ProcessInfo()
            AVCaptureDevice.DiscoverySession.init(deviceTypes: camerasToDiscover, mediaType: .video, position: (currentProcess.isiOSAppOnMac || currentProcess.isMacCatalystApp) ? .unspecified : .back).devices.forEach { device in
                if parent.utilities.preferences.general.deviceModelHasChanged { parent.compatibility.checkCameraCapabilities(device: device) }
                camerasFound.append(device)
                parent.utilities.debugNSLog("[Camera Initialization] \(device.deviceType.rawValue) available")
            }
            
            return camerasFound
        }
        
        /**
         Returns an ``AVCapturePhotoOutput`` object to use when taking a photo with Malachite's ``AVCaptureSession``.
         */
        func addPhotoOutput(session: AVCaptureSession) {
            if !parent.permissions.photosGranted { return }
            if !session.outputs.contains(parent.output) {
                parent.utilities.debugNSLog("[Camera Initialization] Running AVCapturePhotoOutput initialization steps")
                if #unavailable(iOS 16.0) { parent.output.isHighResolutionCaptureEnabled = true }
                parent.output.maxPhotoQualityPrioritization = .quality
                session.sessionPreset = AVCaptureSession.Preset.photo
                session.addOutput(parent.output)
            } else {
                parent.utilities.debugNSLog("[Camera Initialization] AVCapturePhotoOutput already initialized, continuing")
            }
        }
    }
}

