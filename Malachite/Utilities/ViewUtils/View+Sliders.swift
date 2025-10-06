//
//  View+Sliders.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 10/2/25.
//

import Foundation
import UIKit

extension MalachiteViewUtils {
    public class Sliders {
        /// Shows and hides slider controllers in the user interface.
        func runHiders(group: sliderGroup) -> Bool {
            let factor = CGFloat(group.sliderShown ? 0 : -220)
            
            UIView.animate(withDuration: 1) {
                group.activator.transform = CGAffineTransform(translationX: factor, y: 0)
                group.container.transform = CGAffineTransform(translationX: factor, y: 0)
            } completion: { _ in
                UIView.animate(withDuration: 0.25) {
                    group.lock.isEnabled = group.sliderShown ? false : true
                    group.lock.alpha = group.sliderShown ? 0.0 : 1.0 
                }
            }
            
            return !group.sliderShown
        }
        
        /// Sets the lock and unlock state of the passed slider lock buttons.
        func runLocks(group: sliderGroup, associatedGestureRecognizer gestureRecognizer: UIGestureRecognizer?, viewForRecognizers view: UIView) -> Bool {
            group.lock.setImage(UIImage(systemName: (group.lockEnabled ? "lock.open" : "lock"))?.withRenderingMode(.alwaysTemplate), for: .normal)
            group.slider.isEnabled = group.lockEnabled ? true : false
            if let validRecognizer = gestureRecognizer {
                if group.lockEnabled { view.addGestureRecognizer(validRecognizer) }
                else { view.removeGestureRecognizer(validRecognizer) }
            }
            
            return !group.lockEnabled
        }
        
        /// Runs functions or returns an alert controller for the passed ``sliderGroup``.
        func runControllers(group: sliderGroup, condition: Bool, action: @escaping () -> Void) -> UIAlertController? {
            if condition && !MalachitePreferencesUtils.shared.preferences.debug.breakApp { action()
            } else {
                return MalachiteViewUtils().createAlertController(title: "alert.title.\(group.name)", message: "alert.detail.\(group.name)", button: group.activator, defaultSet: true, action: { _ in
                    MalachiteClassesObject().debugNSLog("[Alerts] \(group.name) dialog has been dismissed")
                })
            }
            
            return nil
        }
        
        public struct sliderBuilder {
            let action: Selector
            let dimensions: [ CGFloat ]
            let view: UIView
            let assign: (UISlider) -> Void
        }
        
        public struct sliderGroup {
            var name            = String()
            var activator       = UIButton()
            var sliderShown     = Bool()
            var lockEnabled     = Bool()
            var lock            = UIButton()
            var slider          = UISlider()
            var container       = UIButton()
        }
    }
}
