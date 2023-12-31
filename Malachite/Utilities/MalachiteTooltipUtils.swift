//
//  MalachiteTutorialUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

public class MalachiteTooltipUtils : NSObject {
    var cameraTitle = UILabel()
    var flashlightTitle = UILabel()
    var captureTitle = UILabel()
    var focusTitle = UILabel()
    var exposureTitle = UILabel()
    var aboutTitle = UILabel()
    
    var closeOverlayTitle = UILabel()
    var savePhotoTitle = UILabel()
    var sharePhotoTitle = UILabel()
    
    public func tooltipFlow(viewForBounds view: UIView) {
        focusTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "Manual focus", anchorConstant: 10)
        exposureTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "Manual ISO", anchorConstant: 80)
        
        fadeOutTooltipFlow(labelsToFade: [ focusTitle, exposureTitle])
    }
    
    public func capturedTooltipFlow(viewForBounds view: UIView) {
        closeOverlayTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "Exit without saving", anchorConstant: 10)
        savePhotoTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "Save to Photos", anchorConstant: 80)
        sharePhotoTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "Share photo", anchorConstant: 150)
    }
    
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
