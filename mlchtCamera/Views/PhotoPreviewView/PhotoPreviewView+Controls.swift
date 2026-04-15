//
//  PhotoPreviewView+Controls.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/27/25.
//

import Foundation
import UIKit

extension PhotoPreviewView {
    class ControlLayer: NSObject {
        /// The existing instance of ``PhotoPreviewView`` to act on.
        var delegate = PhotoPreviewView()
        
        init(delegate: PhotoPreviewView) { self.delegate = delegate }
        
        func initButtons() {
            let buttonConstraints: [MalachiteViewUtils.buttonBuilder.constraints] = [
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 150.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
            ]
            
            let buttonConfigs: [MalachiteViewUtils.buttonBuilder] = [
                MalachiteViewUtils.buttonBuilder(symbolName: "xmark", action: #selector(delegate.dismissView), dimensions: [ 60.0 ], constraints: buttonConstraints[0], hidden: false, assign: { [self] button in delegate.dismissButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "photo.on.rectangle", action: #selector(delegate.savePhotoWrapped), dimensions: [ 60.0 ], constraints: buttonConstraints[1], hidden: false, assign: { [self] button in delegate.savePhotoButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "square.and.arrow.up", action: #selector(delegate.sharePhoto), dimensions: [ 60.0 ], constraints: buttonConstraints[2], hidden: false, assign: { [self] button in delegate.sharePhotoButton = button }),
            ]
            
            for config in buttonConfigs {
                let button = delegate.utilities.views.createAndAddButtonToView(symbolName: config.symbolName, delegate: delegate, view: delegate.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions, constraints: config.constraints)
                config.assign(button)
            }
        }
        
        func initRecognizers() {
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            delegate.photoScrollView.addGestureRecognizer(doubleTapRecognizer)
        }
        
        func initTooltips(showLabels: Bool) {
            if showLabels {
                let tooltipConfigs: [ MalachiteViewUtils.tooltipBuilder ] = [
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.close.title", anchor: 10, assign: { [self] label in delegate.dismissTitle = label } ),
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.save.title", anchor: 80, assign: { [self] label in delegate.savePhotoTitle = label } ),
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.share.title", anchor: 150, assign: { [self] label in delegate.sharePhotoTitle = label } ),
                ]
                
                var labels: [ UILabel ] = []
                for config in tooltipConfigs {
                    labels.append(delegate.utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: delegate.view, textForFlow: NSLocalizedString(config.text.localized, comment: ""), anchorConstant: config.anchor))
                }
                
                delegate.utilities.tooltips.fadeOutTooltipFlow(labelsToFade: labels)
            }
        }
        
        func bringUpControlLayer() {
            initButtons()
            initRecognizers()
            initTooltips(showLabels: true)
        }
    }
}

// MARK: ControlLayer - UIScrollViewDelegate
extension PhotoPreviewView.ControlLayer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return delegate.photoImageView
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if delegate.photoScrollView.zoomScale == 1 {
            delegate.photoScrollView.setZoomScale(2, animated: true)
        } else {
            delegate.photoScrollView.setZoomScale(1, animated: true)
        }
    }
}
