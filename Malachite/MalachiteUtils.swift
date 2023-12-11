//
//  MalachiteUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/10/23.
//

import AVFoundation
import Foundation
import UIKit

public class MalachiteClassesObject : NSObject {
    public let versions = MalachiteVersion()
    public let haptics  = MalachiteHapticUtils()
    public let views    = MalachiteViewUtils()
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
