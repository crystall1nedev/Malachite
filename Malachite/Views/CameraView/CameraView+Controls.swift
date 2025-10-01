//
//  CameraView+Controls.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/26/25.
//

import Foundation
import AVFoundation
import AVKit
import UIKit

// MARK: ControlLayer - Main
extension CameraView {
    class ControlLayer: NSObject, AVCaptureSessionControlsDelegate {
        /**
         The existing instance of ``CameraView`` to act on.
         */
        var delegate = CameraView()
        
        init(delegate: CameraView) { self.delegate = delegate }
        
        /**
         An array of ``UIGestureRecognizer`` objects that are managed by this control layer.
         */
        var recognizers = [ UIGestureRecognizer ]()
        /**
         The ``AVCaptureEventInteraction`` that catches volume button and Camera Control events for taking photos.
         */
        var eventInteraction: Any? = { if #available(iOS 17.2, *) { return AVCaptureEventInteraction?.self } else { return nil } }()
        
        /**
         Creates, adds, and constrains the ``UIButton`` objects that are managed by this control layer.
         */
        func initButtons() {
            var lockButtonsX = -80.0
            var lockButtonsY = 0.0
            
            if delegate.view.frame.size.width >= 370 {
                delegate.utilities.debugNSLog("[Initialization] Device screen is capable of displaying lock button inline")
                lockButtonsX = -300.0
            } else {
                // TODO: Make lock buttons not clip into other bars!
                delegate.utilities.debugNSLog("[Initialization] Device screen is too small for inline lock button")
                lockButtonsY = 70.0
            }
            
            let buttonConstraints: [MalachiteViewUtils.buttonBuilder.constraints] = [
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: delegate.view.safeAreaLayoutGuide.centerXAnchor, CXC: 0.0, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: lockButtonsX, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0 + lockButtonsY, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: lockButtonsX, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0 + lockButtonsY, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: nil, LYC: nil, LYP: nil, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
            ]
            
            let buttonConfigs: [MalachiteViewUtils.buttonBuilder] = [
                MalachiteViewUtils.buttonBuilder(symbolName: "camera", action: #selector(delegate.runInputSwitch), dimensions: [ 60.0 ], constraints: buttonConstraints[0], hidden: false, assign: { [self] button in delegate.cameraButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "flashlight.off.fill", action: #selector(delegate.runFlashlightToggle), dimensions: [ 60.0 ], constraints: buttonConstraints[1], hidden: false, assign: { [self] button in delegate.flashlightButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "camera.aperture", action: #selector(delegate.runImageCapture), dimensions: [ 90.0 ], constraints: buttonConstraints[2], hidden: false, assign: { [self] button in delegate.captureButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "scope", action: #selector(delegate.runManualFocusUIHider), dimensions: [ 60.0 ], constraints: buttonConstraints[3], hidden: false, assign: { [self] button in delegate.focusButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 210.0, 60.0 ], constraints: buttonConstraints[4], hidden: false, assign: { [self] button in delegate.focusSliderButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualFocusLockController), dimensions: [ 60.0 ], constraints: buttonConstraints[5], hidden: true, assign: { [self] button in delegate.focusLockButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "plusminus", action: #selector(delegate.runManualExposureUIHider), dimensions: [ 60.0 ], constraints: buttonConstraints[6], hidden: false, assign: { [self] button in delegate.exposureButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 210.0, 60.0 ], constraints: buttonConstraints[7], hidden: false, assign: { [self] button in delegate.exposureSliderButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualExposureLockController), dimensions: [ 60.0 ], constraints: buttonConstraints[8], hidden: true, assign: { [self] button in delegate.exposureLockButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "gear", action: #selector(delegate.presentSettingsView), dimensions: [ 60.0 ], constraints: buttonConstraints[9], hidden: false, assign: { [self] button in delegate.settingsButton = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 120.0 ], constraints: buttonConstraints[10], hidden: true, assign: { [self] button in delegate.aeafFeedback = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 60.0 ], constraints: buttonConstraints[11], hidden: false, assign: { [self] button in delegate.currentCamera = button }),
            ]
            
            for config in buttonConfigs {
                let button = delegate.utilities.views.createAndAddButtonToView(symbolName: config.symbolName, delegate: delegate, view: delegate.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions, constraints: config.constraints)
                if delegate.utilities.preferences.userInterface.appLaunch { button.alpha = 0.0; delegate.uiIsHidden = true }
                if config.hidden { button.alpha = 0.0 }
                config.assign(button)
            }
        }
        
        /**
         Creates, adds, and constrains the ``UISlider`` objects that are managed by this control layer.
         */
        func initSliders() {
            let sliderConfigs: [MalachiteViewUtils.sliderBuilder] = [
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualFocusController), dimensions: [ 180.0, 80.0 ], view: delegate.focusSliderButton, assign: { [self] slider in delegate.focusSlider = slider } ),
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualExposureController), dimensions: [ 180.0, 80.0 ], view: delegate.exposureSliderButton, assign: { [self] slider in delegate.exposureSlider = slider } ),
            ]
            
