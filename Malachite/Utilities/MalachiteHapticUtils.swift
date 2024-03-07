//
//  MalachiteHapticUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

public class MalachiteHapticUtils : NSObject {
    /// A function that triggers a light haptic generator.
    public func triggerLightHaptic() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    /// A function that triggers a medium haptic generator.
    public func triggerMediumHaptic() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    /// A function that triggers a heavy haptic generator.
    public func triggerHeavyHaptic() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    
    /// An Objective-C selector that wraps ``triggerLightHaptic()``
    @objc public func buttonLightHaptics(_ sender: Any) { triggerLightHaptic() }
    /// An Objective-C selector that wraps ``triggerMediumHaptic()``
    @objc public func buttonMediumHaptics(_ sender: Any) { triggerMediumHaptic() }
    /// An Objective-C selector that wraps ``triggerHeavyHaptic()``
    @objc public func buttonHeavyHaptics(_ sender: Any) { triggerHeavyHaptic() }
    
    /// A function that triggers a notification haptic based on the passed type.
    public func triggerNotificationHaptic(type feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
