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
    /// An instance of ``MalachiteSettingsUtils
    public var settings = MalachiteSettingsUtils()
    /// A `Bool` that determines whether or not the device supports HDR.
    public var supportsHDR = false
    
    /// An `enum` that contains Notification names.
    public enum Notifications: String, NotificationName {
        case aspectFillNotification
        case exposureLimitNotification
        case stabilizerNotification
        case gameCenterEnabledNotification
        case unsupportedLensPositionControl
        case megaPixelSwitchNotification
    }
    
    /// Function that determines if the device supports HDR.
    public func deviceFormatSupportsHDR(device hdrDevice: AVCaptureDevice) {
        if hdrDevice.activeFormat.isVideoHDRSupported == true {
            MalachiteClassesObject().settings.defaults.set(true, forKey: "compatibility.hdr")
            self.supportsHDR = true
        }
    }
    
    /// Function that determines if the device supports HEIC.
    public func supportsHEIC() -> Bool {
        MalachiteClassesObject().settings.defaults.set(true, forKey: "compatibility.jpeg")
        if supportedImageCaptureTypes.contains("public.heic") {
            MalachiteClassesObject().settings.defaults.set(true, forKey: "compatibility.heif")
            return true
        }
        
        return false
    }
    
    /// Function that handles pinch to zoom.
    public func zoom(sender pinch: UIPinchGestureRecognizer, captureDevice device: inout AVCaptureDevice, lastZoomFactor zoomFactor: inout CGFloat, hapticClass haptic: MalachiteHapticUtils) {
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, 1.0), 5.0), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
                MalachiteClassesObject().debugNSLog("[Pinch to Zoom] Changed zoom factor")
            } catch {
                MalachiteClassesObject().debugNSLog("[Pinch to Zoom] Error changing video zoom factor: \(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)
        
        switch pinch.state {
        case .began:
            haptic.triggerMediumHaptic()
            fallthrough
        case .changed:
            update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
            haptic.triggerMediumHaptic()
        default: break
        }
    }
    
    /// Function that handles autofocus.
    public func autofocus(sender: UILongPressGestureRecognizer, captureDevice device: inout AVCaptureDevice, button: UIButton, viewForScale view: UIView, hapticClass haptic: MalachiteHapticUtils) {
        let focusPoint = sender.location(in: view)
        if sender.state == UIGestureRecognizer.State.began {
            haptic.triggerNotificationHaptic(type: .success)
            view.addSubview(button)
            
            UIView.animate(withDuration: 0.25) {
                button.alpha = 1.0
            }
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 120),
                button.heightAnchor.constraint(equalToConstant: 120),
                button.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: focusPoint.x),
                button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: focusPoint.y),
            ])
        } else if sender.state == UIGestureRecognizer.State.changed {
            button.removeFromSuperview()
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 120),
                button.heightAnchor.constraint(equalToConstant: 120),
                button.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: focusPoint.x),
                button.centerYAnchor.constraint(equalTo: view.topAnchor, constant: focusPoint.y),
            ])
        } else if sender.state == UIGestureRecognizer.State.ended {
            let focusScaledPointX = focusPoint.x / view.frame.size.width
            let focusScaledPointY = focusPoint.y / view.frame.size.height
            if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
                do {
                    try device.lockForConfiguration()
                } catch {
                    print("[Tap to Zoom] Couldn't lock device for configuration: %@", error.localizedDescription)
                    return
                }
                
                device.focusMode = .autoFocus
                device.focusPointOfInterest = CGPointMake(focusScaledPointX, focusScaledPointY)
                
                MalachiteClassesObject().debugNSLog("[Tap to Focus] Changed focus area")
                device.unlockForConfiguration()
            }
            
            UIView.animate(withDuration: 0.25) {
                button.alpha = 0.0
            } completion: { _ in
                button.removeFromSuperview()
            }
        }
    }
    
    /// Function that handles toggling the flashlight's on state.
    public func toggleFlash(captureDevice device: inout AVCaptureDevice, flashlightButton button: inout UIButton) {
        if device.hasTorch {
            var buttonImage = UIImage()
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    MalachiteClassesObject().debugNSLog("[Flashlight] Flash is already on, turning off")
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                } else {
                    do {
                        MalachiteClassesObject().debugNSLog("[Flashlight] Flash is off, turning on")
                        try device.setTorchModeOn(level: 1.0)
                        buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
                    } catch {
                        print(error)
                        buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                    }
                }
                button.setImage(buttonImage, for: .normal)
                device.unlockForConfiguration()
            } catch {
                print(error)
                buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
            }
        }
    }
    
    /// Function that handles connecting and disconnecting cameras, and changing format properties.
    public func switchInput(session: inout AVCaptureSession, cameras: [AVCaptureDevice], device: inout AVCaptureDevice?, output: inout AVCapturePhotoOutput, input: inout AVCaptureDeviceInput?, button: inout UIButton, firstRun: inout Bool){
        button.isUserInteractionEnabled = false
        MalachiteClassesObject().debugNSLog("[Camera Input] Getting ready to configure session")
        session.beginConfiguration()
        
        
        if !firstRun {
            MalachiteClassesObject().debugNSLog("[Camera Input] Removing currently active camera input")
            session.removeInput(input!)
        } else {
            if !cameras.isEmpty { device = cameras.first }
        }
        
        if MalachiteClassesObject().versionType == "INTERNAL" && firstRun {
            for camera in cameras {
                var tmpDictionary = Dictionary<String, Bool>()
                for format in camera.formats {
                    var maxDimensions: CMVideoDimensions
                    if #available (iOS 16.0, *) {
                        maxDimensions = format.supportedMaxPhotoDimensions[format.supportedMaxPhotoDimensions.count - 1]
                    } else {
                        maxDimensions = format.highResolutionStillImageDimensions
                    }
                    if format == camera.formats[0] { MalachiteClassesObject().internalNSLog("[Camera Input] Querying supported modes of \(camera.deviceType.rawValue)") }
                    if maxDimensions.width == 3264 && maxDimensions.height == 2448 { tmpDictionary["8"] = true }
                    if maxDimensions.width == 4032 && maxDimensions.height == 3024 { tmpDictionary["12"] = true }
                    if maxDimensions.width == 8064 && maxDimensions.height == 6048 { tmpDictionary["48"] = true }
                    switch camera.deviceType {
                    case .builtInUltraWideCamera:
                        MalachiteClassesObject().settings.defaults.set(tmpDictionary, forKey: "compatibility.dimensions.ultrawide")
                    case .builtInWideAngleCamera:
                        MalachiteClassesObject().settings.defaults.set(tmpDictionary, forKey: "compatibility.dimensions.wide")
                    case .builtInTelephotoCamera:
                        MalachiteClassesObject().settings.defaults.set(tmpDictionary, forKey: "compatibility.dimensions.telephoto")
                    default:
                        break
                    }
                }
            }
        }
        
        if cameras.count > 1 && !firstRun {
            if let devicePosition = cameras.firstIndex(of: device!) {
                if devicePosition == (cameras.count - 1) {
                    device = cameras[0]
                } else {
                    device = cameras[devicePosition + 1]
                }
            }
        }
        
        firstRun = false
        
        MalachiteClassesObject().debugNSLog("[Camera Input] Attempting to attach device input to session")
        do { input = try AVCaptureDeviceInput(device: device!) }
        catch {
            print(error)
        }
        
        deviceFormatSupportsHDR(device: device!)
        
        do {
            try device?.lockForConfiguration()
            defer { device?.unlockForConfiguration() }
            device?.activeFormat = (device?.formats[(device?.formats.count)! - 1])!
            device?.automaticallyAdjustsVideoHDREnabled = false
            
            guard let focus = device?.isLockingFocusWithCustomLensPositionSupported else { return }
            if !focus { NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.unsupportedLensPositionControl.name, object: nil) }
            
            if settings.defaults.bool(forKey: "capture.hdr.enabled") {
                if self.supportsHDR {
                    MalachiteClassesObject().debugNSLog("[Camera Input] Force enabled HDR on camera")
                    if device?.activeFormat.isVideoHDRSupported == true {
                        device?.isVideoHDREnabled = true
                    } else {
                        MalachiteClassesObject().debugNSLog("[Camera Input] Current capture mode doesn't support HDR, it needs to be disabled")
                        settings.defaults.set(false, forKey: "capture.hdr.enabled")
                    }
                } else {
                    MalachiteClassesObject().debugNSLog("[Camera Input] HDR enabled on a device that doesn't support it")
                    settings.defaults.set(false, forKey: "capture.hdr.enabled")
                }
            }
            
            if !settings.defaults.bool(forKey: "capture.hdr.enabled") {
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
        
        MalachiteClassesObject().debugNSLog("[Camera Input] Attached input, finishing configuration")
        session.addInput(input!)
        if MalachiteClassesObject().versionType == "INTERNAL" {
            switchInputMegapixels(device: device!, photoOutput: output)
        }
        
        session.commitConfiguration()
        button.isUserInteractionEnabled = true
    }
    
    @objc public func switchInputMegapixels(device: AVCaptureDevice, photoOutput: AVCapturePhotoOutput) {
        if #available(iOS 16.0, *) {
            let maxDimensions = device.activeFormat.supportedMaxPhotoDimensions[device.activeFormat.supportedMaxPhotoDimensions.count - 1]
            
            var mpSetting = Int()
            
            switch device.deviceType {
            case .builtInUltraWideCamera:
                mpSetting = MalachiteClassesObject().settings.defaults.integer(forKey: "capture.mp.ultrawide")
            case .builtInWideAngleCamera:
                mpSetting = MalachiteClassesObject().settings.defaults.integer(forKey: "capture.mp.wide")
            case .builtInTelephotoCamera:
                mpSetting = MalachiteClassesObject().settings.defaults.integer(forKey: "capture.mp.telephoto")
            default:
                mpSetting = MalachiteClassesObject().settings.defaults.integer(forKey: "capture.mp.wide")
            }
            
            switch mpSetting {
            case 48:
                MalachiteClassesObject().internalNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 48MP mode")
                if maxDimensions.width == 8064 && maxDimensions.height == 6048 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 8064, height: 6048) }
            case 12:
                MalachiteClassesObject().internalNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 12MP mode")
                if maxDimensions.width == 4032 && maxDimensions.height == 3024 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) }
            default:
                MalachiteClassesObject().internalNSLog("[INTERNAL] Switching \(device.deviceType.rawValue) to 8MP mode")
                if maxDimensions.width == 3264 && maxDimensions.height == 2448 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 3264, height: 2448) }
            }
        }
        
    }
    
    /// Function that handles taking images on `AVCapturePhotoOutput`.
    public func captureImage(output photoOutput: AVCapturePhotoOutput, viewForBounds view: UIView, captureDelegate delegate: AVCapturePhotoCaptureDelegate) -> AVCapturePhotoOutput {
        var format = [String: Any]()
        if settings.defaults.bool(forKey: "capture.type.heif") && supportsHEIC() {
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
    public func manualFocus(captureDevice device: inout AVCaptureDevice, sender: UISlider) {
        let lensPosition = sender.value
        do {
            try device.lockForConfiguration()
        } catch {
            MalachiteClassesObject().debugNSLog("[Manual Focus] Couldn't lock device for configuration: \(error.localizedDescription)")
            return
        }
        
        device.setFocusModeLocked(lensPosition: lensPosition)
        MalachiteClassesObject().debugNSLog("[Manual Focus] Changed lens position")
        device.unlockForConfiguration()
    }
    
    /// Function that handles manual ISO.
    public func manualExposure(captureDevice device: inout AVCaptureDevice, sender: UISlider) {
        let minISO = device.activeFormat.minISO
        print(minISO)
        let maxISO = device.activeFormat.maxISO
        print(maxISO)
        
        var selectedISO = Float()
        if MalachiteSettingsUtils().defaults.bool(forKey: "capture.exposure.unlimited") {
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
        
        print(sender.value)
        print(selectedISO)
        
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
