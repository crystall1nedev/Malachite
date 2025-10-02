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
        
        struct buttonGroup {
            /// A `UIButton` that enables the user to switch between the ultra-wide and wide angle cameras.
            var camera = UIButton()
            /// A `UIButton` that enables the user to toggle the flashlight's on state.
            var flashlight = UIButton()
            /// A `UIButton` that enables the user to take photos.
            var capture = UIButton()
            /// A `UIButton` that enables the user to change settings within the app.
            var settings = UIButton()
            /// A ``sliderGroup`` that enables the user to control manual focus adjustment.
            var focus = MalachiteViewUtils.Sliders.sliderGroup()
            /// A ``sliderGroup`` that enables the user to control manual exposure adjustment.
            var exposure = MalachiteViewUtils.Sliders.sliderGroup()
            /// A ``sliderGroup`` that enables the user to control the flashlight brightness level.
            var flash = MalachiteViewUtils.Sliders.sliderGroup()
            /// A `UIButton` that contains the blur for the on-screen feedback produced by the auto focus gesture.
            var continuousFeedback = UIButton()
            /// The button used to display what camera is in use.
            var currentCamera = UIButton()
        }
        
        struct recognizerGroup {
            /// A `UIPinchGestureRecognizer` that handles zooming in and out of the ``cameraSession``.
            var zoom = UIPinchGestureRecognizer()
            /// A `UILongPressGestureRecognizer` that handles enabling the AE+AF system at a specific point on the display for the ``cameraSession``.
            var continuous = UILongPressGestureRecognizer()
            /// A `UIPanGestureRecognizer` that handles opening settings with a gesture.
            var settings = UISwipeGestureRecognizer()
            /// A `UILongPressGestureRecognizer` that handles hiding all elements of the user interface, and disabling the ``zoomRecognizer`` and ``aeafRecognizer`` gestures.
            var uiHider = UILongPressGestureRecognizer()
        }
        
        struct titleGroup {
            /// The title for the focus slider.
            var focus = UILabel()
            /// The title for the exposure slider.
            var exposure = UILabel()
        }
        
        var buttons = buttonGroup()
        var recognizers = recognizerGroup()
        var titles = titleGroup()
        
        /// A `Bool` that determines whether or not the user interface is currently hidden to the user.
        var uiIsHidden = false
        
        /**
         An array of `UIGestureRecognizer` objects that are managed by this control layer.
         */
        var activeRecognizers = [ UIGestureRecognizer ]()
        /**
         The `AVCaptureEventInteraction` that catches volume button and Camera Control events for taking photos.
         */
        var eventInteraction: Any? = { if #available(iOS 17.2, *) { return AVCaptureEventInteraction?.self } else { return nil } }()
        
        /**
         Creates, adds, and constrains the `UIButton` objects that are managed by this control layer.
         */
        func initButtons() {
            let buttonConstraints: [MalachiteViewUtils.buttonBuilder.constraints] = [
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -10.0, LYP: true, CXA: delegate.view.safeAreaLayoutGuide.centerXAnchor, CXC: 0.0, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 80.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 150.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: 0.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 150.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.trailingAnchor, LXC: -10.0, LXP: false, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.bottomAnchor, LYC: -80.0, LYP: true, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: nil, LXC: nil, LXP: nil, LYA: nil, LYC: nil, LYP: nil, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
                MalachiteViewUtils.buttonBuilder.constraints(LXA: delegate.view.safeAreaLayoutGuide.leadingAnchor, LXC: 10.0, LXP: true, LYA: delegate.view.safeAreaLayoutGuide.topAnchor, LYC: 10.0, LYP: false, CXA: nil, CXC: nil, CYA: nil, CYC: nil),
            ]
            
            let buttonConfigs: [MalachiteViewUtils.buttonBuilder] = [
                MalachiteViewUtils.buttonBuilder(symbolName: "camera", action: #selector(delegate.runInputSwitch), dimensions: [ 60.0 ], constraints: buttonConstraints[0], hidden: false, assign: { [self] button in self.buttons.camera = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "flashlight.off.fill", action: #selector(delegate.runFlashlightToggle), dimensions: [ 60.0 ], constraints: buttonConstraints[1], hidden: false, assign: { [self] button in self.buttons.flashlight = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "camera.aperture", action: #selector(delegate.runImageCapture), dimensions: [ 90.0 ], constraints: buttonConstraints[2], hidden: false, assign: { [self] button in self.buttons.capture = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "scope", action: #selector(delegate.runManualFocusUIHider), dimensions: [ 60.0 ], constraints: buttonConstraints[3], hidden: false, assign: { [self] button in self.buttons.focus.activator = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 210.0, 60.0 ], constraints: buttonConstraints[4], hidden: false, assign: { [self] button in self.buttons.focus.container = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualFocusLockController), dimensions: [ 60.0 ], constraints: buttonConstraints[5], hidden: true, assign: { [self] button in self.buttons.focus.lock = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "plusminus", action: #selector(delegate.runManualExposureUIHider), dimensions: [ 60.0 ], constraints: buttonConstraints[6], hidden: false, assign: { [self] button in self.buttons.exposure.activator = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 210.0, 60.0 ], constraints: buttonConstraints[7], hidden: false, assign: { [self] button in self.buttons.exposure.container = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualExposureLockController), dimensions: [ 60.0 ], constraints: buttonConstraints[8], hidden: true, assign: { [self] button in self.buttons.exposure.lock = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lightbulb", action: #selector(delegate.runManualFlashUIHider), dimensions: [ 60.0 ], constraints: buttonConstraints[9], hidden: false, assign: { [self] button in self.buttons.flash.activator = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 210.0, 60.0 ], constraints: buttonConstraints[10], hidden: false, assign: { [self] button in self.buttons.flash.container = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "lock.open", action: #selector(delegate.runManualFlashLockController), dimensions: [ 60.0 ], constraints: buttonConstraints[11], hidden: true, assign: { [self] button in self.buttons.flash.lock = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "gear", action: #selector(delegate.presentSettingsView), dimensions: [ 60.0 ], constraints: buttonConstraints[12], hidden: false, assign: { [self] button in self.buttons.settings = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 120.0 ], constraints: buttonConstraints[13], hidden: true, assign: { [self] button in self.buttons.continuousFeedback = button }),
                MalachiteViewUtils.buttonBuilder(symbolName: "", action: #selector(delegate.stub), dimensions: [ 60.0 ], constraints: buttonConstraints[14], hidden: false, assign: { [self] button in self.buttons.currentCamera = button }),
            ]
            
            for config in buttonConfigs {
                let button = delegate.utilities.views.createAndAddButtonToView(symbolName: config.symbolName, delegate: delegate, view: delegate.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions, constraints: config.constraints)
                if delegate.utilities.preferences.userInterface.appLaunch { button.alpha = 0.0; self.uiIsHidden = true }
                if config.hidden { button.alpha = 0.0 }
                config.assign(button)
            }
        }
        
        /**
         Creates, adds, and constrains the ``UISlider`` objects that are managed by this control layer.
         */
        func initSliders() {
            let sliderConfigs: [MalachiteViewUtils.sliderBuilder] = [
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualFocusController), dimensions: [ 180.0, 80.0 ], view: self.buttons.focus.container, assign: { [self] slider in self.buttons.focus.slider = slider } ),
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualExposureController), dimensions: [ 180.0, 80.0 ], view: self.buttons.exposure.container, assign: { [self] slider in self.buttons.exposure.slider = slider } ),
                MalachiteViewUtils.sliderBuilder(action: #selector(delegate.runManualFlashController), dimensions: [ 180.0, 80.0 ], view: self.buttons.flash.container, assign: { [self] slider in self.buttons.flash.slider = slider } ),
            ]
            
            for config in sliderConfigs {
                config.assign(delegate.utilities.views.createAndAddSliderToView(delegate: delegate, view: config.view, utilities: delegate.utilities, action: config.action, dimensions: config.dimensions))
            }
        }
        
        /**
         Creates and adds the ``UIGestureRecognizer`` objects that are managed by this control layer.
         */
        func initRecognizers() {
            self.recognizers.zoom = UIPinchGestureRecognizer(target: delegate, action:#selector(runZoomController))
            self.recognizers.zoom.name = "zoom"
            self.activeRecognizers.append(self.recognizers.zoom)
            
            if !delegate.utilities.preferences.userInterface.tapAndHold.contains("off") {
                self.recognizers.continuous = UILongPressGestureRecognizer(target: delegate, action: #selector(runaeafController))
                self.recognizers.continuous.name = "tah"
                self.activeRecognizers.append(self.recognizers.continuous)
            }
            
            self.recognizers.uiHider = UILongPressGestureRecognizer(target: self, action: #selector(runUIHider))
            self.recognizers.uiHider.numberOfTouchesRequired = 2
            self.activeRecognizers.append(self.recognizers.uiHider)
            
            if delegate.utilities.versionType == "INTERNAL" {
                self.recognizers.settings = UISwipeGestureRecognizer(target: self, action: #selector(self.runSettingsGesture))
                self.updateSettingsGestureFingerCount()
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateSettingsGestureFingerCount), name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
                self.recognizers.settings.direction = .up
                
                self.activeRecognizers.append(self.recognizers.settings)
            }
            
            for recognizer in self.activeRecognizers {
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
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.focus.title", anchor: 10, assign: { [self] label in self.titles.focus = label } ),
                    MalachiteViewUtils.tooltipBuilder(text: "uibutton.exposure.title", anchor: 80, assign: { [self] label in self.titles.exposure = label } ),
                ]
                
                var labels: [ UILabel ] = []
                for config in tooltipConfigs {
                    labels.append(delegate.utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: delegate.view, textForFlow: NSLocalizedString(config.text.localized, comment: ""), anchorConstant: config.anchor))
                }
                
                delegate.utilities.tooltips.fadeOutTooltipFlow(labelsToFade: labels)
            }
            
            if delegate.camera.device != nil {
                if showCamera { delegate.utilities.tooltips.zoomTooltipFlow(button: self.buttons.currentCamera, viewForBounds: delegate.view, camera: delegate.camera.device) }
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

// MARK: ControlLayer - Slider Controls
extension CameraView.ControlLayer {
    func hideOtherSliders(name: String) {
        if name != "focus" && self.buttons.focus.sliderShown { delegate.runManualFocusUIHider() }
        if name != "exposure" && self.buttons.exposure.sliderShown { delegate.runManualExposureUIHider() }
        if name != "flash" && self.buttons.flash.sliderShown { delegate.runManualFlashUIHider() }
    }
}

// MARK: ControlLayer - Camera Control
@available(iOS 18.0, *)
extension CameraView.ControlLayer {
    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        if !self.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
        if !self.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
        if self.uiIsHidden { runUIHider() }
    }
    
    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        if self.uiIsHidden { runUIHider() }
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
            delegate.utilities.function.addControlsToSession(session: delegate.camera.session, controls: controls)
        }
    }
}

