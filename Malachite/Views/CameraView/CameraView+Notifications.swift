//
//  CameraView+Notifications.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/29/25.
//

import Foundation
import UIKit

extension CameraView {
    class notifications: NSObject {
        /// The existing instance of ``CameraView`` to act on.
        var delegate = CameraView()
        
        init(delegate: CameraView) { self.delegate = delegate }
        
        func initNotifications() {
            let notificationConfigs: [temputils.notificationBuilder] = [
                temputils.notificationBuilder(delegate: delegate, name: UIDevice.orientationDidChangeNotification, action: #selector(orientationChanged)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, action: #selector(changeAspectFill)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, action: #selector(changeExposureLimit)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, action: #selector(changeStabilizerMode)),
                temputils.notificationBuilder(delegate: delegate.utilities.games, name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, action: #selector(delegate.utilities.games.changeGameCenterEnabled)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.unsupportedISOValueNotification.name, action: #selector(runManualExposureUIHiderWhenUnsupported)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.unsupportedLensPositionNotification.name, action: #selector(runManualFocusUIHiderWhenUnsupported)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, action: #selector(changeContinuousAEAF)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, action: #selector(changeAEAFRecognizer)),
                temputils.notificationBuilder(delegate: delegate.utilities.function, name: MalachiteFunctionUtils.Notifications.idleTimerNotification.name, action: #selector(delegate.utilities.function.changeIdleTimerState)),
                temputils.notificationBuilder(delegate: delegate, name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, action: #selector(runInputMegapixelSwitch)),
            ]
            
            for config in notificationConfigs {
                delegate.utilities.debugNSLog("[Initialization] Setting up notification observer for \(config.name.rawValue) changes")
                NotificationCenter.default.addObserver(config.delegate, selector: config.action, name: config.name, object: nil)
            }
            
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        func bringUpNotifications() {
            initNotifications()
        }
    }
}
