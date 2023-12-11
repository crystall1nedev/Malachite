//
//  MalachiteUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/10/23.
//

import AVFoundation
import Foundation
import Photos
import UIKit

public class MalachiteClassesObject : NSObject {
    public let versions  = MalachiteVersion()
    public let haptics   = MalachiteHapticUtils()
    public let views     = MalachiteViewUtils()
    public let function  = MalachiteFuncUtils()
}

public class MalachiteVersion : NSObject {
    public let versionMajor = "1"
    public let versionMinor = "0"
    public let versionFixer = "0"
    public let versionBeta  = true
}

public class MalachiteHapticUtils : NSObject {
    let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    let notificationHaptic = UINotificationFeedbackGenerator()
    
    public func triggerLightHaptic() { lightHaptic.impactOccurred() }
    public func triggerMediumHaptic() { mediumHaptic.impactOccurred() }
    public func triggerHeavyHaptic() { heavyHaptic.impactOccurred() }
    
    @objc public func buttonLightHaptics(_ sender: Any) { triggerLightHaptic() }
    @objc public func buttonMediumHaptics(_ sender: Any) { triggerMediumHaptic() }
    @objc public func buttonHeavyHaptics(_ sender: Any) { triggerHeavyHaptic() }
    
    public func triggerNotificationHaptic(type feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        notificationHaptic.notificationOccurred(feedbackType)
    }
}

public class MalachiteViewUtils : NSObject {
    public func returnProperButton(symbolName name: String, viewForBounds view: UIView, hapticClass haptic: MalachiteHapticUtils) -> UIButton {
        let button = UIButton()
        let buttonImage = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        button.bringSubviewToFront(button.imageView!)
        button.insertSubview(returnProperBlur(viewForBounds: view), at: 0)
        button.addTarget(haptic, action: #selector(haptic.buttonMediumHaptics(_:)), for: .touchUpInside)
        return button
    }
    
    public func returnProperBlur(viewForBounds view: UIView) -> UIVisualEffectView {
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        return blurView
    }
}

public class MalachiteFuncUtils : NSObject {
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
        case .changed: update(scale: newScaleFactor)
        case .ended:
            zoomFactor = minMaxZoom(newScaleFactor)
            update(scale: zoomFactor)
            haptic.triggerMediumHaptic()
        default: break
        }
    }
    
    
    
    public func autofocus(sender: UILongPressGestureRecognizer, captureDevice device: inout AVCaptureDevice, viewForScale view: UIView, hapticClass haptic: MalachiteHapticUtils) {
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
            haptic.triggerNotificationHaptic(type: .success)
            NSLog("[Tap to Focus] Changed focus area")
            device.unlockForConfiguration()
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
        
        NSLog("[Camera Input] Attached input, finishing configuration")
        session.addInput(input!)
        session.commitConfiguration()
        button.isUserInteractionEnabled = true
    }
    
    @objc public func captureImage(output photoOutput: AVCapturePhotoOutput, viewForBounds view: UIView, captureDelegate delegate: AVCapturePhotoCaptureDelegate) -> AVCapturePhotoOutput {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
        
        return photoOutput
    }
}
