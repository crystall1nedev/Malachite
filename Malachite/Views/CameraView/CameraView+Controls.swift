//
//  CameraView+Controls.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/26/25.
//

import Foundation
import UIKit

extension CameraView {
    class controls: NSObject {
        /// The existing instance of ``CameraView`` to act on.
        var delegate = CameraView()
        
        init(delegate: CameraView) { self.delegate = delegate }
        
        func initButtons() {
            var lockButtonsX = -80.0
            var lockButtonsY = 0.0
            
            if delegate.view.frame.size.width >= 370 {
                delegate.utilities.debugNSLog("[Initialization] Device screen is capable of displaying lock button inline")
                lockButtonsX = -300.0
            } else {
                // TODO: Make lock buttons not clip into other bars!
                NSLog("[Initialization] Device screen is too small for inline lock button")
                lockButtonsY = 70.0
            }
            
            let buttonConstraints: [MalachiteViewUtils.buttonBuilder.constraints] = [
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: delegate.view.safeAreaLayoutGuide.centerXAnchor, CXC: 0.0, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: lockButtonsX, LXP: false, LYA: delegate.focusButton.topAnchor, LYC: lockButtonsY, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: lockButtonsX, LXP: false, LYA: delegate.exposureButton.topAnchor, LYC: lockButtonsY, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: nil, LYC: nil, LYP: nil, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
            ]
            
            let buttonConfigs: [MalachiteViewUtils.buttonBuilder] = [
                MalachiteViewUtils.buttonBuilder(symbolName: "camera", action: #selector(delegate.runInputSwitch), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[0], assign: { [self] button in delegate.cameraButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "flashlight.off.fill", action: #selector(delegate.runFlashlightToggle), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[1], assign: { [self] button in delegate.flashlightButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "camera.aperture", action: #selector(delegate.runImageCapture), dimensions: [ 45.0, 90.0 ], constraints: buttonConstraints[2], assign: { [self] button in delegate.captureButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "scope", action: #selector(delegate.runManualFocusUIHider), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[3], assign: { [self] button in delegate.focusButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 30.0, 210.0, 60.0 ], constraints: buttonConstraints[4], assign: { [self] button in delegate.focusSliderButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualFocusLockController), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[5], assign: { [self] button in delegate.focusLockButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "plusminus", action: #selector(delegate.runManualExposureUIHider), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[6], assign: { [self] button in delegate.exposureButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 30.0, 210.0, 60.0 ], constraints: buttonConstraints[7], assign: { [self] button in delegate.exposureSliderButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualExposureLockController), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[8], assign: { [self] button in delegate.exposureLockButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "gear", action: #selector(delegate.presentSettingsView), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[9], assign: { [self] button in delegate.settingsButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 30.0, 120.0 ], constraints: buttonConstraints[10], assign: { [self] button in delegate.aeafFeedback = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 30.0, 60.0 ], constraints: buttonConstraints[11], assign: { [self] button in delegate.currentCamera = button }),
            ]
            
            for config in buttonConfigs {
                let button = delegate.utilities.views.createAndAddButtonToView(symbolName: config.symbolName, delegate: delegate, view: delegate.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions, constraints: config.constraints)
                if delegate.utilities.preferences.userInterface.appLaunch { button.alpha = 0.0; delegate.uiIsHidden = true }
                config.assign(button)
            }
        }
        
        func initSliders() {
            let sliderConfigs: [MalachiteViewUtils.sliderBuilder] = [
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualFocusController), dimensions: [ 180.0, 80.0 ], view: delegate.focusSliderButton, assign: { [self] slider in delegate.focusSlider = slider } ),
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualExposureController), dimensions: [ 180.0, 80.0 ], view: delegate.exposureSliderButton, assign: { [self] slider in delegate.exposureSlider = slider } ),
            ]
            
            for config in sliderConfigs {
                config.assign(delegate.utilities.views.createAndAddSliderToView(delegate: delegate, view: config.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions))
            }
        }
        
        func initRecognizers() {
            delegate.zoomRecognizer = UIPinchGestureRecognizer(target: delegate, action:#selector(runZoomController))
            delegate.view.addGestureRecognizer(delegate.zoomRecognizer)
            
            if !delegate.utilities.preferences.userInterface.tapAndHold.contains("off") {
                delegate.aeafRecognizer = UILongPressGestureRecognizer(target: delegate, action: #selector(runaeafController))
                delegate.view.addGestureRecognizer(delegate.aeafRecognizer)
            }
            
            delegate.uiHiderRecognizer = UILongPressGestureRecognizer(target: delegate, action: #selector(runUIHider))
            delegate.uiHiderRecognizer.numberOfTouchesRequired = 2
            delegate.view.addGestureRecognizer(delegate.uiHiderRecognizer)
        }
        
        func initTooltips(showLabels: Bool, showCamera: Bool) {
            if showLabels {
                let tooltipConfigs: [ MalachiteViewUtils.tooltipBuilder ] = [
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.focus.title", anchor: 10, assign: { [self] label in delegate.focusTitle = label } ),
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.exposure.title", anchor: 80, assign: { [self] label in delegate.exposureTitle = label } ),
                ]
                
                var labels: [ UILabel ] = []
                for config in tooltipConfigs {
                    labels.append(delegate.utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: delegate.view, textForFlow: NSLocalizedString(config.text, comment: ""), anchorConstant: config.anchor))
                }
                
                delegate.utilities.tooltips.fadeOutTooltipFlow(labelsToFade: labels)
            }
            
            if showCamera { delegate.utilities.tooltips.zoomTooltipFlow(button: delegate.currentCamera, viewForBounds: delegate.view, camera: delegate.selectedDevice) }
        }
        
        func bringUpControlLayer() {
            initButtons()
            initSliders()
            initRecognizers()
            if !delegate.utilities.preferences.userInterface.appLaunch { initTooltips(showLabels: true, showCamera: true) }
        }
    }
}

