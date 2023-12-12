//
//  MalachiteHapticUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

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
