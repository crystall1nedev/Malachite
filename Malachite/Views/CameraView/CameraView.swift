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
    var controlLayer: ControlLayer?
    var notifications: notifications?
    var preview: Preview?
    
    /// The `AVCaptureSession` Malachite uses for everything.
    var cameraSession: AVCaptureSession?
    /// The currently selected `AVCaptureDevice` for input to ``cameraSession``.
    var selectedDevice: AVCaptureDevice?
    /// An array respresenting the device's available rear cameras. This variable will be `nil` if no cameras are present (as is the case of the iOS simulator)
    var availableRearCameras = [AVCaptureDevice]()
    /// The device's currently available rear ultra-wide angle `AVCaptureDevice`, if available. This variable is `nil` if no ultra-wide angle camera is present (i.e. single-camera, Simulator).
    var ultraWideDevice: AVCaptureDevice?
    /// The device's currently available wide angle `AVCaptureDevice`, if available. This variable is `nil` if no wide angle camera is present (currently only in the Simulator).
    var wideAngleDevice: AVCaptureDevice?
    /// The currently selected `AVCaptureDeviceInput` for input to ``cameraSession``.
    var selectedInput: AVCaptureDeviceInput?
    /// The `AVCapturePhotoOutput` used to capture photos with ``selectedDevice`` and ``cameraSession``.
    var photoOutput = AVCapturePhotoOutput()
    /// The `AVCaptureVideoPreviewLayer` used to allow users to see a preview of their camera before taking a shot with ``photoOutput``.
    var cameraPreview = AVCaptureVideoPreviewLayer()
    /// A `Bool` that determines whether or not the wide angle lens is in use.
    var wideAngleInUse = true
    /// A `Bool` that determines whether or not the app is still initializing. Uses for tasks that should only be run once at the start of Malachite.
    var initRun = true
    /// A `CGFloat` that temporarily holds the zoom factor.
    var zoomFloater = CGFloat()
    /// A `Float` that temporarily holds the focus factor.
    var focusFloater: Float?
    /// A `Float` that temporarily holds the level of flash brightness to use.
    var flashFloater: Float?
    /// A `Bool` that temporarily holds the current status of the flashlight.
    var flashStatus = Bool()
    /// An `Int` that temporarily holds the index of the camera to switch to.
    var cameraIndex: Int?
    
    /// A `UIButton` that enables the user to switch between the ultra-wide and wide angle cameras.
    var cameraButton = UIButton()
    /// A `UIButton` that enables the user to toggle the flashlight's on state.
    var flashlightButton = UIButton()
    /// A `UIButton` that enables the user to take photos.
    var captureButton = UIButton()
    /// A `UIButton` that enables the user to change settings within the app.
    var settingsButton = UIButton()
    
    /// A `UIButton` that enables the user to reveal the ``focusSlider`` for manual focus adjustment.
    var focusButton = UIButton()
    /// A `UIButton` that holds the ``focusSlider`` for improved blur compatibility and shaping.
    var focusSliderButton = UIButton()
    /// A `UISlider` that enables the user to manually adjust the lens position.
    var focusSlider = UISlider()
    /// A `UIButton` that enables the user to toggle the lock states for the ``focusSlider`` and the ``aeafRecognizer``.
    var focusLockButton = UIButton()
    /// A `Bool` that determines whether or not the ``focusSlider`` is currently displayed on the user's screen.
    var manualFocusSliderIsActive = false
    /// A `Bool` that determines whether or not the ``focusLockButton`` is currently set to Locked.
    var manualFocusLockIsActive = false
    
    /// A `UIButton` that enables the user to reveal the ``exposureSlider`` for manual exposure adjustment.
    var exposureButton = UIButton()
    /// A `UIButton` that holds the ``exposureSlider`` for improved blur compatibility and shaping.
    var exposureSliderButton = UIButton()
    /// A `UISlider` that enables the user to manually adjust the exposure level.
    var exposureSlider = UISlider()
    /// A `UIButton` that enables the user to toggle the lock state for the ``exposureSlider``. Auto exposure toggling will come at a later date.
    var exposureLockButton = UIButton()
    /// A `Bool` that determines whether or not the ``exposureSlider`` is currently displayed on the user's screen.
    var manualExposureSliderIsActive = false
    /// A `Bool` that determines whether or not the ``exposureLockButton`` is currently set to Locked.
    var manualExposureLockIsActive = false
    
    /// A `UIPinchGestureRecognizer` that handles zooming in and out of the ``cameraSession``.
    var zoomRecognizer = UIPinchGestureRecognizer()
    /// A `UILongPressGestureRecognizer` that handles enabling the AE+AF system at a specific point on the display for the ``cameraSession``.
    var aeafRecognizer = UILongPressGestureRecognizer()
    /// A `UIButton` that contains the blur for the on-screen feedback produced by the auto focus gesture.
    var aeafFeedback = UIButton()
    /// A `UIPanGestureRecognizer` that handles opening settings with a gesture.
    var settingsRecognizer = UISwipeGestureRecognizer()
    /// A `UILongPressGestureRecognizer` that handles hiding all elements of the user interface, and disabling the ``zoomRecognizer`` and ``aeafRecognizer`` gestures.
    var uiHiderRecognizer = UILongPressGestureRecognizer()
    ///
    var eventInteraction: Any? = {
        if #available(iOS 17.2, *) {
            return AVCaptureEventInteraction?.self
        } else {
            return nil
        }
    }()
    
    /// A `Bool` that determines whether or not the user interface is currently hidden to the user.
    var uiIsHidden = false
    /// The title for the focus slider.
    var focusTitle = UILabel()
    /// The title for the exposure slider.
    var exposureTitle = UILabel()
    /// The button used to display what camera is in use.
    var currentCamera = UIButton()
    
    /// The minimum zoom value that the ``zoomRecognizer`` is allowed to reach.
    let minimumZoom: CGFloat = 1.0
    /// The maximum zoom value that the ``zoomRecognizer`` is allowed to reach.
    let maximumZoom: CGFloat = 5.0
    /// The last known zoom factor that the ``zoomRecognizer`` was set to.
    var lastZoomFactor: CGFloat = 1.0
    
    /// A `UIActivityIndicatorView` used to let the user know that Malachite is processing the image.
    var progressIndicator = UIActivityIndicatorView()
    
    /// An instance of ``MalachiteClassesObject`` for reuse across the app.
    public var utilities = MalachiteClassesObject()
    /// An observer for the device's rotation.
    private var rotationObserver: NSObjectProtocol?
    
    /**
     viewDidLoad override for the main user interface.
     
     This function currently serves to do the following:
     - Create and assign a value to all variables needed to run ``cameraSession`` and its preview layer, ``cameraPreview``.
     - Read the user's preferences to determine the preview layer's aspect ratio.
     - Register notifications for changes to certain options in ``MalachiteSettingsView``, as well as orientation changes.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.controlLayer = CameraView.ControlLayer(delegate: self)
        self.notifications = CameraView.notifications(delegate: self)
        self.preview = CameraView.Preview(delegate: self)
        
        #warning("this is temporary for testing")
        let bringup = Camera.Bringup(utilities: utilities)
        bringup.checkForHEICCompatibility()
        
        #warning("malachite camera init")
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = bringup.createAVCaptureSession(session: cameraSession)
        cameraPreview = preview!.createPreviewLayer(previewLayer: cameraPreview)
        
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        
        utilities.debugNSLog("[Camera Input] Getting current camera system capabilities")
        
        #warning("malachite camera init")
        var camerasToDiscover: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 17.0, *) { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera ] }
        else { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera] }
        
        utilities.debugNSLog("[Camera Input] Discovering available cameras")
        let currentProcess = ProcessInfo()
        AVCaptureDevice.DiscoverySession.init(deviceTypes: camerasToDiscover, mediaType: .video, position: (currentProcess.isiOSAppOnMac || currentProcess.isMacCatalystApp) ? .unspecified : .back).devices.forEach { device in
            self.availableRearCameras.append(device)
            utilities.debugNSLog("[Camera Input] \(device.localizedName)")
            utilities.debugNSLog("[Camera Input] \(device.deviceType.rawValue) available")
        }
        
        #warning("malachite camera init")
        runInputSwitch()
        
        if self.availableRearCameras.first != nil {
            photoOutput = AVCapturePhotoOutput()
            if #unavailable(iOS 16.0) { photoOutput.isHighResolutionCaptureEnabled = true }
            photoOutput.maxPhotoQualityPrioritization = .quality
            cameraSession?.sessionPreset = AVCaptureSession.Preset.photo
            cameraSession?.addOutput(photoOutput)
            
            utilities.debugNSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
            cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
            
            var statusBarOrientation = UIInterfaceOrientation.portrait
            #if MAIN_APP
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                statusBarOrientation = windowScene.interfaceOrientation
            }
            #endif
            cameraPreview.frame = view.layer.bounds
            let videoOrientation: AVCaptureVideoOrientation = (statusBarOrientation.videoOrientation)
            cameraPreview.connection?.videoOrientation = videoOrientation
            
            if utilities.preferences.preview.aspect {
                cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspect
            }
            
            self.view.layer.addSublayer(cameraPreview)
            
            utilities.debugNSLog("[Initialization] Starting session stream")
            DispatchQueue.global(qos: .background).async {
                self.cameraSession?.startRunning()
            }
        } else {
            utilities.debugNSLog("[Initialization] No cameras detected, skipping to user interface bringup")
        }
        
        #warning("malachite init")
        
        #warning("malachite camera init")
        if #available (iOS 17.2, *) {
            let interaction = AVCaptureEventInteraction { event in
                if event.phase == .ended {
                    self.runImageCapture()
                }
            }
            self.view.addInteraction(interaction)
            eventInteraction = interaction
        }
        
        
        #warning("malachite photo init")
        let cameraAuthStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if cameraAuthStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [self] status in
                utilities.debugNSLog("[Permissions] Camera authorization status: \(status)")
            }
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
        
        settingsRecognizer = UISwipeGestureRecognizer(target: self.controlLayer!, action: #selector(self.controlLayer!.runSettingsGesture))
        self.controlLayer!.updateSettingsGestureFingerCount()
        settingsRecognizer.direction = .up
        
        self.view.addGestureRecognizer(settingsRecognizer)
        
        NotificationCenter.default.addObserver(self.controlLayer!, selector: #selector(self.controlLayer!.updateSettingsGestureFingerCount), name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
        
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
#warning("remove simulator support")
#if targetEnvironment(simulator)
        utilities.views.setupLmaoView(view: self.view)
#endif
        
        self.controlLayer!.bringUpControlLayer()
        self.notifications!.bringUpNotifications()
        
        utilities.function.changeIdleTimerState()
    }
    
    /// Stub function. It literally does nothing.
    @objc func stub() { }
    
    /// Function to dynamically update the aspect ratio for ``cameraPreview`` through ``MalachiteSettingsView``.
    @objc func changeAspectFill() {
        UIView.animate(withDuration: 20) { [self] in
            if utilities.preferences.preview.aspect {
                cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
    }
    
    /// Function to dynamically change the auto exposure and ``exposureSlider`` values when toggling in ``MalachiteSettingsView``.
    @objc func changeExposureLimit() {
        guard let exposure = selectedDevice?.isExposureModeSupported(.continuousAutoExposure) else { return }
        do {
            try selectedDevice?.lockForConfiguration()
            defer { selectedDevice?.unlockForConfiguration() }
            if exposure { selectedDevice?.exposureMode = .continuousAutoExposure }
        } catch {
            utilities.debugNSLog("[Change Exposure Limit] Couldn't lock device for configuration")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.exposureSlider.value = 0.0
        }
    }
    
    @objc func changeContinuousAEAF() {
        guard let selectedDevice = self.selectedDevice else { return }
        utilities.function.continuousAEAF(device: selectedDevice)
    }
    
    @objc func changeAEAFRecognizer() {
        let tapGestureElements = utilities.preferences.userInterface.tapAndHold
        guard let currentGestureRecognizers = self.view.gestureRecognizers else { return }
        
        if tapGestureElements.contains("off") {
            if currentGestureRecognizers.contains(aeafRecognizer) {
                utilities.debugNSLog("[AE+AF] Disabling tap and hold gesture")
                self.view.removeGestureRecognizer(aeafRecognizer)
            }
        } else {
            if !currentGestureRecognizers.contains(aeafRecognizer) {
                utilities.debugNSLog("[AE+AF] Enabling tap and hold gesture")
                self.view.addGestureRecognizer(aeafRecognizer)
            }
        }
    }
    
    /// Function to change the video stabilization mode for the ``cameraPreview``.
    @objc func changeStabilizerMode() {
        if utilities.preferences.preview.stablize {
            if #available(iOS 17.0, *) {
                if ((selectedDevice?.activeFormat.isVideoStabilizationModeSupported(.previewOptimized)) != nil) {
                    utilities.debugNSLog("[Preview Stabilization] Enabling enhanced stabilization mode")
                    cameraPreview.connection!.preferredVideoStabilizationMode = .previewOptimized
                    return
                }
            }
            
            if ((selectedDevice?.activeFormat.isVideoStabilizationModeSupported(.standard)) != nil) {
                utilities.debugNSLog("[Preview Stabilization] Enabling standard stabilization mode")
                cameraPreview.connection!.preferredVideoStabilizationMode = .standard
            }
        } else {
            cameraPreview.connection!.preferredVideoStabilizationMode = .off
        }
    }
    
    /// Function to present ``MalachiteSettingsView``
    @objc func presentSettingsView() {
#if APP_EXTENSION
        utilities.debugNSLog("[Settings] Attempt to access Settings UI from app extension")
        let alert = utilities.views.createAlertController(title: "alert.title.app_extensions.settings", message: "alert.detail.app_extensions.settings", button: settingsButton, defaultSet: true, action: { _ in
            self.utilities.debugNSLog("[Settings] Dialog has been dismissed")
        })
        self.present(alert, animated: true, completion: nil)
        return
#elseif MAIN_APP
        var aboutView = SettingsView(dismissAction: {self.dismiss( animated: true, completion: nil )})
        aboutView.utilities = self.utilities
        let hostingController = UIHostingController(rootView: aboutView)
        hostingController.modalPresentationStyle = UIModalPresentationStyle.popover
        hostingController.popoverPresentationController?.sourceView = settingsButton
        hostingController.isModalInPresentation = true
        if #available(iOS 26.0, *) {
            hostingController.preferredTransition = .zoom { [self] _ in
                settingsButton
            }
        }
        self.present(hostingController, animated: true, completion: nil)
#endif
    }
    
    /// Function to switch cameras and attach new inputs to ``cameraSession``, and set settings based on the `activeFormat` of ``selectedDevice``.
    @objc func runInputSwitch() {
        cameraSession?.beginConfiguration()
        cameraButton.isUserInteractionEnabled = false
        if (self.availableRearCameras.count < 2 || utilities.preferences.debug.breakApp) && !self.initRun  {
            utilities.debugNSLog("[Camera Input] Only one AVCaptureDevice is available to use, showing error")
            let alert = utilities.views.createAlertController(title: "alert.title.camera_switch", message: "alert.detail.camera_switch", button: cameraButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Camera Input] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
            cameraButton.isUserInteractionEnabled = true
            return
        }
            
        UIView.animate(withDuration: 0.5) {
            self.focusSlider.value = 0.0
            self.exposureSlider.value = 0.0
        }
        
        if cameraIndex != nil { selectedDevice = availableRearCameras[cameraIndex!] } else {
            if availableRearCameras.count > 1 && !initRun {
                if let devicePosition = availableRearCameras.firstIndex(of: selectedDevice!) {
                    if devicePosition == (availableRearCameras.count - 1) {
                        selectedDevice = availableRearCameras[0]
                    } else {
                        selectedDevice = availableRearCameras[devicePosition + 1]
                    }
                }
            }
        }
        
        utilities.function.switchInput(session: &cameraSession!,
                                       cameras: availableRearCameras,
                                       device: &selectedDevice,
                                       output: &photoOutput,
                                       input: &selectedInput,
                                       button: cameraButton,
                                       firstRun: &initRun)
        
        
        if #available(iOS 18.0, *) {
            if utilities.versionType == "INTERNAL" && utilities.preferences.evaintrnl.cameraControlEnabled {
                self.controlLayer!.initCameraControl()
            }
        }
        
        cameraSession?.commitConfiguration()
        
        DispatchQueue.main.async() { [self] in
            self.controlLayer!.initTooltips(showLabels: false, showCamera: true)
        }
        
        cameraButton.isUserInteractionEnabled = true
    }
    
    @objc func runInputMegapixelSwitch() {
        guard let selectedDevice = self.selectedDevice else { return }
        utilities.function.switchInputMegapixels(device: selectedDevice, photoOutput: self.photoOutput)
    }
    
    /// Function to toggle the flashlight's on state.
    @objc func runFlashlightToggle() {
        guard let flashlight = selectedDevice?.isFlashAvailable else { return }
        if flashlight && !utilities.preferences.debug.breakApp {
            utilities.function.toggleFlash(captureDevice: &selectedDevice!,
                                           flashlightButton: flashlightButton,
                                           floater: flashFloater,
                                           isFlashOn: &flashStatus)
        } else {
            utilities.debugNSLog("[Flashlight] No flashlight available")
            let alert = utilities.views.createAlertController(title: "alert.title.flashlight", message: "alert.detail.flashlight", button: flashlightButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Flashlight] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to take an image.
    @objc func runImageCapture() {
        self.captureButton.isEnabled = false
        progressIndicator = UIActivityIndicatorView(frame: self.captureButton.frame)
        self.view.addSubview(progressIndicator)
        self.captureButton.setImage(nil, for: .normal)
        progressIndicator.startAnimating()
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if (status == .authorized || status == .limited) && !utilities.preferences.debug.breakApp {
            self.photoOutput = utilities.function.captureImage(output: self.photoOutput, viewForBounds: self.view, captureDelegate: self)
        } else {
            utilities.debugNSLog("[Capture Photo] PHPhotoLibrary not authorized, showing error")
            let alert = utilities.views.createAlertController(title: "alert.title.phphotolibrary", message: "alert.detail.phphotolibrary", button: captureButton, defaultSet: true, action: { _ in
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
        if utilities.versionType == "INTERNAL" && utilities.preferences.preview.fastPath {
            photoPreview.savePhoto(finalImage: photoPreview.finalizeImageForExport(imageData: imageData))
        } else {
            let navigationController = UINavigationController(rootViewController: photoPreview)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            navigationController.isModalInPresentation = true
            navigationController.isNavigationBarHidden = true
            navigationController.popoverPresentationController?.sourceView = captureButton
            if #available(iOS 26.0, *) {
                navigationController.preferredTransition = .zoom { [self] _ in captureButton }
            }
            self.present(navigationController, animated: true, completion: nil)
            NotificationCenter.default.addObserver(photoPreview, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        self.captureButton.isEnabled = true
        self.captureButton.setImage(UIImage(systemName: "camera.aperture"), for: .normal)
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
        utilities.function.zoom(sender: zoomRecognizer,
                                floater: &zoomFloater,
                                captureDevice: &selectedDevice!,
                                lastZoomFactor: &lastZoomFactor,
                                hapticClass: utilities.haptics)
    }
    
    /// Function to autofocus + autoexposure with ``aeafRecognizer``.
    @objc func runaeafController() {
        guard var selectedDevice = self.selectedDevice else { return }
        utilities.function.pointOfInterestAEAF(sender: aeafRecognizer,
                                     captureDevice: &selectedDevice,
                                     button: aeafFeedback,
                                     viewForScale: self.view,
                                     hapticClass: utilities.haptics)
    }
    
    /// Function to handle ``exposureSlider`` interaction.
    @objc func runManualExposureController() {
        guard let exposure = selectedDevice?.isExposureModeSupported(.custom) else { return }
        if exposure && !utilities.preferences.debug.breakApp {
            utilities.function.manualExposure(captureDevice: &selectedDevice!,
                                              sender: exposureSlider)
        } else {
            utilities.debugNSLog("[Manual Exposure] Current camera is not capable of adjusting exposure")
            let alert = utilities.views.createAlertController(title: "alert.title.exposure", message: "alert.detail.exposure", button: exposureButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to show and hide the ``exposureSliderButton`` and ``exposureLockButton``.
    @objc func runManualExposureUIHider() {
        guard let exposure = selectedDevice?.isExposureModeSupported(.custom) else { return }
        if exposure && !utilities.preferences.debug.breakApp {
            manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualExposureSliderIsActive,
                                                                                optionButton: exposureButton,
                                                                                lockButton: exposureLockButton,
                                                                                associatedSliderButton: exposureSliderButton)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting exposure")
            let alert = utilities.views.createAlertController(title: "alert.title.exposure", message: "alert.detail.exposure", button: exposureButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func runManualExposureUIHiderWhenUnsupported() {
        if manualExposureSliderIsActive {
            manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualExposureSliderIsActive,
                                                                                optionButton: exposureButton,
                                                                                lockButton: exposureLockButton,
                                                                                associatedSliderButton: exposureSliderButton)
        } else {
            manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: true,
                                                                                optionButton: exposureButton,
                                                                                lockButton: exposureLockButton,
                                                                                associatedSliderButton: exposureSliderButton)
        }
    }
    
    /// Function to lock and unlock the ``exposureSlider``.
    @objc func runManualExposureLockController() {
        manualExposureLockIsActive = utilities.views.runLockControllers(lockIsActive: manualExposureLockIsActive,
                                                                        lockButton: &exposureLockButton,
                                                                        associatedSlider: &exposureSlider,
                                                                        associatedGestureRecognizer: nil,
                                                                        viewForRecognizers: self.view)
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusController() {
        guard let focus = selectedDevice?.isLockingFocusWithCustomLensPositionSupported else { return }
        if focus && !utilities.preferences.debug.breakApp {
            utilities.function.manualFocus(captureDevice: &selectedDevice!,
                                           sender: focusSlider,
                                           floater: focusFloater ?? focusSlider.value)
        } else {
            #warning("refactor to call unsupported codepath")
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = utilities.views.createAlertController(title: "alert.title.focus", message: "alert.detail.focus", button: focusButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusUIHider() {
        guard let focus = selectedDevice?.isLockingFocusWithCustomLensPositionSupported else { return }
        if focus && !utilities.preferences.debug.breakApp {
        manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualFocusSliderIsActive,
                                                                         optionButton: focusButton,
                                                                         lockButton: focusLockButton,
                                                                         associatedSliderButton: focusSliderButton)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = utilities.views.createAlertController(title: "alert.title.focus", message: "alert.detail.focus", button: focusButton, defaultSet: true, action: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func runManualFocusUIHiderWhenUnsupported() {
        if manualFocusSliderIsActive {
            manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualFocusSliderIsActive,
                                                                             optionButton: focusButton,
                                                                             lockButton: focusLockButton,
                                                                             associatedSliderButton: focusSliderButton)
        } else {
            manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: true,
                                                                             optionButton: focusButton,
                                                                             lockButton: focusLockButton,
                                                                             associatedSliderButton: focusSliderButton)
        }
    }
    
    /// Function to show and hide the ``focusSliderButton`` and ``focusLockButton``.
    @objc func runManualFocusLockController() {
        manualFocusLockIsActive = utilities.views.runLockControllers(lockIsActive: manualFocusLockIsActive,
                                                                     lockButton: &focusLockButton,
                                                                     associatedSlider: &focusSlider,
                                                                     associatedGestureRecognizer: aeafRecognizer,
                                                                    viewForRecognizers: self.view)
    }
    
    /// Function to handle device rotation.
    #warning("refactor to view utils")
    @objc func orientationChanged() {
        utilities.views.rotateButtonsWithOrientation(buttonsToRotate: [ cameraButton,
                                                                        flashlightButton,
                                                                        captureButton,
                                                                        settingsButton,
                                                                        focusButton,
                                                                        focusLockButton,
                                                                        exposureButton,
                                                                        exposureLockButton ])
    }
}

