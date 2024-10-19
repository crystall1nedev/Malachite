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
import Photos
import GameKit

class MalachiteView: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
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
    var photoOutput: AVCapturePhotoOutput?
    /// The `AVCaptureVideoPreviewLayer` used to allow users to see a preview of their camera before taking a shot with ``photoOutput``.
    var cameraPreview: AVCaptureVideoPreviewLayer?
    /// A `Bool` that determines whether or not the wide angle lens is in use.
    var wideAngleInUse = true
    /// A `Bool` that determines whether or not the app is still initializing. Uses for tasks that should only be run once at the start of Malachite.
    var initRun = true
    
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
    /// A `UIButton` that enables the user to toggle the lock states for the ``focusSlider`` and the ``autofocusRecognizer``.
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
    /// A `UILongPressGestureRecognizer` that handles enabling the autofocus system at a specific point on the display for the ``cameraSession``.
    var autofocusRecognizer = UILongPressGestureRecognizer()
    /// A `UIButton` that contains the blur for the on-screen feedback produced by the auto focus gesture.
    private var autofocusFeedback = UIButton()
    /// A `UILongPressGestureRecognizer` that handles hiding all elements of the user interface, and disabling the ``zoomRecognizer`` and ``autofocusRecognizer`` gestures.
    var uiHiderRecognizer = UILongPressGestureRecognizer()
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
        
        NSLog("[Initialization] Starting up Malachite")
        
        if utilities.versionType == "INTERNAL" {
            utilities.internalNSLog("[Initialization] Running an INTERNAL build, logging will be force enabled")
        } else if utilities.versionType == "DEBUG" {
            utilities.debugNSLog("[Initialization] Running a DEBUG build, logging will be force enabled")
        } else if utilities.versionType == "RELEASE" {
            utilities.NSLog("[Initialization] Running a RELEASE build")
        }
        
        if !utilities.function.supportsHEIC() {
            utilities.debugNSLog("[Initialization] HEIF enabled on a device that doesn't support it, disabling")
            utilities.settings.defaults.set(true, forKey: "format.type.jpeg")
            utilities.settings.defaults.set(false, forKey: "format.type.heif")
        }
        

        cameraPreview?.frame.size = self.view.frame.size
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = AVCaptureSession()
        
        utilities.debugNSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        
        utilities.debugNSLog("[Camera Input] Getting current camera system capabilities")
        
        var camerasToDiscover : [AVCaptureDevice.DeviceType] = []
        if #available(iOS 17.0, *) {
            camerasToDiscover = [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .external]
        } else {
            camerasToDiscover = [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera]
        }
        
        AVCaptureDevice.DiscoverySession.init(deviceTypes: camerasToDiscover, mediaType: .video, position: .back).devices.forEach { device in
            self.availableRearCameras.append(device)
            utilities.debugNSLog("[Camera Input] \(device.deviceType.rawValue) available")
        }
        
        runInputSwitch()

        if self.availableRearCameras.first != nil {
            
            let photoOutput = AVCapturePhotoOutput()
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            cameraSession?.sessionPreset = AVCaptureSession.Preset.photo
            cameraSession?.addOutput(photoOutput)
            self.photoOutput = photoOutput
            
            utilities.debugNSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
            cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
            
            let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
            let videoOrientation: AVCaptureVideoOrientation = (statusBarOrientation?.videoOrientation)!
            cameraPreview?.frame = view.layer.bounds
            cameraPreview?.connection?.videoOrientation = videoOrientation
            
            if utilities.settings.defaults.bool(forKey: "format.preview.fill") {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
            }
            
            //cameraPreview?.connection?.videoOrientation = transformOrientation(orientation: .portrait)
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
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAspectFill), name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeExposureLimit), name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStabilizerMode), name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeGameCenterEnabled), name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // TODO: Separate debug and release builds
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
     - ``autofocusRecognizer`` - Tap and hold with one finger
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
        focusButton = utilities.views.returnProperButton(symbolName: "viewfinder", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        focusSliderButton = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        focusLockButton = utilities.views.returnProperButton(symbolName: "lock.open", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        exposureButton = utilities.views.returnProperButton(symbolName: "eye", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        exposureSliderButton = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        exposureLockButton = utilities.views.returnProperButton(symbolName: "lock.open", cornerRadius: 30, viewForBounds: view, hapticClass: utilities.haptics)
        settingsButton = utilities.views.returnProperButton(symbolName: "gear", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        autofocusFeedback = utilities.views.returnProperButton(symbolName: "", cornerRadius: 60, viewForBounds: self.view, hapticClass: utilities.haptics)
        currentCamera = utilities.views.returnProperButton(symbolName: "", cornerRadius: 30, viewForBounds: self.view, hapticClass: nil)
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        exposureSlider.translatesAutoresizingMaskIntoConstraints = false
        focusLockButton.alpha = 0.0
        exposureLockButton.alpha = 0.0
        autofocusFeedback.alpha = 0.0
        
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
        self.view.addSubview(autofocusFeedback)
        self.view.addSubview(currentCamera)
        focusSliderButton.addSubview(focusSlider)
        exposureSliderButton.addSubview(exposureSlider)
        
#if !targetEnvironment(simulator)
        cameraButton.addTarget(self, action: #selector(self.runInputSwitch), for: .touchUpInside)
        flashlightButton.addTarget(self, action: #selector(self.runFlashlightToggle), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(self.runImageCapture), for: .touchUpInside)
        focusSlider.addTarget(self, action: #selector(self.runManualFocusController), for: .valueChanged)
        focusSlider.addTarget(utilities.haptics, action: #selector(utilities.haptics.buttonMediumHaptics(_:)), for: .touchUpInside)
        focusLockButton.addTarget(self, action: #selector(runManualFocusLockController), for: .touchUpInside)
        exposureSlider.addTarget(self, action: #selector(runManualExposureController), for: .valueChanged)
        exposureSlider.addTarget(utilities.haptics, action: #selector(utilities.haptics.buttonMediumHaptics(_:)), for: .touchUpInside)
        exposureLockButton.addTarget(self, action: #selector(self.runManualExposureLockController), for: .touchUpInside)
#endif
        focusButton.addTarget(self, action: #selector(self.runManualFocusUIHider), for: .touchUpInside)
        exposureButton.addTarget(self, action: #selector(self.runManualExposureUIHider), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(self.presentSettingsView), for: .touchUpInside)
        
        zoomRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(runZoomController))
        autofocusRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runAutoFocusController))
        uiHiderRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runUIHider))
        uiHiderRecognizer.numberOfTouchesRequired = 2
        
        
        focusTitle = utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: view, textForFlow: NSLocalizedString("uibutton.focus.title", comment: ""), anchorConstant: 10)
        exposureTitle = utilities.tooltips.returnLabelForTooltipFlows(viewForBounds: view, textForFlow: NSLocalizedString("uibutton.exposure.title", comment: ""), anchorConstant: 80)
        
        self.view.addGestureRecognizer(zoomRecognizer)
        self.view.addGestureRecognizer(autofocusRecognizer)
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
        
        utilities.tooltips.fadeOutTooltipFlow(labelsToFade: [ focusTitle, exposureTitle])
        utilities.tooltips.zoomTooltipFlow(button: currentCamera, viewForBounds: self.view, camera: selectedDevice)
        
        setupGameKitAlert()
    }
    
    func setupGameKitAlert() {
        if utilities.settings.defaults.bool(forKey: "internal.gamekit.alert") {
            let alert = UIAlertController(title: "alert.title.gamekit".localized, message: "alert.detail.gamekit".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.reopen", comment: "Default action"), style: .default, handler: { _ in
                exit(11)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.report", comment: "Default action"), style: .default, handler: { _ in
                guard let url = URL(string: "https://www.youtube.com/watch?v=At8v_Yc044Y") else {
                  return
                }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ignore", comment: "Default action"), style: .default, handler: { _ in
                self.utilities.settings.defaults.set(false, forKey: "internal.gamekit.alert")
                self.setupLmaoView()
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
    
    /// Function to check and ask for permissions to use the camera.
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            utilities.debugNSLog("[Permissions] User has given permission to use the camera")
            return
        case .denied:
            utilities.debugNSLog("[Permissions] User has denied permission to use the camera")
            abort()
        case .notDetermined:
            utilities.debugNSLog("[Permissions] Unknown authorization state, requesting access")
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in if(!authorized){ abort() } })
        case .restricted:
            utilities.debugNSLog("[Permissions] User cannot give camera access due to restrictions")
            abort()
        @unknown default:
            utilities.debugNSLog("[Permissions] the what")
            fatalError()
        }
    }
    
    /// Function to dynamically update the aspect ratio for ``cameraPreview`` through ``MalachiteSettingsView``.
    @objc func changeAspectFill() {
        UIView.animate(withDuration: 20) { [self] in
            if utilities.settings.defaults.bool(forKey: "format.preview.fill") {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
    }
    
    /// Function to dynamically change the auto exposure and ``exposureSlider`` values when toggling in ``MalachiteSettingsView``.
    @objc func changeExposureLimit() {
        do {
            try selectedDevice?.lockForConfiguration()
            defer { selectedDevice?.unlockForConfiguration() }
            selectedDevice?.exposureMode = .continuousAutoExposure
        } catch {
            utilities.debugNSLog("[Change Exposure Limit] Couldn't lock device for configuration")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.exposureSlider.value = 0.0
        }
    }
    
    /// Function to change the video stabilization mode for the ``cameraPreview``.
    @objc func changeStabilizerMode() {
        if utilities.settings.defaults.bool(forKey: "capture.stblz.enabled") {
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
            if utilities.settings.defaults.bool(forKey: "internal.gamekit.enabled") {
                utilities.games.setupGameCenter()
            }
            
            utilities.settings.dumpUserDefaults()
            
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
    
    /// INTERNAL function, documented later
    @objc func runInputSwitch() {
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
        
        utilities.function.switchInput(session: &cameraSession!,
                                                cameras: availableRearCameras,
                                                device: &selectedDevice,
                                                input: &selectedInput,
                                                button: &cameraButton,
                                                firstRun: &initRun)
        
        utilities.tooltips.zoomTooltipFlow(button: currentCamera, viewForBounds: view, camera: selectedDevice)
    }
    
    /// Function to toggle the flashlight's on state.
    @objc func runFlashlightToggle() {
        utilities.function.toggleFlash(captureDevice: &selectedDevice!,
                                       flashlightButton: &flashlightButton)
    }
    
    /// Function to take an image.
    @objc func runImageCapture() {
        self.captureButton.isEnabled = false
        progressIndicator = UIActivityIndicatorView(frame: self.captureButton.frame)
        self.view.addSubview(progressIndicator)
        self.captureButton.setImage(nil, for: .normal)
        progressIndicator.startAnimating()
        
        
        var libraryAccessGranted = false
        let group = DispatchGroup()
        group.enter()
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized || status == .limited {
                libraryAccessGranted = true
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [self] in
            if libraryAccessGranted {
                self.photoOutput = utilities.function.captureImage(output: self.photoOutput!, viewForBounds: self.view, captureDelegate: self)
            } else {
                utilities.debugNSLog("[Capture Photo] PHPhotoLibrary not authorized, showing error")
                let alert = UIAlertController(title: "error.title.phphotolibrary", message: "error.detail.phphotolibrary", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("alert.button.ok", comment: "Default action"), style: .default, handler: { _ in
                    self.utilities.debugNSLog("[Capture Photo] Dialog has been dismissed")
                }))
                self.present(alert, animated: true, completion: nil)
            }
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
            utilities.settings.runPhotoCounter()
            if utilities.games.gameCenterEnabled {
                let numPhotos = utilities.settings.defaults.integer(forKey: "internal.photos.count")
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
                                captureDevice: &selectedDevice!,
                                lastZoomFactor: &lastZoomFactor,
                                hapticClass: utilities.haptics)
    }
    
    /// Function to autofocus with ``autofocusRecognizer``.
    @objc func runAutoFocusController() {
        utilities.function.autofocus(sender: autofocusRecognizer,
                                     captureDevice: &selectedDevice!,
                                     button: autofocusFeedback,
                                     viewForScale: self.view,
                                     hapticClass: utilities.haptics)
    }
    
    /// Function to handle ``focusSlider`` interaction.
    @objc func runManualFocusController() {
        utilities.function.manualFocus(captureDevice: &selectedDevice!,
                                       sender: focusSlider)
    }
    
    /// Function to handle ``exposureSlider`` interaction.
    @objc func runManualExposureController() {
        utilities.function.manualExposure(captureDevice: &selectedDevice!,
                                          sender: exposureSlider)
    }
    
    /// Function to show and hide the ``exposureSliderButton`` and ``exposureLockButton``.
    @objc func runManualExposureUIHider() {
        manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualExposureSliderIsActive,
                                                                            optionButton: exposureButton,
                                                                            lockButton: exposureLockButton,
                                                                            associatedSliderButton: exposureSliderButton)
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
    @objc func runManualFocusUIHider() {
        manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualFocusSliderIsActive,
                                                                         optionButton: focusButton,
                                                                         lockButton: focusLockButton,
                                                                         associatedSliderButton: focusSliderButton)
    }
    
    /// Function to show and hide the ``focusSliderButton`` and ``focusLockButton``.
    @objc func runManualFocusLockController() {
        manualFocusLockIsActive = utilities.views.runLockControllers(lockIsActive: manualFocusLockIsActive,
                                                                     lockButton: &focusLockButton,
                                                                     associatedSlider: &focusSlider,
                                                                     associatedGestureRecognizer: autofocusRecognizer,
                                                                     viewForRecognizers: self.view)
    }
    
    /// Function to show and hide the user interface that was drawn with ``setupView()``.
    @objc func runUIHider() {
        if uiHiderRecognizer.state != UITapGestureRecognizer.State.began { return }
        
        let gestureRecognizers = [ zoomRecognizer, autofocusRecognizer ]
        
        if !uiIsHidden {
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
            for gestureRecognizer in gestureRecognizers {
                self.view.removeGestureRecognizer(gestureRecognizer)
            }
        } else {
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
                self.view.addGestureRecognizer(gestureRecognizer)
            }
        }
        
        uiIsHidden = !uiIsHidden
        utilities.haptics.triggerNotificationHaptic(type: .success)
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
    
    /// Override function to trigger actions when the screen rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [self] context in
            self.cameraPreview?.connection!.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.windows.first!.windowScene!.interfaceOrientation.rawValue)!)
            self.cameraPreview?.frame.size = self.view.frame.size
        })
    }
}
