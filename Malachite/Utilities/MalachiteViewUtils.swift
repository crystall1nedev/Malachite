//
//  MalachiteViewUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

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
}
