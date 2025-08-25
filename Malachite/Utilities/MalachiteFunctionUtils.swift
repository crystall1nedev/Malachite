//
//  MalachiteFuncUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import AVFoundation
import Foundation
import Photos
import UIKit

public class MalachiteFunctionUtils : NSObject {
    /// An array that returns the available image capture types supported by the camera.
    private let supportedImageCaptureTypes = CGImageDestinationCopyTypeIdentifiers() as NSArray
    /// A `Bool` that determines whether or not the device supports HDR.
    public var supportsHDR = false
    
    /// An `enum` that contains Notification names.
    public enum Notifications: String, NotificationName {
        case aspectFillNotification
        case exposureLimitNotification
        case stabilizerNotification
        case gameCenterEnabledNotification
        case unsupportedISOValueNotification
        case unsupportedLensPositionNotification
        case megaPixelSwitchNotification
        case continousAEAFNotification
        case aeafTapGestureNotification
        case idleTimerNotification
        case settingsGestureNotification
    }
    
    /// Function that determines if the device supports HDR.
    public func deviceFormatSupportsHDR(device hdrDevice: AVCaptureDevice) {
        if hdrDevice.activeFormat.isVideoHDRSupported == true {
            MalachitePreferencesUtils.shared.preferences.compatibility.hdr = true
            self.supportsHDR = true
        }
    }
    
    /// Function that determines if the device supports HEIC.
    public func supportsHEIC() -> Bool {
        MalachitePreferencesUtils.shared.preferences.compatibility.jpeg = true
        if supportedImageCaptureTypes.contains("public.heic") {
            MalachitePreferencesUtils.shared.preferences.compatibility.heic = true
            return true
        }
        
        return false
    }
    