// MARK: ControlLayer - Misc
extension CameraView.ControlLayer {
    @objc func updateSettingsGestureFingerCount() { self.recognizers.settings.numberOfTouchesRequired = delegate.utilities.preferences.evaintrnl.settingsGesture }
    
    @objc func runSettingsGesture() {
        if self.recognizers.settings.state == UIGestureRecognizer.State.ended {
            delegate.presentSettingsView()
        }
    }
    
    /// Function to show and hide the user interface that was drawn with ``setupView()``.
    @objc func runUIHider() {
        #warning("update for Liquid Glass, using UIView.animate is not recommended")
        if self.recognizers.uiHider.state == UITapGestureRecognizer.State.ended || self.recognizers.uiHider.state == UITapGestureRecognizer.State.changed  { return }
        
        DispatchQueue.main.async { [self] in
            if !self.uiIsHidden {
                delegate.utilities.views.hideUI(view: delegate.view, blacklisted: [ self.buttons.continuousFeedback, self.recognizers.uiHider ], conditionals: [ self.buttons.focus.lock : self.buttons.focus.sliderShown, self.buttons.exposure.lock : self.buttons.exposure.sliderShown ], gestureRecognizers: self.activeRecognizers)
            } else {
                delegate.utilities.views.showUI(view: delegate.view, blacklisted: [ self.buttons.continuousFeedback, self.recognizers.uiHider ], conditionals: [ self.buttons.focus.lock : self.buttons.focus.sliderShown, self.buttons.exposure.lock : self.buttons.exposure.sliderShown ], gestureRecognizers: self.activeRecognizers)
                delegate.utilities.tooltips.zoomTooltipFlow(button: self.buttons.currentCamera, viewForBounds: delegate.view, camera: delegate.camera.device)
            }

            self.uiIsHidden = !self.uiIsHidden
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