            for config in sliderConfigs {
                config.assign(delegate.utilities.views.createAndAddSliderToView(delegate: delegate, view: config.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions))
            }
        }
        
        /**
         Creates and adds the ``UIGestureRecognizer`` objects that are managed by this control layer.
         */
        func initRecognizers() {
            delegate.zoomRecognizer = UIPinchGestureRecognizer(target: delegate, action:#selector(runZoomController))
            delegate.zoomRecognizer.name = "zoom"
            self.recognizers.append(delegate.zoomRecognizer)
            
            if !delegate.utilities.preferences.userInterface.tapAndHold.contains("off") {
                delegate.aeafRecognizer = UILongPressGestureRecognizer(target: delegate, action: #selector(runaeafController))
                delegate.aeafRecognizer.name = "tah"
                self.recognizers.append(delegate.aeafRecognizer)
            }
            
            delegate.uiHiderRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runUIHider))
            delegate.uiHiderRecognizer.numberOfTouchesRequired = 2
            self.recognizers.append(delegate.uiHiderRecognizer)
            
            for recognizer in recognizers {
                recognizer.cancelsTouchesInView = false
                delegate.view.addGestureRecognizer(recognizer)
            }
        }
        
        /**
         Creates, adds, and fades the tooltip flows that are managed by this control layer.
         */
        func initTooltips(showLabels: Bool, showCamera: Bool) {
            if showLabels {
                let tooltipConfigs: [ MalachiteViewUtils.tooltipBuilder ] = [
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.focus.title", anchor: 10, assign: { [self] label in delegate.focusTitle = label } ),
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.exposure.title", anchor: 80, assign: { [self] label in delegate.exposureTitle = label } ),
                ]
                
                var labels: [ UILabel ] = []
                for config in tooltipConfigs {
                    labels.append(delegate.utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: delegate.view, textForFlow: NSLocalizedString(config.text.localized, comment: ""), anchorConstant: config.anchor))
                }
                
                delegate.utilities.tooltips.fadeOutTooltipFlow(labelsToFade: labels)
            }
            
            if delegate.camera.device != nil {
                if showCamera { delegate.utilities.tooltips.zoomTooltipFlow(button: delegate.currentCamera, viewForBounds: delegate.view, camera: delegate.camera.device) }
            }
        }
        
        /**
         Runs all other initialization functions defined in this control layer's class.
         */
        func bringUpControlLayer() {
            initButtons()
            initSliders()
            initRecognizers()
            if !delegate.utilities.preferences.userInterface.appLaunch { initTooltips(showLabels: true, showCamera: true) }
            if #available(iOS 17.2, *) { initEventInteraction() }
        }
    }
}

