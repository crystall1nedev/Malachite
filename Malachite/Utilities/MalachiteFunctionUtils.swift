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
    public let supportedImageCaptureTypes = CGImageDestinationCopyTypeIdentifiers() as NSArray
    
    public func zoom(sender pinch: UIPinchGestureRecognizer, captureDevice device: inout AVCaptureDevice, lastZoomFactor zoomFactor: inout CGFloat, hapticClass haptic: MalachiteHapticUtils) {
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, 1.0), 5.0), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
                NSLog("[Pinch to Zoom] Changed zoom factor")
            } catch {
                NSLog("[Pinch to Zoom] Error changing video zoom factor: %@", error.localizedDescription)
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
    
    
    
    public func autofocus(sender: UILongPressGestureRecognizer, captureDevice device: inout AVCaptureDevice, viewForScale view: UIView, hapticClass haptic: MalachiteHapticUtils) {
        if sender.state == UIGestureRecognizer.State.began {
            haptic.triggerNotificationHaptic(type: .success)
        } else if sender.state == UIGestureRecognizer.State.ended {
            let focusPoint = sender.location(in: view)
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
                
                NSLog("[Tap to Focus] Changed focus area")
                device.unlockForConfiguration()
            }
        }
    }
    
    public func toggleFlash(captureDevice device: inout AVCaptureDevice, flashlightButton button: inout UIButton) {
        if device.hasTorch {
            var buttonImage = UIImage()
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    NSLog("[Flashlight] Flash is already on, turning off")
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                } else {
                    do {
                        NSLog("[Flashlight] Flash is off, turning on")
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
    
    public func switchInput(session: inout AVCaptureSession, uwDevice: inout AVCaptureDevice?, waDevice: inout AVCaptureDevice, device: inout AVCaptureDevice?, input: inout AVCaptureDeviceInput?, button: inout UIButton, waInUse: inout Bool, firstRun: inout Bool){
        button.isUserInteractionEnabled = false
        NSLog("[Camera Input] Getting ready to configure session")
        session.beginConfiguration()
        
        if !firstRun {
            NSLog("[Camera Input] Removing currently active camera input")
            session.removeInput(input!)
        } else {
            firstRun = false
        }
        
        if waInUse == true && uwDevice != nil {
            NSLog("[Camera Input] builtInUltraWideCamera is available, selecting as device")
            device = uwDevice!
            waInUse = false
        } else {
            NSLog("[Camera Input] builtInWideAngle is available, selecting as device")
            device = waDevice
            waInUse = true
            
        }
        
        NSLog("[Camera Input] Attempting to attach device input to session")
        do { input = try AVCaptureDeviceInput(device: device!) }
        catch {
            print(error)
        }
        
        do {
                try device?.lockForConfiguration()
                defer { device?.unlockForConfiguration() }
                device?.automaticallyAdjustsVideoHDREnabled = false
                if MalachiteSettingsUtils().defaults.bool(forKey: "shouldUseHDR") {
                    NSLog("[Camera Input] Force enabled HDR on camera")
                    device?.isVideoHDREnabled = true
                } else {
                    NSLog("[Camera Input] Force disabled HDR on camera")
                    device?.isVideoHDREnabled = false
                }
        } catch {
            NSLog("[Camera Input] Error forcing HDR: %@", error.localizedDescription)
        }
        
        NSLog("[Camera Input] Attached input, finishing configuration")
        session.addInput(input!)
        session.commitConfiguration()
        button.isUserInteractionEnabled = true
    }
    
    public func captureImage(output photoOutput: AVCapturePhotoOutput, viewForBounds view: UIView, captureDelegate delegate: AVCapturePhotoCaptureDelegate) -> AVCapturePhotoOutput {
        var format = [String: Any]()
        if MalachiteSettingsUtils().defaults.bool(forKey: "shouldUseHEIC") {
            format = [AVVideoCodecKey : AVVideoCodecType.hevc]
        } else {
            format = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        }
        let photoSettings = AVCapturePhotoSettings(format: format)
        let photoOrientation = UIDevice.current.orientation.asCaptureVideoOrientation
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            if let photoOutputConnection = photoOutput.connection(with: AVMediaType.video) {
                photoOutputConnection.videoOrientation = photoOrientation
            }
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
        
        return photoOutput
    }
    
    public func manualFocus(captureDevice device: inout AVCaptureDevice, sender: UISlider) {
        let lensPosition = sender.value
        do {
            try device.lockForConfiguration()
        } catch {
            NSLog("[Manual Focus] Couldn't lock device for configuration: %@", error.localizedDescription)
            return
        }
        
        device.setFocusModeLocked(lensPosition: lensPosition)
        NSLog("[Manual Focus] Changed lens position")
        device.unlockForConfiguration()
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            abort()
        }
    }
}

extension CIImageRepresentationOption {
    static var hdrGainMapImage: Self { .init(rawValue: "kCIImageRepresentationHDRGainMapImage") }
}
