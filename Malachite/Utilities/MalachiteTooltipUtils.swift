//
//  MalachiteTutorialUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import AVFoundation
import UIKit

public class MalachiteTooltipUtils : NSObject {
    
    /// Function used to display the current camera ("0.5x" or "1x") when switching cameras.
    public func zoomTooltipFlow(button: UIButton, viewForBounds view: UIView, camera: AVCaptureDevice?) {
        button.isEnabled = false
        button.alpha = 1.0
        if camera == nil { return }
        
        switch camera?.deviceType {
        case .builtInUltraWideCamera:
            button.setTitle("UW", for: .normal)
        case .builtInWideAngleCamera:
            button.setTitle("W", for: .normal)
        case .builtInTelephotoCamera:
            button.setTitle("T", for: .normal)
        default:
            button.setTitle("", for: .normal)
        }
        
        fadeOutZoomTooltipFlow(button: button)
    }
    
    /// Function used to fade out ``tooltipFlow(viewForBounds:)
    public func fadeOutTooltipFlow(labelsToFade labels: Array<UILabel>) {
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            for label in labels {
                UIView.animate(withDuration: 1, animations: {
                    label.alpha = 0.0
                }, completion: { (finished:Bool) in
                    label.removeFromSuperview()
                })
            }
        }
    }
    
    /// Function used to fade out ``zoomTooltipFlow(viewForBounds:waInUse:)``.
    public func fadeOutZoomTooltipFlow(button: UIButton) {
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 1, animations: {
                button.alpha = 0.0
            }, completion: { _ in
            })
        }
        
    }
    
    /// Function used to return the proper labels for any tooltip flows that require it.
    public func returnLabelForTooltipFlows(viewForBounds view: UIView, textForFlow text: String, anchorConstant y: CGFloat) -> UILabel {
        let label = MalachiteViewUtils().returnProperLabel(viewForBounds: view, text: text, textColor: .white)
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(label)
        
        if y > 0 {
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 180),
                label.heightAnchor.constraint(equalToConstant: 60),
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: y),
                label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            ])
        } else {
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 180),
                label.heightAnchor.constraint(equalToConstant: 60),
                label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: y),
                label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),
            ])
        }
        return label
    }
}