// MARK: ControlLayer - Camera Control
@available(iOS 18.0, *)
extension CameraView.ControlLayer {
    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        if !delegate.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
        if !delegate.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
        if delegate.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        if delegate.uiIsHidden { runUIHider() }
        if delegate.camera.index != nil {
            delegate.runInputSwitch()
            delegate.camera.index = nil
        }
    }
    
    func initCameraControl() {
        guard delegate.camera.session.supportsControls else { return }
        var controls: [ AVCaptureControl ] = []
        
#warning("malachitekit should properly sync this with the zoom slider")
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("zoom") {
            let zoomSlider = AVCaptureSlider("Zoom", symbolName: "plus.viewfinder", in: 1.0...Float(MalachiteClassesObject().preferences.capture.maximumZoom))
            zoomSlider.prominentValues = [ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0 ]
            zoomSlider.setActionQueue(delegate.utilities.sessionQueue) { [self] position in
                delegate.zoomFloater = CGFloat(position)
                delegate.runZoomController()
            }
            controls.append(zoomSlider)
        }
        
#warning("same as above")
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("focus") {
            let focusSlider = AVCaptureSlider("Focus", symbolName: "scope", in: 0.0...1.0)
            focusSlider.setActionQueue(delegate.utilities.sessionQueue) { [self] position in
                delegate.focusFloater = position
                delegate.runManualFocusController()
                delegate.focusFloater = nil
            }
            controls.append(focusSlider)
        }
        
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("cameras") {
            let cameraSwitcher = AVCaptureIndexPicker("Cameras", symbolName: "camera.fill", localizedIndexTitles: delegate.camera.cameras.map { $0.localizedName } )
            if let device = delegate.camera.device {
                cameraSwitcher.selectedIndex = delegate.camera.cameras.firstIndex(of: device)!
            }
            cameraSwitcher.setActionQueue(delegate.utilities.sessionQueue) { [self] index in
                delegate.camera.index = index
            }
            controls.append(cameraSwitcher)
        }
        
        var flashSwitcher: AVCaptureIndexPicker?
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("flash") {
            flashSwitcher = AVCaptureIndexPicker("Flash", symbolName: "bolt.fill", numberOfIndexes: 2, localizedTitleTransform: { index in
                switch index {
                case 0: return NSLocalizedString("flash.off", comment: "")
                case 1: return NSLocalizedString("flash.on", comment: "")
                default: return ""
                }
            })
            flashSwitcher!.setActionQueue(delegate.utilities.sessionQueue) { [self] index in
                flashSwitcher!.selectedIndex = delegate.flashStatus ? 1 : 0
                delegate.runFlashlightToggle()
                flashSwitcher!.selectedIndex = delegate.flashStatus ? 1 : 0
            }
            controls.append(flashSwitcher!)
        }
        
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("flashLevel") {
            let flashSlider = AVCaptureSlider("Flash Level", symbolName: "lightbulb.fill", in: 0.0...1.0)
            flashSlider.setActionQueue(delegate.utilities.sessionQueue) { [self] position in
                if (position == 0.0 && delegate.flashStatus) || (position != 0.0 && !delegate.flashStatus) {
                    delegate.flashFloater = position
                    delegate.runFlashlightToggle()
                    delegate.flashFloater = nil
                    if let flashSwitcher = flashSwitcher { flashSwitcher.selectedIndex = delegate.flashStatus ? 1 : 0 }
                } else {
                    delegate.utilities.function.flashLevelTest(captureDevice: delegate.camera.device!, floater: position)
                }
            }
            controls.append(flashSlider)
        }
        
        if delegate.utilities.preferences.evaintrnl.cameraControlOptions.contains("exposureBias") {
            if let device = delegate.camera.device {
                let systemBiasSlider = AVCaptureSystemExposureBiasSlider(device: device)
            controls.append(systemBiasSlider)
            }
        }
        
        if delegate.utilities.versionType == "INTERNAL" {
            delegate.camera.session.setControlsDelegate(self, queue: delegate.utilities.sessionQueue)
            delegate.utilities.function.addControlsToSession(session: &delegate.camera.session, controls: controls)
        }
    }
}

// MARK: ControlLayer - Misc
extension CameraView.ControlLayer {
    @objc func updateSettingsGestureFingerCount() {
        delegate.settingsRecognizer.numberOfTouchesRequired = delegate.utilities.preferences.evaintrnl.settingsGesture
    }
    
    @objc func runSettingsGesture() {
        if delegate.settingsRecognizer.state == UIGestureRecognizer.State.ended {
            delegate.presentSettingsView()
        }
    }
    
    /// Function to show and hide the user interface that was drawn with ``setupView()``.
    @objc func runUIHider() {
        #warning("update for Liquid Glass, using UIView.animate is not recommended")
        if delegate.uiHiderRecognizer.state == UITapGestureRecognizer.State.ended || delegate.uiHiderRecognizer.state == UITapGestureRecognizer.State.changed  { return }
        
        DispatchQueue.main.async { [self] in
            if !delegate.uiIsHidden {
                delegate.utilities.views.hideUI(view: delegate.view, blacklisted: [ delegate.aeafFeedback, delegate.uiHiderRecognizer ], conditionals: [ delegate.focusLockButton : delegate.manualFocusSliderIsActive, delegate.exposureLockButton : delegate.manualExposureSliderIsActive], gestureRecognizers: self.recognizers)
            } else {
                delegate.utilities.views.showUI(view: delegate.view, blacklisted: [ delegate.aeafFeedback, delegate.uiHiderRecognizer ], conditionals: [ delegate.focusLockButton : delegate.manualFocusSliderIsActive, delegate.exposureLockButton : delegate.manualExposureSliderIsActive], gestureRecognizers: self.recognizers)
                delegate.utilities.tooltips.zoomTooltipFlow(button: delegate.currentCamera, viewForBounds: delegate.view, camera: delegate.camera.device)
            }

            delegate.uiIsHidden = !delegate.uiIsHidden
            delegate.utilities.haptics.triggerNotificationHaptic(type: .success)
        }
    }
    
    @available(iOS 17.2, *)
    func initEventInteraction() {
        let interaction = AVCaptureEventInteraction { event in
            if event.phase == .ended { self.delegate.runImageCapture() }
        }
        delegate.view.addInteraction(interaction)
        eventInteraction = interaction
    }
}


