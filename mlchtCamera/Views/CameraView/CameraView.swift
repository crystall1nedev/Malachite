//
//  CameraView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/25/23.
//

import SwiftUI
import UIKit
import Foundation
import AVFoundation
import AVKit
import Photos
import GameKit

class CameraView: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    /// An instance of ``MalachiteClassesObject`` for reuse across the app.
    public var utilities: MalachiteClassesObject!
    
    /// An instance of MalachiteKit's ``Camera`` class.
    var camera: Camera!
    
    /// An instance of ``CameraView/ControlLayer`` for this view.
    var controlLayer: CameraView.ControlLayer!
    /// An instance of ``CameraView/Notifications`` for this view.
    var notifications: CameraView.Notifications!
    /// An instance of ``CameraView/Preview`` for this view.
    var preview: CameraView.Preview!
    
    /// A `CGFloat` that temporarily holds the zoom factor.
    var zoomFloater = CGFloat()
    /// A `Float` that temporarily holds the focus factor.
    var focusFloater: Float?
    /// A `Float` that temporarily holds the level of flash brightness to use.
    var flashFloater: Float?
    /// A `Bool` that temporarily holds the current status of the flashlight.
    var flashStatus = Bool()
    
    /// The minimum zoom value that the ``zoomRecognizer`` is allowed to reach.
    let minimumZoom: CGFloat = 1.0
    /// The maximum zoom value that the ``zoomRecognizer`` is allowed to reach.
    let maximumZoom: CGFloat = 5.0
    /// The last known zoom factor that the ``zoomRecognizer`` was set to.
    var lastZoomFactor: CGFloat = 1.0
    
    /// A `UIActivityIndicatorView` used to let the user know that Malachite is processing the image.
    var progressIndicator = UIActivityIndicatorView()
    
    /**
     viewDidLoad override for the main user interface.
     
     This function currently serves to do the following:
     - Create and assign a value to all variables needed to run ``cameraSession`` and its preview layer, ``cameraPreview``.
     - Read the user's preferences to determine the preview layer's aspect ratio.
     - Register notifications for changes to certain options in ``MalachiteSettingsView``, as well as orientation changes.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #unavailable(iOS 18.0) { overrideUserInterfaceStyle = .dark }
        self.view.backgroundColor = .black
        
        self.notifications = CameraView.Notifications(delegate: self)
        self.controlLayer = CameraView.ControlLayer(delegate: self)
        
        self.notifications.bringUpNotifications()
        self.camera = Camera(utilities: utilities)
        self.preview = CameraView.Preview(delegate: self)
        
        self.utilities.watch.bringUpCompanionConnection()
    }
    
    @objc func cameraClassDidLoad() {
        if camera.cameras.first != nil {
            utilities.debugNSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
            self.runInputSwitch()
            preview.initPreviewLayer()
            
            utilities.debugNSLog("[Initialization] Starting session stream")
            self.camera.queue.async { self.camera.session.startRunning() }
        } else {
            utilities.debugNSLog("[Initialization] No cameras detected, skipping to user interface bringup")
        }
    }
    
    /**
     viewDidAppear override for the main user interface.
     
     This function currently serves to do the following:
     - Create all buttons and gestures required to operate the user interface.
     - Set up GameKit integration for achievements and leaderboard reporting.
     
     `DEBUG` builds of Malachite additionally do the following:
     - Dump the contents of UserDefaults.
     - Dump the contents of Game Center achievements and leaderboards.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        utilities.debugNSLog("[Initialization] Presenting user interface")
        (utilities.versionType == "INTERNAL") ? setupView_INTERNAL() : setupView()
    }
    
    /**
     Function used to determine what rotation Malachite should be in on iPadOS.
     
     iPhones follow the stock camera apps's behavior of only rotating buttons, while iPads get the ability to rotate the entire device.
     TODO: fix bugs regarding this...
     */
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func setupView_INTERNAL() {
        utilities.games.changeGameCenterEnabled()
        if utilities.preferences.general.gamekit.alerted { self.present(utilities.games.setupGameKitAlert(), animated: true, completion: nil) }
        setupView()
    }
    
    /**
     Function to register buttons and gestures for operating Malachite.
     
     This function creates and provides layout properties for the following views:
     - ``cameraButton``
     - ``flashlightButton``
     - ``captureButton``
     - ``focusButton``
     - ``focusSliderButton``
     - ``focusSlider``
     - ``focusLockButton``
     - ``exposureButton``
     - ``exposureSliderButton``
     - ``exposureSlider``
     - ``exposureLockButton``
     - ``settingsButton``
     
     This function also creates the following gesture recognizers:
     - ``zoomRecognizer`` - Pinch-to-zoom gesture
     - ``aeafRecognizer`` - Tap and hold with one finger
     - ``uiHiderRecognizer`` - Tap and hold with two fingers
     */
    func setupView(){
#if targetEnvironment(simulator)
        utilities.views.setupLmaoView(view: self.view)
#endif
        
        self.controlLayer.bringUpControlLayer()
        
        utilities.function.changeIdleTimerState()
    }
    
    /// Stub function. It literally does nothing.
    @objc func stub() { }
    
    /// Function to dynamically update the aspect ratio for ``cameraPreview`` through ``MalachiteSettingsView``.
    @objc func changeAspectFill() {
        UIView.animate(withDuration: 20) { [self] in
            if utilities.preferences.preview.aspect {
                self.preview.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                self.preview.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
    }
    
    /// Function to dynamically change the auto exposure and ``exposureSlider`` values when toggling in ``MalachiteSettingsView``.
    @objc func changeExposureLimit() {
        guard let exposure = camera.device?.isExposureModeSupported(.continuousAutoExposure) else { return }
        do {
            try camera.device?.lockForConfiguration()
            defer { camera.device?.unlockForConfiguration() }
            if exposure { camera.device?.exposureMode = .continuousAutoExposure }
        } catch {
            utilities.debugNSLog("[Change Exposure Limit] Couldn't lock device for configuration")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.controlLayer.buttons.exposure.slider.value = 0.0
        }
    }
    
    @objc func changeContinuousAEAF() {
        guard let selectedDevice = camera.device else { return }
        utilities.function.continuousAEAF(device: selectedDevice)
    }
    
    @objc func changeAEAFRecognizer() {
        let tapGestureElements = utilities.preferences.userInterface.tapAndHold
        guard let currentGestureRecognizers = self.view.gestureRecognizers else { return }
        
        if tapGestureElements.contains("off") {
            if currentGestureRecognizers.contains(self.controlLayer.recognizers.continuous) {
                utilities.debugNSLog("[AE+AF] Disabling tap and hold gesture")
                self.view.removeGestureRecognizer(self.controlLayer.recognizers.continuous)
            }
        } else {
            if !currentGestureRecognizers.contains(self.controlLayer.recognizers.continuous) {
                utilities.debugNSLog("[AE+AF] Enabling tap and hold gesture")
                self.view.addGestureRecognizer(self.controlLayer.recognizers.continuous)
            }
        }
    }
    
    /// Function to change the video stabilization mode for the ``cameraPreview``.
    @objc func changeStabilizerMode() {
        guard let connection = self.preview.previewLayer.connection else { print("bruh"); return }
        if utilities.preferences.preview.stablize {
            if #available(iOS 17.0, *) {
                if ((camera.device?.activeFormat.isVideoStabilizationModeSupported(.previewOptimized)) != nil) {
                    utilities.debugNSLog("[Preview Stabilization] Enabling enhanced stabilization mode")
                    connection.preferredVideoStabilizationMode = .previewOptimized
                    return
                }
            }
            
            if ((camera.device?.activeFormat.isVideoStabilizationModeSupported(.standard)) != nil) {
                utilities.debugNSLog("[Preview Stabilization] Enabling standard stabilization mode")
                connection.preferredVideoStabilizationMode = .standard
            }
        } else {
            connection.preferredVideoStabilizationMode = .off
        }
    }
    
    /// Function to present ``MalachiteSettingsView``
    @objc func presentSettingsView() {
#if APP_EXTENSION
        utilities.debugNSLog("[Settings] Attempt to access Settings UI from app extension")
        let alert = utilities.views.createAlertController(title: "alert.title.app_extensions.settings", message: "alert.detail.app_extensions.settings", button: self.controlLayer.buttons.settings, defaultSet: true, action: { _ in
            self.utilities.debugNSLog("[Settings] Dialog has been dismissed")
        })
        DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
        return
#elseif MAIN_APP
        var aboutView = SettingsView(dismissAction: {self.dismiss( animated: true, completion: nil )})
        aboutView.utilities = self.utilities
        let hostingController = UIHostingController(rootView: aboutView)
        hostingController.modalPresentationStyle = UIModalPresentationStyle.popover
        hostingController.popoverPresentationController?.sourceView = self.controlLayer.buttons.settings
        hostingController.isModalInPresentation = true
        if #available(iOS 26.0, *) {
            hostingController.preferredTransition = .zoom { [self] _ in
                self.controlLayer.buttons.settings
            }
        }
        DispatchQueue.main.async { self.present(hostingController, animated: true, completion: nil) }
#endif
    }
    
    /// Function to switch cameras and attach new camera.inputs to ``cameraSession``, and set settings based on the `activeFormat` of ``selectedDevice``.
    @objc func runInputSwitch() {
        DispatchQueue.main.async { self.controlLayer.buttons.camera.isUserInteractionEnabled = false }
        if (self.camera.cameras.count < 2 || utilities.preferences.debug.breakApp) && !self.camera.session.inputs.isEmpty  {
            utilities.debugNSLog("[Camera Input] Only one AVCaptureDevice is available to use, showing error")
            let alert = utilities.views.createAlertController(title: "alert.title.camera_switch", message: "alert.detail.camera_switch", button: self.controlLayer.buttons.camera, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Camera Input] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
            self.controlLayer.buttons.camera.isUserInteractionEnabled = true
            return
        }
            
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.controlLayer.buttons.focus.slider.value = 0.0
                self.controlLayer.buttons.exposure.slider.value = 0.0
            }
        }
        
        camera.input.runInputSwitch()
        
        
        if #available(iOS 18.0, *) {
            if utilities.versionType == "INTERNAL" && utilities.preferences.evaintrnl.cameraControlEnabled {
                DispatchQueue.main.async { self.controlLayer.initCameraControl() }
            }
        }
        
        DispatchQueue.main.async() { [self] in
            DispatchQueue.main.async { self.controlLayer.initTooltips(showLabels: false, showCamera: true) }
        }
        
        DispatchQueue.main.async { self.controlLayer.buttons.camera.isUserInteractionEnabled = true }
    }
    
    @available(iOS 16.0, *)
    @objc func runInputMegapixelSwitch() {
        guard let selectedDevice = camera.device else { return }
        utilities.function.switchInputMegapixels(device: selectedDevice, photoOutput: self.camera.output)
    }
    
    /// Function to toggle the flashlight's on state.
    @objc func runFlashlightToggle() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.isFlashAvailable && !utilities.preferences.debug.breakApp {
            utilities.function.toggleFlash(captureDevice: selectedDevice,
                                           flashlightButton: self.controlLayer.buttons.flashlight,
                                           floater: flashFloater,
                                           isFlashOn: &flashStatus)
        } else {
            utilities.debugNSLog("[Flashlight] No flashlight available")
            let alert = utilities.views.createAlertController(title: "alert.title.flashlight", message: "alert.detail.flashlight", button: self.controlLayer.buttons.flashlight, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Flashlight] Dialog has been dismissed")
            })
            DispatchQueue.main.async { self.present(alert, animated: true, completion: nil) }
        }
    }
    
    /// Function to take an image.
    @objc func runImageCapture() {
        DispatchQueue.main.async { [self] in
            self.controlLayer.buttons.capture.isEnabled = false
            progressIndicator = UIActivityIndicatorView(frame: self.controlLayer.buttons.capture.frame)
            self.view.addSubview(progressIndicator)
            self.controlLayer.buttons.capture.setImage(nil, for: .normal)
            progressIndicator.startAnimating()
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if (status == .authorized || status == .limited) && !utilities.preferences.debug.breakApp {
            self.camera.output = utilities.function.captureImage(output: self.camera.output, viewForBounds: self.view, captureDelegate: self)
        } else {
            utilities.debugNSLog("[Capture Photo] PHPhotoLibrary not authorized, showing error")
            let alert = utilities.views.createAlertController(title: "alert.title.phphotolibrary", message: "alert.detail.phphotolibrary", button: self.controlLayer.buttons.capture, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Capture Photo] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function for opening ``MalachitePhotoPreview`` and running GameKit commands after photo processing is completed.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let getterForOrientation = UIImage(data: imageData)
        let previewImage = UIImage(ciImage: CIImage(data: imageData, options: [.applyOrientationProperty: true,
                                                                               .properties: [kCGImagePropertyOrientation: CGImagePropertyOrientation(getterForOrientation!.imageOrientation).rawValue]])!)
        let photoPreview = PhotoPreviewView()
        photoPreview.photoImageData = imageData
        photoPreview.photoImageView.frame = view.frame
        photoPreview.photoImage = previewImage
        if utilities.preferences.preview.fastPath {
            photoPreview.savePhoto(finalImage: photoPreview.finalizeImageForExport(imageData: imageData))
        } else {
            let navigationController = UINavigationController(rootViewController: photoPreview)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            navigationController.isModalInPresentation = true
            navigationController.isNavigationBarHidden = true
            navigationController.popoverPresentationController?.sourceView = self.controlLayer.buttons.capture
            if #available(iOS 26.0, *) {
                navigationController.preferredTransition = .zoom { [self] _ in self.controlLayer.buttons.capture }
            }
            self.present(navigationController, animated: true, completion: nil)
            NotificationCenter.default.addObserver(photoPreview, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        self.controlLayer.buttons.capture.isEnabled = true
        self.controlLayer.buttons.capture.setImage(UIImage(systemName: "camera.aperture"), for: .normal)
        progressIndicator.stopAnimating()
        
        DispatchQueue.global(qos: .background).async { [self] in
            utilities.preferences.ext.runPhotoCounter()
            if utilities.games.gameCenterEnabled {
                let numPhotos = utilities.preferences.general.photoCount
                if numPhotos == 1 {
                    let firstPhoto = utilities.games.achievements.pullAchievement(achievementName: "first_photo")
                    firstPhoto.percentComplete = 100
                    utilities.games.achievements.pushAchievement(achievementBody: firstPhoto)
                }
                utilities.games.leaderboards.pushLeaderboard(scoreToSubmit: numPhotos, leaderboardToSubmit: "photos_taken")
            }
        }
    }
    
    /// Function to zoom in and out with ``zoomRecognizer``.
    @objc func runZoomController() {
        guard let selectedDevice = camera.device else { return }
        utilities.function.zoom(sender: self.controlLayer.recognizers.zoom,
                                floater: &zoomFloater,
                                captureDevice: selectedDevice,
                                lastZoomFactor: &lastZoomFactor,
                                hapticClass: utilities.haptics)
    }
    
    /// Function to autofocus + autoexposure with ``aeafRecognizer``.
    @objc func runaeafController() {
        guard let selectedDevice = camera.device else { return }
        utilities.function.pointOfInterestAEAF(sender: self.controlLayer.recognizers.continuous,
                                     captureDevice: selectedDevice,
                                               button: self.controlLayer.buttons.continuousFeedback,
                                     viewForScale: self.view,
                                     hapticClass: utilities.haptics)
    }
    
    /// Function to handle ``exposureSlider`` interaction.
    @objc func runManualExposureController() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.isExposureModeSupported(.custom) && !utilities.preferences.debug.breakApp {
            utilities.function.manualExposure(captureDevice: selectedDevice,
                                              sender: self.controlLayer.buttons.exposure.slider)
        } else {
            utilities.debugNSLog("[Manual Exposure] Current camera is not capable of adjusting exposure")
            let alert = utilities.views.createAlertController(title: "alert.title.exposure", message: "alert.detail.exposure", button: self.controlLayer.buttons.exposure.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to show and hide the ``exposureSliderButton`` and ``exposureLockButton``.
    @objc func runManualExposureUIHider() {
        guard let exposure = camera.device?.isExposureModeSupported(.custom) else { return }
        if exposure && !utilities.preferences.debug.breakApp {
            self.controlLayer.hideOtherSliders(group: self.controlLayer.buttons.exposure)
            self.controlLayer.buttons.exposure.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.exposure)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting exposure")
            let alert = utilities.views.createAlertController(title: "alert.title.exposure", message: "alert.detail.exposure", button: self.controlLayer.buttons.exposure.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func runManualExposureUIHiderWhenUnsupported() {
        self.controlLayer.buttons.exposure.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.exposure)
    }
    
    /// Function to lock and unlock the ``exposureSlider``.
    @objc func runManualExposureLockController() {
        self.controlLayer.buttons.exposure.lockEnabled = utilities.views.sliders.runLocks(group: self.controlLayer.buttons.exposure,
                                                                                          associatedGestureRecognizer: nil,
                                                                                          viewForRecognizers: self.view)
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusController() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.isLockingFocusWithCustomLensPositionSupported && !utilities.preferences.debug.breakApp {
            utilities.function.manualFocus(captureDevice: selectedDevice,
                                           sender: self.controlLayer.buttons.focus.slider,
                                           floater: focusFloater ?? self.controlLayer.buttons.focus.slider.value)
        } else {
            #warning("refactor to call unsupported codepath")
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = utilities.views.createAlertController(title: "alert.title.focus", message: "alert.detail.focus", button: self.controlLayer.buttons.focus.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusUIHider() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.isLockingFocusWithCustomLensPositionSupported && !utilities.preferences.debug.breakApp {
            self.controlLayer.hideOtherSliders(group: self.controlLayer.buttons.focus)
            self.controlLayer.buttons.focus.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.focus)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = utilities.views.createAlertController(title: "alert.title.focus", message: "alert.detail.focus", button: self.controlLayer.buttons.focus.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func runManualFocusUIHiderWhenUnsupported() {
        self.controlLayer.buttons.focus.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.focus)
    }
    
    /// Function to show and hide the ``focusSliderButton`` and ``focusLockButton``.
    @objc func runManualFocusLockController() {
        self.controlLayer.buttons.focus.lockEnabled = utilities.views.sliders.runLocks(group: self.controlLayer.buttons.focus,
                                                                                       associatedGestureRecognizer: self.controlLayer.recognizers.continuous,
                                                                                       viewForRecognizers: self.view)
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFlashController() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.hasTorch && !utilities.preferences.debug.breakApp {
            if (self.controlLayer.buttons.flash.slider.value == 0.0 && flashStatus) || (self.controlLayer.buttons.flash.slider.value != 0.0 && !flashStatus) {
                flashFloater = self.controlLayer.buttons.flash.slider.value
                runFlashlightToggle()
                flashFloater = nil
            } else {
                utilities.function.flashLevelTest(captureDevice: selectedDevice,
                                               floater: flashFloater ?? self.controlLayer.buttons.flash.slider.value)
            }
            
        } else {
            #warning("refactor to call unsupported codepath")
            utilities.debugNSLog("[Flashlight Level] Device does not have a flashlight")
            let alert = utilities.views.createAlertController(title: "alert.title.flashlight", message: "alert.detail.flashlight", button: self.controlLayer.buttons.flash.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Flashlight Level] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFlashUIHider() {
        guard let selectedDevice = camera.device else { return }
        if selectedDevice.hasTorch && !utilities.preferences.debug.breakApp {
            self.controlLayer.hideOtherSliders(group: self.controlLayer.buttons.flash)
            self.controlLayer.buttons.flash.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.flash)
        } else {
            utilities.debugNSLog("[Flashlight Level] Device does not have a flashlight")
            let alert = utilities.views.createAlertController(title: "alert.title.flashlight", message: "alert.detail.flashlight", button: self.controlLayer.buttons.flash.activator, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Flashlight Level] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func runManualFlashUIHiderWhenUnsupported() {
        self.controlLayer.buttons.flash.sliderShown = utilities.views.sliders.runHiders(group: self.controlLayer.buttons.flash)
    }
    
    /// Function to show and hide the ``focusSliderButton`` and ``focusLockButton``.
    @objc func runManualFlashLockController() {
        self.controlLayer.buttons.flash.lockEnabled = utilities.views.sliders.runLocks(group: self.controlLayer.buttons.flash,
                                                                                       associatedGestureRecognizer: nil,
                                                                                       viewForRecognizers: self.view)
    }
    
    /// Function to handle device rotation.
    #warning("refactor to view utils")
    @objc func orientationChanged() {
        utilities.views.rotateButtonsWithOrientation(buttonsToRotate: [ self.controlLayer.buttons.camera,
                                                                        self.controlLayer.buttons.flashlight,
                                                                        self.controlLayer.buttons.capture,
                                                                        self.controlLayer.buttons.settings,
                                                                        self.controlLayer.buttons.focus.activator,
                                                                        self.controlLayer.buttons.focus.lock,
                                                                        self.controlLayer.buttons.exposure.activator,
                                                                        self.controlLayer.buttons.exposure.lock,
                                                                        self.controlLayer.buttons.flash.activator,
                                                                        self.controlLayer.buttons.flash.lock  ])
    }
}

