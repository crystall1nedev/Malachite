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
    public func returnProperButton(symbolName name: String, cornerRadius corners: CGFloat, viewForBounds view: UIView, hapticClass haptic: MalachiteHapticUtils) -> UIButton {
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
        button.addTarget(haptic, action: #selector(haptic.buttonMediumHaptics(_:)), for: .touchUpInside)
        
        return button
    }
    
    public func returnProperBlur(viewForBounds view: UIView, blurStyle style: UIBlurEffect.Style) -> UIVisualEffectView {
        let blur = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        
        return blurView
    }
    
    public func returnProperLabel(viewForBounds view: UIView, text labelText: String, textColor labelColor: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = labelText
        label.textColor = labelColor
        
        return label
    }
    
    @objc func rotateButtonsWithOrientation(buttonsToRotate buttons: Array<UIButton>) {
        var rotation = -1.0
        
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
        
        if rotation.isEqual(to: -1.0) { return }
        
        UIView.animate(withDuration: 0.25) {
            for button in buttons {
                button.imageView?.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }
    }
    
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
}

extension UIDeviceOrientation {
    var asCaptureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}

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
