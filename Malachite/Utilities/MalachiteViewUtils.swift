//
//  MalachiteViewUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import Photos
import UIKit

public class MalachiteViewUtils : NSObject {
    /// Function that returns a buttons for the user interface.
    public func returnProperButton(symbolName name: String, cornerRadius corners: CGFloat, viewForBounds view: UIView, hapticClass haptic: MalachiteHapticUtils?) -> UIButton {
        let button = UIButton()
        let buttonImage = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = corners
        button.bringSubviewToFront(button.imageView!)
        button.imageView?.clipsToBounds = false
        button.imageView?.contentMode = .center
        button.insertSubview(returnProperBlur(viewForBounds: view, blurStyle: .systemThinMaterial), at: 0)
        if haptic != nil {
            button.addTarget(haptic, action: #selector(haptic!.buttonMediumHaptics(_:)), for: .touchUpInside)
        }
        button.isPointerInteractionEnabled = true
        button.pointerStyleProvider = { button, proposedEffect, proposedShape -> UIPointerStyle? in
            let parameters = UIPreviewParameters()
            let shapePath = UIBezierPath(roundedRect: button.bounds, cornerRadius: corners)
            parameters.shadowPath = shapePath
            let preview = UITargetedPreview(view: proposedEffect.preview.view, parameters: parameters, target: proposedEffect.preview.target)
            let rect = button.convert(button.bounds, to: preview.target.container)
            return UIPointerStyle(effect: .lift(preview), shape: .roundedRect(rect, radius: corners))
        }
        
        return button
    }
    
    /// Function that returns blurs for the user interface.
    public func returnProperBlur(viewForBounds view: UIView, blurStyle style: UIBlurEffect.Style) -> UIVisualEffectView {
        let blur = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        
        return blurView
    }
    
    /// Function that returns labels for the user interface.
    public func returnProperLabel(viewForBounds view: UIView, text labelText: String, textColor labelColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = labelText
        label.textColor = labelColor
        
        return label
    }
    
    /// Function that rotates the passed array of buttons based on device orientation
    @objc func rotateButtonsWithOrientation(buttonsToRotate buttons: Array<UIButton>) {
        var rotation = -1.0
        
        if MalachiteClassesObject().idiom == .phone {
            switch UIDevice.current.orientation {
            case .unknown:
                NSLog("[Rotation] How did I get here?")
                rotation = Double.pi * 2
            case .portrait:
                NSLog("[Rotation] Device has rotated portrait, with front camera on the top")
                rotation = Double.pi * 2
            case .portraitUpsideDown:
                NSLog("[Rotation] Device has rotated portrait, with front camera on the bottom")
                rotation = Double.pi
            case .landscapeLeft:
                NSLog("[Rotation] Device has rotated landscape, with front camera on the left")
                rotation = Double.pi / 2
            case .landscapeRight:
                NSLog("[Rotation] Device has rotated landscape, with front camera on the right")
                rotation = -Double.pi / 2
            case .faceUp:
                NSLog("[Rotation] Unneeded rotation, ignoring")
                rotation = Double.pi * 2
            case .faceDown:
                NSLog("[Rotation] Unneeded rotation, ignoring")
                rotation = Double.pi * 2
            @unknown default:
                abort()
            }
        } else {
            rotation = Double.pi * 2
        }
        
        if rotation.isEqual(to: -1.0) { return }
        
        UIView.animate(withDuration: 0.25) {
            for button in buttons {
                button.imageView?.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }
    }
    
    /// Function that shows and hides slider controllers in the user interface.
    func runSliderControllers(sliderIsShown shown: Bool, optionButton option: UIButton, lockButton button: UIButton, associatedSliderButton sliderButton: UIButton) -> Bool {
        var factor = CGFloat()
        if shown {
            factor = 0
        } else {
            factor = -220
        }
        
        UIView.animate(withDuration: 1) {
            option.transform = CGAffineTransform(translationX: factor, y: 0)
            sliderButton.transform = CGAffineTransform(translationX: factor, y: 0)
        } completion: { _ in
            UIView.animate(withDuration: 0.25) {
                if !shown {
                    button.isEnabled = true
                    button.alpha = 1.0
                } else {
                    button.isEnabled = false
                    button.alpha = 0.0
                }
            }
        }
        return !shown
    }
    
    /// Function that sets the lock and unlock state of the bassed slider lock buttons.
    func runLockControllers(lockIsActive locked: Bool, lockButton button: inout UIButton, associatedSlider slider: inout UISlider, associatedGestureRecognizer gestureRecognizer: UIGestureRecognizer?, viewForRecognizers view: UIView) -> Bool {
        if locked {
            button.setImage(UIImage(systemName: "lock.open")?.withRenderingMode(.alwaysTemplate), for: .normal)
            slider.isEnabled = true
            if let validRecognizer = gestureRecognizer { view.addGestureRecognizer(validRecognizer) }
        } else {
            button.setImage(UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate), for: .normal)
            slider.isEnabled = false
            if let validRecognizer = gestureRecognizer { view.removeGestureRecognizer(validRecognizer) }
        }
        
        return !locked
    }
    
    /// Function that presents an image instead of a null ``cameraSession`` for the iOS simulator.
    func returnImageForSimulator() -> UIImage {
        let lobotomized = "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"
        let data = Data(base64Encoded: lobotomized, options: .ignoreUnknownCharacters)
        return UIImage(data: data!)!
    }
}

/// An extension for `UIDeviceOrientation` that properly orients the `cameraSession`
extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}

/// An extension for `UIInterfaceOrientation` that properly orients the `cameraSession`
extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        default: return .portrait
        }
    }
}

/// An extension for `CGImagePropertyOrientation` that properly orients the given `UIImage`.
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

/// An extension for `UIImage` that enables rotating images easily.
extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
