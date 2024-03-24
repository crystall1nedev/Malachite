//
//  MalachiteTutorialUtils.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 12/11/23.
//

import Foundation
import UIKit

public class MalachiteTooltipUtils : NSObject {
    /// The title for the focus slider.
    var focusTitle = UILabel()
    /// The title for the exposure slider.
    var exposureTitle = UILabel()
    /// The button used to display what camera is in use.
    var currentCamera = UIButton()
    
    /// The title for the dismiss button in ``MalachitePhotoPreview``
    var closeOverlayTitle = UILabel()
    /// The title for the save photo button in ``MalachitePhotoPreview``
    var savePhotoTitle = UILabel()
    /// The title for the share photo button in ``MalachitePhotoPreview``
    var sharePhotoTitle = UILabel()
    
    /// Function used to display text in ``MalachiteView``.
    public func tooltipFlow(viewForBounds view: UIView) {
        focusTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "uibutton.focus.title", anchorConstant: 10)
        exposureTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "uibutton.exposure.title", anchorConstant: 80)
        
        fadeOutTooltipFlow(labelsToFade: [ focusTitle, exposureTitle])
    }
    
    /// Function used to display text in ``MalachitePhotoPreview``.
    public func capturedTooltipFlow(viewForBounds view: UIView) {
        closeOverlayTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "uibutton.close.title", anchorConstant: 10)
        savePhotoTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "uibutton.save.title", anchorConstant: 80)
        sharePhotoTitle = returnLabelForTooltipFlows(viewForBounds: view, textForFlow: "uibutton.share.title", anchorConstant: 150)
    }
    
    /// Function used to display the current camera ("0.5x" or "1x") when switching cameras.
    public func zoomTooltipFlow(viewForBounds view: UIView, waInUse: Bool) {
        currentCamera = MalachiteViewUtils().returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: view, hapticClass: nil)
        currentCamera.isEnabled = false
        if waInUse {
            currentCamera.setTitle("1x", for: .normal)
        } else {
            currentCamera.setTitle("0.5x", for: .normal)
        }
        
        view.addSubview(currentCamera)
        
        NSLayoutConstraint.activate([
            currentCamera.widthAnchor.constraint(equalToConstant: 60),
            currentCamera.heightAnchor.constraint(equalToConstant: 60),
            currentCamera.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            currentCamera.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        ])
        
        fadeOutZoomTooltipFlow()
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
    public func fadeOutZoomTooltipFlow() {
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            UIView.animate(withDuration: 1, animations: { [self] in
                currentCamera.alpha = 0.0
            }, completion: { [self] (finished:Bool) in
                currentCamera.removeFromSuperview()
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
