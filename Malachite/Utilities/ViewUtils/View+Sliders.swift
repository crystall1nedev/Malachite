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
        /// Function that shows and hides slider controllers in the user interface.
        func runControllers(sliderIsShown shown: Bool, optionButton option: UIButton, lockButton button: UIButton, associatedSliderButton sliderButton: UIButton) -> Bool {
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
        func runLocks(lockIsActive locked: Bool, lockButton button: inout UIButton, associatedSlider slider: UISlider, associatedGestureRecognizer gestureRecognizer: UIGestureRecognizer?, viewForRecognizers view: UIView) -> Bool {
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
        
        public struct sliderBuilder {
            let action: Selector
            let dimensions: [ CGFloat ]
            let view: UIView
            let assign: (UISlider) -> Void
        }
        
        public struct sliderGroup {
            var activator       = UIButton()
            var sliderShown     = Bool()
            var lockEnabled     = Bool()
            var lock            = UIButton()
            var slider          = UISlider()
            var container       = UIButton()
        }
    }
}
