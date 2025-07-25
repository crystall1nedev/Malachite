//
//  ViewController.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/25/23.
//

import SwiftUI
import UIKit
import Foundation
import AVFoundation
import AVKit
import LockedCameraCapture
import Photos
import GameKit

struct MalachiteView_SwiftUIWrapped: UIViewControllerRepresentable {
    let rootURL: URL?
    typealias UIViewControllerType = MalachiteView
    func makeUIViewController(context: Self.Context) -> MalachiteView {
        return MalachiteView()
    }
 
    func updateUIViewController(_ uiViewController: MalachiteView, context: Self.Context) {
    }
}

@available(iOS 18.0, *)
extension MalachiteView_SwiftUIWrapped {
    init(_ session: LockedCameraCaptureSession) {
        self.rootURL = session.sessionContentURL
    }
}

class MalachiteView: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate, AVCaptureSessionControlsDelegate {
    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        if !uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
        if !uiIsHidden { runUIHider() }
    }
    
    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
        if uiIsHidden { runUIHider() }
    }
    
    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        if uiIsHidden { runUIHider() }
        if cameraIndex != nil {
            runInputSwitch()
            self.cameraIndex = nil
        }
    }
    
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
    var cameraPreview: AVCaptureVideoPreviewLayer?
    /// A `Bool` that determines whether or not the wide angle lens is in use.
    var wideAngleInUse = true
    /// A `Bool` that determines whether or not the app is still initializing. Uses for tasks that should only be run once at the start of Malachite.
    var initRun = true
    /// A `CGFloat` that temporarily holds the zoom factor.
    var zoomFloater: CGFloat?
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
    
    var cameraView = UIView()
    
    /**
     viewDidLoad override for the main user interface.
     
     This function currently serves to do the following:
     - Create and assign a value to all variables needed to run ``cameraSession`` and its preview layer, ``cameraPreview``.
     - Read the user's preferences to determine the preview layer's aspect ratio.
     - Register notifications for changes to certain options in ``MalachiteSettingsView``, as well as orientation changes.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        utilities.debugNSLog("[Initialization] Starting up Malachite")
        
        if utilities.versionType == "INTERNAL" {
            utilities.internalNSLog("[Initialization] Running an INTERNAL build, logging will be force enabled")
        } else if utilities.versionType == "DEBUG" {
            utilities.debugNSLog("[Initialization] Running a DEBUG build, logging will be force enabled")
        } else if utilities.versionType == "RELEASE" {
            utilities.NSLog("[Initialization] Running a RELEASE build")
        }
        
        #if APP_EXTENSION
        utilities.debugNSLog("[Initialization] Running out of an app extension.")
        #elseif MAIN_APP
        utilities.debugNSLog("[Initialization] Running out of the main app.")
        #endif
        
        if utilities.versionType == "INTERNAL" {
            if !utilities.preferences.ext.deviceModel.isSameDevice(in: &utilities.preferences) {
                utilities.internalNSLog("[Initialization] This is a new device, rechecking compatibility.")
                utilities.preferences.general.deviceModel = utilities.preferences.ext.deviceModel.get()
            } else {
                utilities.internalNSLog("[Initialization] This is the same device, can skip compatibility checks.")
            }
        }
        
        if !utilities.function.supportsHEIC() {
            utilities.debugNSLog("[Initialization] HEIF enabled on a device that doesn't support it, disabling")
            utilities.preferences.capture.format.heic = false
            utilities.preferences.capture.format.jpeg = true
        }
        
        cameraPreview?.frame.size = self.view.frame.size
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = AVCaptureSession()
        
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        
        utilities.debugNSLog("[Camera Input] Getting current camera system capabilities")
        
        var camerasToDiscover: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 17.0, *) { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera, .continuityCamera, .external] }
        else { camerasToDiscover = [.builtInUltraWideCamera, .builtInWideAngleCamera, .builtInTelephotoCamera] }
        
        utilities.debugNSLog("[Camera Input] Discovering available cameras")
        let currentProcess = ProcessInfo()
        AVCaptureDevice.DiscoverySession.init(deviceTypes: camerasToDiscover, mediaType: .video, position: (currentProcess.isiOSAppOnMac || currentProcess.isMacCatalystApp) ? .unspecified : .back).devices.forEach { device in
            self.availableRearCameras.append(device)
            utilities.debugNSLog("[Camera Input] \(device.localizedName)")
            utilities.debugNSLog("[Camera Input] \(device.deviceType.rawValue) available")
        }
        
        runInputSwitch()
        
        if #available(iOS 18.0, *) {
            cameraSession?.setControlsDelegate(self, queue: utilities.sessionQueue)
        }
        
        if self.availableRearCameras.first != nil {
            photoOutput = AVCapturePhotoOutput()
            if #available(iOS 16.0, *) {} else { photoOutput.isHighResolutionCaptureEnabled = true }
            photoOutput.maxPhotoQualityPrioritization = .quality
            cameraSession?.sessionPreset = AVCaptureSession.Preset.photo
            cameraSession?.addOutput(photoOutput)
            
            utilities.debugNSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
            cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
            
            #if MAIN_APP
            let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.portrait
            #else
            let statusBarOrientation = UIInterfaceOrientation.portrait
            #endif
            let videoOrientation: AVCaptureVideoOrientation = (statusBarOrientation.videoOrientation)
            cameraPreview?.frame = view.layer.bounds
            cameraPreview?.connection?.videoOrientation = videoOrientation
            
            if utilities.preferences.preview.aspect {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
            }
            
            cameraView = UIView(frame: self.view.bounds)
            cameraView.layer.addSublayer(cameraPreview!)
            self.view.insertSubview(cameraView, at: 0)
            
            utilities.debugNSLog("[Initialization] Starting session stream")
            DispatchQueue.global(qos: .background).async {
                self.cameraSession?.startRunning()
            }
        } else {
            utilities.debugNSLog("[Initialization] No cameras detected, skipping to user interface bringup")
        }
        
        utilities.debugNSLog("[Initialization] Setting up notification observer for orientation changes")
        #if MAIN_APP
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(changeAspectFill), name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeExposureLimit), name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStabilizerMode), name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeGameCenterEnabled), name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(runManualExposureUIHiderWhenUnsupported), name: MalachiteFunctionUtils.Notifications.unsupportedISOValueNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(runManualFocusUIHiderWhenUnsupported), name: MalachiteFunctionUtils.Notifications.unsupportedLensPositionNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeContinuousAEAF), name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAEAFRecognizer), name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeIdleTimerState), name: MalachiteFunctionUtils.Notifications.idleTimerNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(runInputMegapixelSwitch), name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        if utilities.versionType == "INTERNAL" || utilities.versionType == "DEBUG" {
            if utilities.preferences.debug.logging.preferences {
                MalachitePreferencesUtils().printPreferences()
            }
        }
        
        if #available (iOS 17.2, *) {
            let interaction = AVCaptureEventInteraction { event in
                if event.phase == .ended {
                    self.runImageCapture()
                }
            }
            self.view.addInteraction(interaction)
            eventInteraction = interaction
        }
        
        
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
        setupView()
        if utilities.versionType == "INTERNAL" {
            setupView_INTERNAL()
        }
        
        self.changeGameCenterEnabled()
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
        settingsRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(runSettingsGesture))
        updateSettingsGestureFingerCount()
        settingsRecognizer.direction = .up
        
        self.view.addGestureRecognizer(settingsRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettingsGestureFingerCount), name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
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
        self.view.backgroundColor = .black
        
#if targetEnvironment(simulator)
        setupLmaoView()
#endif
        
        cameraButton = utilities.views.returnProperButton(symbolName: "camera", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        
        flashlightButton = utilities.views.returnProperButton(symbolName: "flashlight.off.fill", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        captureButton = utilities.views.returnProperButton(symbolName: "camera.aperture", cornerRadius: 45, viewForBounds: view, hapticClass: utilities.haptics)
        focusButton = utilities.views.returnProperButton(symbolName: "scope", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        focusSliderButton = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        focusLockButton = utilities.views.returnProperButton(symbolName: "lock.open", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        exposureButton = utilities.views.returnProperButton(symbolName: "plusminus", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        exposureSliderButton = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        exposureLockButton = utilities.views.returnProperButton(symbolName: "lock.open", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        settingsButton = utilities.views.returnProperButton(symbolName: "gear", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        aeafFeedback = utilities.views.returnProperButton(symbolName: "", cornerRadius: 60, viewForBounds: self.view, hapticClass: utilities.haptics)
        currentCamera = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: self.view, hapticClass: nil)
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        exposureSlider.translatesAutoresizingMaskIntoConstraints = false
        focusLockButton.alpha = 0.0
        exposureLockButton.alpha = 0.0
        aeafFeedback.alpha = 0.0
        
        self.view.addSubview(cameraButton)
        self.view.addSubview(flashlightButton)
        self.view.addSubview(captureButton)
        self.view.addSubview(focusButton)
        self.view.addSubview(focusSliderButton)
        self.view.addSubview(focusLockButton)
        self.view.addSubview(exposureButton)
        self.view.addSubview(exposureSliderButton)
        self.view.addSubview(exposureLockButton)
        self.view.addSubview(settingsButton)
        self.view.addSubview(aeafFeedback)
        self.view.addSubview(currentCamera)
        focusSliderButton.addSubview(focusSlider)
        exposureSliderButton.addSubview(exposureSlider)
        
        if self.availableRearCameras.count > 0 {
            cameraButton.addTarget(self, action: #selector(self.runInputSwitch), for: .touchUpInside)
            flashlightButton.addTarget(self, action: #selector(self.runFlashlightToggle), for: .touchUpInside)
            captureButton.addTarget(self, action: #selector(self.runImageCapture), for: .touchUpInside)
            focusSlider.addTarget(self, action: #selector(self.runManualFocusController), for: .valueChanged)
            focusSlider.addTarget(utilities.haptics, action: #selector(utilities.haptics.buttonMediumHaptics(_:)), for: .touchUpInside)
            focusLockButton.addTarget(self, action: #selector(runManualFocusLockController), for: .touchUpInside)
            exposureSlider.addTarget(self, action: #selector(runManualExposureController), for: .valueChanged)
            exposureSlider.addTarget(utilities.haptics, action: #selector(utilities.haptics.buttonMediumHaptics(_:)), for: .touchUpInside)
            exposureLockButton.addTarget(self, action: #selector(self.runManualExposureLockController), for: .touchUpInside)
        }
        
        focusButton.addTarget(self, action: #selector(self.runManualFocusUIHider), for: .touchUpInside)
        exposureButton.addTarget(self, action: #selector(self.runManualExposureUIHider), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(self.presentSettingsView), for: .touchUpInside)
        
        zoomRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(runZoomController))
        aeafRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runaeafController))
        uiHiderRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runUIHider))
        uiHiderRecognizer.numberOfTouchesRequired = 2
        
        
        focusTitle = utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: view, textForFlow: NSLocalizedString("uibutton.focus.title", comment: ""), anchorConstant: 10)
        exposureTitle = utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: view, textForFlow: NSLocalizedString("uibutton.exposure.title", comment: ""), anchorConstant: 80)
        
        self.view.addGestureRecognizer(zoomRecognizer)
        let tapGestureElements = utilities.preferences.userInterface.tapAndHold
        if !tapGestureElements.contains("off") { self.view.addGestureRecognizer(aeafRecognizer) }
        self.view.addGestureRecognizer(uiHiderRecognizer)
        
        var lockButtonsX = -80.0
        var lockButtonsY = 0.0
        
        if self.view.frame.size.width >= 370 {
            utilities.debugNSLog("[Initialization] Device screen is capable of displaying lock button inline")
            lockButtonsX = -300.0
        } else {
            // TODO: Make lock buttons not clip into other bars!
            NSLog("[Initialization] Device screen is too small for inline lock button")
            lockButtonsY = 70.0
        }
        
        utilities.tooltips.fadeOutTooltipFlow(labelsToFade: [ focusTitle, exposureTitle])
        utilities.tooltips.zoomTooltipFlow(button: currentCamera, viewForBounds: self.view, camera: selectedDevice)
        
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 60),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cameraButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            
            flashlightButton.widthAnchor.constraint(equalToConstant: 60),
            flashlightButton.heightAnchor.constraint(equalToConstant: 60),
            flashlightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            flashlightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            captureButton.widthAnchor.constraint(equalToConstant: 90),
            captureButton.heightAnchor.constraint(equalToConstant: 90),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            
            focusButton.widthAnchor.constraint(equalToConstant: 60),
            focusButton.heightAnchor.constraint(equalToConstant: 60),
            focusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            focusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            focusSliderButton.widthAnchor.constraint(equalToConstant: 210),
            focusSliderButton.heightAnchor.constraint(equalToConstant: 60),
            focusSliderButton.topAnchor.constraint(equalTo: focusButton.topAnchor),
            focusSliderButton.leadingAnchor.constraint(equalTo: focusButton.trailingAnchor, constant: 10),
            
            focusSlider.widthAnchor.constraint(equalToConstant: 180),
            focusSlider.heightAnchor.constraint(equalToConstant: 80),
            focusSlider.centerYAnchor.constraint(equalTo: focusSliderButton.centerYAnchor),
            focusSlider.centerXAnchor.constraint(equalTo: focusSliderButton.trailingAnchor, constant: -105),
            
            focusLockButton.widthAnchor.constraint(equalToConstant: 60),
            focusLockButton.heightAnchor.constraint(equalToConstant: 60),
            focusLockButton.topAnchor.constraint(equalTo: focusButton.topAnchor, constant: lockButtonsY),
            focusLockButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: lockButtonsX),
            
            exposureButton.widthAnchor.constraint(equalToConstant: 60),
            exposureButton.heightAnchor.constraint(equalToConstant: 60),
            exposureButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            exposureButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            exposureSliderButton.widthAnchor.constraint(equalToConstant: 210),
            exposureSliderButton.heightAnchor.constraint(equalToConstant: 60),
            exposureSliderButton.topAnchor.constraint(equalTo: exposureButton.topAnchor),
            exposureSliderButton.leadingAnchor.constraint(equalTo: exposureButton.trailingAnchor, constant: 10),
            
            exposureSlider.widthAnchor.constraint(equalToConstant: 180),
            exposureSlider.heightAnchor.constraint(equalToConstant: 80),
            exposureSlider.centerYAnchor.constraint(equalTo: exposureSliderButton.centerYAnchor),
            exposureSlider.centerXAnchor.constraint(equalTo: exposureSliderButton.trailingAnchor, constant: -105),
            
            exposureLockButton.widthAnchor.constraint(equalToConstant: 60),
            exposureLockButton.heightAnchor.constraint(equalToConstant: 60),
            exposureLockButton.topAnchor.constraint(equalTo: exposureButton.topAnchor, constant: lockButtonsY),
            exposureLockButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: lockButtonsX),
            
            currentCamera.widthAnchor.constraint(equalToConstant: 60),
            currentCamera.heightAnchor.constraint(equalToConstant: 60),
            currentCamera.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            currentCamera.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        ])
        
        if utilities.preferences.userInterface.appLaunch {
            cameraButton.alpha = 0.0
            flashlightButton.alpha = 0.0
            captureButton.alpha = 0.0
            focusButton.alpha = 0.0
            focusSliderButton.alpha = 0.0
            exposureButton.alpha = 0.0
            exposureSliderButton.alpha = 0.0
            settingsButton.alpha = 0.0
            currentCamera.alpha = 0.0
            focusTitle.alpha = 0.0
            exposureTitle.alpha = 0.0
            
            uiIsHidden = true
        }
        
        setupGameKitAlert()
        changeIdleTimerState()
    }
    
    func setupGameKitAlert() {
        if utilities.preferences.general.gamekit.alerted {
            let alert = UIAlertController(title: "alert.title.gamekit".localized, message: "alert.detail.gamekit".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.reopen", comment: "Default action"), style: .default, handler: { _ in
                exit(11)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.report", comment: "Default action"), style: .default, handler: { _ in
                guard let url = URL(string: "https://www.youtube.com/watch?v=At8v_Yc044Y") else {
                    return
                }
                #if MAIN_APP
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                #endif
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ignore", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.preferences.general.gamekit.alerted = false
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupLmaoView() {
        let lmaoView = UIImageView(image: utilities.views.returnImageForSimulator())
        self.view.addSubview(lmaoView)
        
        NSLayoutConstraint.activate([
            lmaoView.widthAnchor.constraint(equalToConstant: 60),
            lmaoView.heightAnchor.constraint(equalToConstant: 60),
            lmaoView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            lmaoView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
    }
    
    /// Function to enable or disable the idle timer.
    @objc func changeIdleTimerState() {
        #if MAIN_APP
        UIApplication.shared.isIdleTimerDisabled = utilities.preferences.userInterface.idleTimerDisabled
        #endif
    }
    
    /// Function to dynamically update the aspect ratio for ``cameraPreview`` through ``MalachiteSettingsView``.
    @objc func changeAspectFill() {
        UIView.animate(withDuration: 20) { [self] in
            if utilities.preferences.preview.aspect {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
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
        utilities.function.continuousAEAF(device: selectedDevice!)
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
                    cameraPreview?.connection!.preferredVideoStabilizationMode = .previewOptimized
                    return
                }
            }
            
            if ((selectedDevice?.activeFormat.isVideoStabilizationModeSupported(.standard)) != nil) {
                utilities.debugNSLog("[Preview Stabilization] Enabling standard stabilization mode")
                cameraPreview?.connection!.preferredVideoStabilizationMode = .standard
            }
        } else {
            cameraPreview?.connection!.preferredVideoStabilizationMode = .off
        }
    }
    
    /// Function to change the GameKit enabled state.
    @objc func changeGameCenterEnabled() {
        DispatchQueue.global(qos: .background).async { [self] in
            if utilities.preferences.general.gamekit.enabled {
                utilities.games.setupGameCenter()
            }
        }
    }
    
    /// Function to present ``MalachiteSettingsView``
    @objc func presentSettingsView() {
        var aboutView = MalachiteSettingsView(dismissAction: {self.dismiss( animated: true, completion: nil )})
        aboutView.utilities = self.utilities
        let hostingController = UIHostingController(rootView: aboutView)
        hostingController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(hostingController, animated: true, completion: nil)
    }
    
    /// Function to switch cameras and attach new inputs to ``cameraSession``, and set settings based on the `activeFormat` of ``selectedDevice``.
    @objc func runInputSwitch() {
        cameraSession?.beginConfiguration()
        DispatchQueue.main.async() { [self] in
            if self.availableRearCameras.count == 1 && !initRun{
                utilities.debugNSLog("[Camera Input] Only one AVCaptureDevice is available to use, showing error")
                let alert = UIAlertController(title: "alert.title.camera_switch".localized, message: "alert.detail.camera_switch".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "alert.button.ok".localized, style: .default, handler: { _ in
                    self.utilities.debugNSLog("[Camera Input] Dialog has been dismissed")
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            UIView.animate(withDuration: 0.5) {
                self.focusSlider.value = 0.0
                self.exposureSlider.value = 0.0
            }
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
        
        
        if #available(iOS 18.0, *) { addControls() }
        
        cameraSession?.commitConfiguration()
        
        DispatchQueue.main.async() { [self] in
            utilities.tooltips.zoomTooltipFlow(button: currentCamera, viewForBounds: view, camera: selectedDevice)
        }
    }
    
    @available(iOS 18.0, *)
    func addControls() {
        guard cameraSession!.supportsControls else { return }
        
        let systemBiasSlider = AVCaptureSystemExposureBiasSlider(device: selectedDevice!)
        
        let zoomSlider = AVCaptureSlider("Zoom", symbolName: "plus.viewfinder", in: 1.0...Float(MalachiteClassesObject().preferences.capture.maximumZoom))
        zoomSlider.setActionQueue(utilities.sessionQueue) { position in
            self.zoomFloater = CGFloat(position)
            self.runZoomController()
            self.zoomFloater = nil
        }
        
        let focusSlider = AVCaptureSlider("Focus", symbolName: "scope", in: 0.0...1.0)
        focusSlider.setActionQueue(utilities.sessionQueue) { position in
            self.focusFloater = position
            self.runManualFocusController()
            self.focusFloater = nil
        }
        
        let cameraSwitcher = AVCaptureIndexPicker("Cameras", symbolName: "camera.fill", localizedIndexTitles: self.availableRearCameras.map { $0.localizedName } )
        cameraSwitcher.selectedIndex = self.availableRearCameras.firstIndex(of: self.selectedDevice!)!
        cameraSwitcher.setActionQueue(utilities.sessionQueue) { index in
            self.cameraIndex = index
        }
        
        let flashSwitcher = AVCaptureIndexPicker("Flash", symbolName: "bolt.fill", numberOfIndexes: 2, localizedTitleTransform: { index in
            switch index {
            case 0: return NSLocalizedString("flash.off", comment: "Off")
            case 1: return NSLocalizedString("flash.on", comment: "On")
            default: return ""
            }
        })
        flashSwitcher.setActionQueue(utilities.sessionQueue) { index in
            flashSwitcher.selectedIndex = self.flashStatus ? 1 : 0
            self.runFlashlightToggle()
            flashSwitcher.selectedIndex = self.flashStatus ? 1 : 0
        }
        
        let flashSlider = AVCaptureSlider("Flash Level", symbolName: "lightbulb.fill", in: 0.0...1.0)
        flashSlider.setActionQueue(utilities.sessionQueue) { position in
            if (position == 0.0 && self.flashStatus) || (position != 0.0 && !self.flashStatus) {
                self.flashFloater = position
                self.runFlashlightToggle()
                self.flashFloater = nil
                flashSwitcher.selectedIndex = self.flashStatus ? 1 : 0
            } else {
                self.utilities.function.flashLevelTest(captureDevice: self.selectedDevice!, floater: position)
            }
        }
        
        utilities.function.addControlsToSession(session: &cameraSession!, controls: [ zoomSlider, focusSlider, cameraSwitcher, flashSwitcher, flashSlider, systemBiasSlider])
    }
    
    @objc func runInputMegapixelSwitch() {
        utilities.function.switchInputMegapixels(device: selectedDevice!, photoOutput: self.photoOutput)
    }
    
    /// Function to toggle the flashlight's on state.
    @objc func runFlashlightToggle() {
        guard let flashlight = selectedDevice?.hasFlash else { return }
        if flashlight {
            utilities.function.toggleFlash(captureDevice: &selectedDevice!,
                                           flashlightButton: flashlightButton,
                                           floater: flashFloater,
                                           isFlashOn: &flashStatus)
        } else {
            utilities.debugNSLog("[Flashlight] No flashlight available")
            let alert = UIAlertController(title: "alert.title.flashlight".localized, message: "alert.detail.flashlight".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Flashlight] Dialog has been dismissed")
            }))
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
        
        if status == .authorized || status == .limited {
            self.photoOutput = utilities.function.captureImage(output: self.photoOutput, viewForBounds: self.view, captureDelegate: self)
        } else {
            utilities.debugNSLog("[Capture Photo] PHPhotoLibrary not authorized, showing error")
            let alert = UIAlertController(title: "alert.title.phphotolibrary".localized, message: "alert.detail.phphotolibrary".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Capture Photo] Dialog has been dismissed")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function for opening ``MalachitePhotoPreview`` and running GameKit commands after photo processing is completed.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let getterForOrientation = UIImage(data: imageData)
        let previewImage = UIImage(ciImage: CIImage(data: imageData, options: [.applyOrientationProperty: true,
                                                                               .properties: [kCGImagePropertyOrientation: CGImagePropertyOrientation(getterForOrientation!.imageOrientation).rawValue]])!)
        let photoPreview = MalachitePhotoPreview()
        photoPreview.photoImageData = imageData
        photoPreview.photoImageView.frame = view.frame
        photoPreview.photoImage = previewImage
        let navigationController = UINavigationController(rootViewController: photoPreview)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        navigationController.isModalInPresentation = true
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true, completion: nil)
        NotificationCenter.default.addObserver(photoPreview, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
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
                                floater: zoomFloater ?? zoomRecognizer.scale,
                                captureDevice: &selectedDevice!,
                                lastZoomFactor: &lastZoomFactor,
                                hapticClass: utilities.haptics)
    }
    
    /// Function to autofocus + autoexposure with ``aeafRecognizer``.
    @objc func runaeafController() {
        utilities.function.pointOfInterestAEAF(sender: aeafRecognizer,
                                     captureDevice: &selectedDevice!,
                                     button: aeafFeedback,
                                     viewForScale: self.view,
                                     hapticClass: utilities.haptics)
    }
    
    /// Function to handle ``exposureSlider`` interaction.
    @objc func runManualExposureController() {
        guard let exposure = selectedDevice?.isExposureModeSupported(.custom) else { return }
        if exposure {
            utilities.function.manualExposure(captureDevice: &selectedDevice!,
                                              sender: exposureSlider)
        } else {
            utilities.debugNSLog("[Manual Exposure] Current camera is not capable of adjusting exposure")
            let alert = UIAlertController(title: "alert.title.exposure".localized, message: "alert.detail.exposure".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to show and hide the ``exposureSliderButton`` and ``exposureLockButton``.
    @objc func runManualExposureUIHider() {
        guard let exposure = selectedDevice?.isExposureModeSupported(.custom) else { return }
        if exposure {
            manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualExposureSliderIsActive,
                                                                                optionButton: exposureButton,
                                                                                lockButton: exposureLockButton,
                                                                                associatedSliderButton: exposureSliderButton)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting exposure")
            let alert = UIAlertController(title: "alert.title.exposure".localized, message: "alert.detail.exposure".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Manual Exposure] Dialog has been dismissed")
            }))
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
        if focus {
            utilities.function.manualFocus(captureDevice: &selectedDevice!,
                                           sender: focusSlider,
                                           floater: focusFloater ?? focusSlider.value)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = UIAlertController(title: "alert.title.focus".localized, message: "alert.detail.focus".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusUIHider() {
        guard let focus = selectedDevice?.isLockingFocusWithCustomLensPositionSupported else { return }
        if focus {
        manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualFocusSliderIsActive,
                                                                         optionButton: focusButton,
                                                                         lockButton: focusLockButton,
                                                                         associatedSliderButton: focusSliderButton)
        } else {
            utilities.debugNSLog("[Manual Focus] Current camera is not capable of adjusting focus")
            let alert = UIAlertController(title: "alert.title.focus".localized, message: "alert.detail.focus".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.debugNSLog("[Manual Focus] Dialog has been dismissed")
            }))
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
    
    @objc func updateSettingsGestureFingerCount() {
        settingsRecognizer.numberOfTouchesRequired = utilities.preferences.evaintrnl.settingsGesture
    }
    
    @objc func runSettingsGesture() {
        if settingsRecognizer.state == UIGestureRecognizer.State.ended {
            self.presentSettingsView()
        }
    }
    
    /// Function to show and hide the user interface that was drawn with ``setupView()``.
    @objc func runUIHider() {
        if uiHiderRecognizer.state == UITapGestureRecognizer.State.ended || uiHiderRecognizer.state == UITapGestureRecognizer.State.changed  { return }
        
        let gestureRecognizers = [ zoomRecognizer, aeafRecognizer ]
        
        DispatchQueue.main.async { [self] in
            if !uiIsHidden {
                hideUI()
            } else {
                showUI()
                utilities.tooltips.zoomTooltipFlow(button: currentCamera, viewForBounds: self.view, camera: selectedDevice)
            }

            uiIsHidden = !uiIsHidden
            utilities.haptics.triggerNotificationHaptic(type: .success)
        }
        
        func hideUI() {
            UIView.animate(withDuration: 0.25) { [self] in
                for subview in self.view.subviews {
                    if subview != cameraView {
                        if subview == focusLockButton {
                            if manualFocusSliderIsActive { subview.alpha = 0.0 }
                        } else if subview == exposureLockButton {
                            if manualExposureSliderIsActive { subview.alpha = 0.0 }
                        } else {
                            subview.alpha = 0.0
                        }
                    }
                }
            }
            let hiddenRecognizers = utilities.preferences.userInterface.hiddenControls
            for gestureRecognizer in gestureRecognizers {
                if gestureRecognizer == zoomRecognizer && !hiddenRecognizers.contains("zoom") { self.view.removeGestureRecognizer(gestureRecognizer) }
                if gestureRecognizer == aeafRecognizer && !hiddenRecognizers.contains("tah") { self.view.removeGestureRecognizer(gestureRecognizer) }
            }
        }
        
        func showUI() {
            UIView.animate(withDuration: 0.25) { [self] in
                for subview in self.view.subviews {
                    if subview != cameraView {
                        if subview == focusLockButton {
                            if manualFocusSliderIsActive { subview.alpha = 1.0 }
                        } else if subview == exposureLockButton {
                            if manualExposureSliderIsActive { subview.alpha = 1.0 }
                        } else {
                            subview.alpha = 1.0
                        }
                    }
                }
            }
            
            for gestureRecognizer in gestureRecognizers {
                guard let currentRecognizers = self.view.gestureRecognizers else { return }
                if !currentRecognizers.contains(gestureRecognizer) {
                    self.view.addGestureRecognizer(gestureRecognizer)
                }
            }
        }
    }
    
    /// Function to handle device rotation.
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
    
    /// Override function to force the status bar to never be shown.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// Override function to force the app to be in portrait mode on iPhone.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if utilities.idiom == .phone {
            return .portrait
        }
        
        return .all
    }
    
    /// Override function to force the system to reject gestures from the bottom of the screen.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    /// Override function for layoutSubviews.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cameraView.center = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
        cameraView.frame = self.view.bounds
    }
    
    #if MAIN_APP
    /// Override function to trigger actions when the screen rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [self] context in
            #if MAIN_APP
            self.cameraPreview?.connection!.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.windows.first!.windowScene!.interfaceOrientation.rawValue)!)
            #endif
            self.cameraPreview?.frame.size = self.view.frame.size
        })
    }
    #endif
}