    /// Function that handles pinch to zoom.
    public func zoom(sender pinch: UIPinchGestureRecognizer, floater float: inout CGFloat, captureDevice device: inout AVCaptureDevice, lastZoomFactor zoomFactor: inout CGFloat, hapticClass haptic: MalachiteHapticUtils) {
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, 1.0), CGFloat(MalachitePreferencesUtils.shared.preferences.capture.maximumZoom)), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
                MalachiteClassesObject().debugNSLog("[Zoom] Changed zoom factor")
            } catch {
                MalachiteClassesObject().debugNSLog("[Zoom] Error changing video zoom factor: \(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(float * zoomFactor)
        update(scale: newScaleFactor)
        
        switch pinch.state {
        case .began:
            haptic.triggerMediumHaptic()
            fallthrough
        case .changed:
            let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
            float = minMaxZoom(newScaleFactor)
            update(scale: newScaleFactor)
        case .ended:
            let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
            zoomFactor = minMaxZoom(newScaleFactor)
            float = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
            haptic.triggerMediumHaptic()
        default: break
        }
    }
    
    /// Function that handles autofocus and autoexposure
    public func pointOfInterestAEAF(sender: UILongPressGestureRecognizer, captureDevice device: inout AVCaptureDevice, button: UIButton, viewForScale view: UIView, hapticClass haptic: MalachiteHapticUtils) {
        let point = sender.location(in: view)
        if sender.state == UIGestureRecognizer.State.began {
            haptic.triggerNotificationHaptic(type: .success)
            view.addSubview(button)
            
            UIView.animate(withDuration: 0.25) {
                button.alpha = 1.0
            }
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 120),
                button.heightAnchor.constraint(equalToConstant: 120),
                button.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: point.x),
                button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: point.y),
            ])
        } else if sender.state == UIGestureRecognizer.State.changed {
            button.removeFromSuperview()
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 120),
                button.heightAnchor.constraint(equalToConstant: 120),
                button.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: point.x),
                button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: point.y),
            ])
        } else if sender.state == UIGestureRecognizer.State.ended {
            let scaledPointX = point.x / view.frame.size.width
            let scaledPointY = point.y / view.frame.size.height
            do {
                try device.lockForConfiguration()
            } catch {
                print("[AE+AF] Couldn't lock device for configuration: %@", error.localizedDescription)
                return
            }
            
            let tapGestureElements = MalachitePreferencesUtils.shared.preferences.userInterface.tapAndHold
            
            if tapGestureElements.contains("af") {
                if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = CGPointMake(scaledPointX, scaledPointY)
                    MalachiteClassesObject().debugNSLog("[AE+AF] Changed focus POI")
                }
            }
            if tapGestureElements.contains("ae") {
                if device.isExposureModeSupported(.autoExpose) && device.isExposurePointOfInterestSupported {
                    device.exposureMode = .autoExpose
                    device.exposurePointOfInterest = CGPointMake(scaledPointX, scaledPointY)
                    MalachiteClassesObject().debugNSLog("[AE+AF] Changed exposure POI")
                }
            }
            
            device.unlockForConfiguration()
            
            UIView.animate(withDuration: 0.25) {
                button.alpha = 0.0
            } completion: { _ in
                button.removeFromSuperview()
            }
        }
    }
    
    public func continuousAEAF(device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
        } catch {
            print("[Continuous AE+AF] Couldn't lock device for configuration: %@", error.localizedDescription)
            return
        }
        
        let continuousElements = MalachitePreferencesUtils.shared.preferences.capture.continuous
        
        if continuousElements.contains("ae") && device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
            MalachiteClassesObject().debugNSLog("[Continuous AE+AF] AE Enabled")
        } else if (!continuousElements.contains("ae")) && device.isExposureModeSupported(.locked) {
            device.exposureMode = .locked
            MalachiteClassesObject().debugNSLog("[Continuous AE+AF] AE Disabled")
        }
        if continuousElements.contains("af") && device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
            MalachiteClassesObject().debugNSLog("[Continuous AE+AF] AF Enabled")
        } else if (!continuousElements.contains("af")) && device.isFocusModeSupported(.locked) {
            device.focusMode = .locked
            MalachiteClassesObject().debugNSLog("[Continuous AE+AF] AF Disabled")
        }
        
        device.unlockForConfiguration()
    }
    
    /// Function that handles toggling the flashlight's on state.
    public func toggleFlash(captureDevice device: inout AVCaptureDevice, flashlightButton button: UIButton, floater float: Float?, isFlashOn: inout Bool) {
        if device.hasTorch {
            var buttonImage = UIImage()
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    MalachiteClassesObject().debugNSLog("[Flashlight] Flash is already on, turning off")
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                    isFlashOn = false
                } else {
                    do {
                        MalachiteClassesObject().debugNSLog("[Flashlight] Flash is off, turning on")
                        try device.setTorchModeOn(level: float ?? AVCaptureDevice.maxAvailableTorchLevel)
                        buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
                        isFlashOn = true
                    } catch {
                        print(error)
                        buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                        isFlashOn = false
                    }
                }
                DispatchQueue.main.async() { button.setImage(buttonImage, for: .normal) }
                device.unlockForConfiguration()
            } catch {
                print(error)
                buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
                isFlashOn = false
            }
        }
    }
    
    public func flashLevelTest(captureDevice device: AVCaptureDevice, floater float: Float?) {
        var torchLevel = float ?? AVCaptureDevice.maxAvailableTorchLevel
        if torchLevel >= AVCaptureDevice.maxAvailableTorchLevel { torchLevel = AVCaptureDevice.maxAvailableTorchLevel }
        do {
            try device.lockForConfiguration()
            if device.torchMode == AVCaptureDevice.TorchMode.on {
                do {
                    try device.setTorchModeOn(level: torchLevel)
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    /// Function that handles connecting and disconnecting cameras, and changing format properties.
    public func switchInput(session: inout AVCaptureSession, cameras: [AVCaptureDevice], device: inout AVCaptureDevice?, output: inout AVCapturePhotoOutput, input: inout AVCaptureDeviceInput?, button: UIButton, firstRun: inout Bool){
        MalachiteClassesObject().debugNSLog("[Camera Input] Getting ready to configure session")
        
        if !firstRun {
            MalachiteClassesObject().debugNSLog("[Camera Input] Removing currently active camera input")
            session.removeInput(input!)
        } else {
            if !cameras.isEmpty { device = cameras.first }
        }
        
        if firstRun {
            for camera in cameras {
                var tmpDictionary = Dictionary<String, Bool>()
                for format in camera.formats {
                    var maxDimensions: CMVideoDimensions
                    if #available (iOS 16.0, *) {
                        maxDimensions = format.supportedMaxPhotoDimensions[format.supportedMaxPhotoDimensions.count - 1]
                    } else {
                        maxDimensions = format.highResolutionStillImageDimensions
                    }
                    if format == camera.formats[0] { MalachiteClassesObject().debugNSLog("[Camera Input] Querying supported modes of \(camera.deviceType.rawValue)") }
                    if maxDimensions.width == 3264 && maxDimensions.height == 2448 { tmpDictionary["8"] = true }
                    if maxDimensions.width == 4032 && maxDimensions.height == 3024 { tmpDictionary["12"] = true }
                    if maxDimensions.width == 8064 && maxDimensions.height == 6048 { tmpDictionary["48"] = true }
                    switch camera.deviceType {
                    case .builtInUltraWideCamera:
                        MalachitePreferencesUtils.shared.preferences.compatibility.ultrawide = tmpDictionary
                    case .builtInWideAngleCamera:
                        MalachitePreferencesUtils.shared.preferences.compatibility.wideangle = tmpDictionary
                    case .builtInTelephotoCamera:
                        MalachitePreferencesUtils.shared.preferences.compatibility.telephoto = tmpDictionary
                    default:
                        break
                    }
                }
            }
        }
        
        firstRun = false
        
        deviceFormatSupportsHDR(device: device!)
        
        do {
            try device?.lockForConfiguration()
            defer { device?.unlockForConfiguration() }
            MalachiteClassesObject().debugNSLog("[Camera Input] Selected input: \(String(describing: device?.formats[(device?.formats.count)! - 1]))")
            device?.activeFormat = (device?.formats[(device?.formats.count)! - 1])!
            continuousAEAF(device: device!)
            
            guard let focus = device?.isLockingFocusWithCustomLensPositionSupported else { return }
            if !focus { NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.unsupportedLensPositionNotification.name, object: nil) }
            
            guard let exposure = device?.isExposureModeSupported(.custom) else { return }
            if !exposure { NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.unsupportedISOValueNotification.name, object: nil) }
            
            device?.automaticallyAdjustsVideoHDREnabled = false
            
            if MalachiteClassesObject().preferences.capture.hdr {
                if self.supportsHDR {
                    MalachiteClassesObject().debugNSLog("[Camera Input] Force enabled HDR on camera")
                    if device?.activeFormat.isVideoHDRSupported == true {
                        device?.isVideoHDREnabled = true
                    } else {
                        MalachiteClassesObject().debugNSLog("[Camera Input] Current capture mode doesn't support HDR, it needs to be disabled")
                        MalachiteClassesObject().preferences.capture.hdr = false
                    }
                } else {
                    MalachiteClassesObject().debugNSLog("[Camera Input] HDR enabled on a device that doesn't support it")
                    MalachiteClassesObject().preferences.capture.hdr = false
                }
            } else {
                MalachiteClassesObject().debugNSLog("[Camera Input] Force disabled HDR on camera")
                if device?.activeFormat.isGlobalToneMappingSupported == true {
                    device?.isGlobalToneMappingEnabled = false
                }
                if device?.activeFormat.isVideoHDRSupported == true {
                    device?.isVideoHDREnabled = false
                }
            }
        } catch {
            MalachiteClassesObject().debugNSLog("[Camera Input] Error adjusting device properties: \(error.localizedDescription)")
        }
        
        
        MalachiteClassesObject().debugNSLog("[Camera Input] Attempting to attach device input to session")
        do { input = try AVCaptureDeviceInput(device: device!) }
        catch {
            print(error)
        }
        
        MalachiteClassesObject().debugNSLog("[Camera Input] Attached input, finishing configuration")
        if session.canAddInput(input!) { session.addInput(input!) }
        switchInputMegapixels(device: device!, photoOutput: output)
    }
    
    @available(iOS 18.0, *)
    public func addControlsToSession(session: inout AVCaptureSession, controls: [AVCaptureControl]) {
        guard session.supportsControls else { return }
        
        session.beginConfiguration()
        
        
        for control in session.controls { session.removeControl(control) }
        
        for control in controls {
            if session.canAddControl(control) {
                session.addControl(control)
            } else {
                print("Unable to add control \(control).")
            }
        }
        
        session.commitConfiguration()
    }
    
    @objc public func switchInputMegapixels(device: AVCaptureDevice, photoOutput: AVCapturePhotoOutput) {
        if #available(iOS 16.0, *) {
            let maxDimensions = device.activeFormat.supportedMaxPhotoDimensions[device.activeFormat.supportedMaxPhotoDimensions.count - 1]
            
            var mpSetting = Int()
            
            switch device.deviceType {
            case .builtInUltraWideCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.ultrawide
            case .builtInWideAngleCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.wideangle
            case .builtInTelephotoCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.telephoto
            default:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.wideangle
            }
            
            switch mpSetting {
            case 48:
                MalachiteClassesObject().debugNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 48MP mode")
                if maxDimensions.width == 8064 && maxDimensions.height == 6048 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 8064, height: 6048) }
            case 12:
                MalachiteClassesObject().debugNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 12MP mode")
                if maxDimensions.width == 4032 && maxDimensions.height == 3024 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) }
            default:
                MalachiteClassesObject().debugNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 8MP mode")
                if maxDimensions.width == 3264 && maxDimensions.height == 2448 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 3264, height: 2448) }
            }
        }
        
    }
    
    /// Function that handles taking images on `AVCapturePhotoOutput`.
    public func captureImage(output photoOutput: AVCapturePhotoOutput, viewForBounds view: UIView, captureDelegate delegate: AVCapturePhotoCaptureDelegate) -> AVCapturePhotoOutput {
        var format = [String: Any]()
        if MalachiteClassesObject().preferences.compatibility.heic && supportsHEIC() {
            format = [AVVideoCodecKey : AVVideoCodecType.hevc]
        } else {
            format = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        }
        let photoSettings = AVCapturePhotoSettings(format: format)
        let photoOrientation = UIDevice.current.orientation.videoOrientation
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            if let photoOutputConnection = photoOutput.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = photoOrientation
            }
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoSettings.photoQualityPrioritization = photoOutput.maxPhotoQualityPrioritization
            if #available(iOS 16.0, *) {
                if MalachiteClassesObject().versionType == "INTERNAL" {
                    photoSettings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
                }
            }
            print(photoOutput.availablePhotoFileTypes)
            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
        
        return photoOutput
    }
    
    /// Function that handles manual focus.
    public func manualFocus(captureDevice device: inout AVCaptureDevice, sender: UISlider, floater float: Float) {
        do {
            try device.lockForConfiguration()
        } catch {
            MalachiteClassesObject().debugNSLog("[Manual Focus] Couldn't lock device for configuration: \(error.localizedDescription)")
            return
        }
        
        device.setFocusModeLocked(lensPosition: float)
        MalachiteClassesObject().debugNSLog("[Manual Focus] Changed lens position")
        device.unlockForConfiguration()
    }
    
    /// Function that handles manual ISO.
    public func manualExposure(captureDevice device: inout AVCaptureDevice, sender: UISlider) {
        let minISO = device.activeFormat.minISO
        let maxISO = device.activeFormat.maxISO
        
        var selectedISO = Float()
        if MalachiteClassesObject().preferences.capture.unlimitedISO {
            selectedISO = sender.value * maxISO
        } else {
            if maxISO > 1600 {
                selectedISO = sender.value * 1600
            } else {
                selectedISO = sender.value * maxISO
            }
        }
        
        if selectedISO < minISO {
            selectedISO = minISO
        }
        
        do {
            try device.lockForConfiguration()
            device.setExposureModeCustom(duration:AVCaptureDevice.currentExposureDuration, iso: selectedISO, completionHandler: nil)
            device.unlockForConfiguration()
        } catch let error {
            MalachiteClassesObject().debugNSLog("Could not lock device for configuration: \(error)")
        }
    }
}

/// An extension for `CIImageRepresentationOption` that allows setting gain map images.
extension CIImageRepresentationOption {
    static var hdrGainMapImage: Self { .init(rawValue: "kCIImageRepresentationHDRGainMapImage") }
}

/// A protocol that enables Notification posting and getting.
protocol NotificationName {
    var name: Notification.Name { get }
}

/// An extension that enables Notification posting and getting.
extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

