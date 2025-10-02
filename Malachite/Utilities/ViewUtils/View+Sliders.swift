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
        func runControllers(group: sliderGroup) -> Bool {
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
        
        /// Function that sets the lock and unlock state of the bassed slider lock buttons.
        func runLocks(group: sliderGroup, associatedGestureRecognizer gestureRecognizer: UIGestureRecognizer?, viewForRecognizers view: UIView) -> Bool {
            group.lock.setImage(UIImage(systemName: (group.lockEnabled ? "lock.open" : "lock"))?.withRenderingMode(.alwaysTemplate), for: .normal)
            group.slider.isEnabled = group.lockEnabled ? true : false
            if let validRecognizer = gestureRecognizer {
                if group.lockEnabled { view.addGestureRecognizer(validRecognizer) }
                else { view.removeGestureRecognizer(validRecognizer) }
            }
            
            return !group.lockEnabled
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
