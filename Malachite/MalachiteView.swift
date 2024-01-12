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

class MalachiteView: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    var cameraSession: AVCaptureSession?
    var selectedDevice: AVCaptureDevice?
    var ultraWideDevice: AVCaptureDevice?
    var wideAngleDevice: AVCaptureDevice?
    var selectedInput: AVCaptureDeviceInput?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreview: AVCaptureVideoPreviewLayer?
    var wideAngleInUse = true
    var initRun = true
    
    var cameraButton = UIButton()
    var flashlightButton = UIButton()
    var captureButton = UIButton()
    var settingsButton = UIButton()
    
    var focusButton = UIButton()
    var focusSliderButton = UIButton()
    var focusSlider = UISlider()
    var focusLockButton = UIButton()
    var manualFocusSliderIsActive = false
    var manualFocusLockIsActive = false
    
    var exposureButton = UIButton()
    var exposureSliderButton = UIButton()
    var exposureSlider = UISlider()
    var exposureLockButton = UIButton()
    var manualExposureSliderIsActive = false
    var manualExposureLockIsActive = false
    
    var zoomRecognizer = UIPinchGestureRecognizer()
    var autofocusRecognizer = UILongPressGestureRecognizer()
    var uiHiderRecognizer = UILongPressGestureRecognizer()
    var uiIsHidden = false
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
    public var utilities = MalachiteClassesObject()
    private var rotationObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        utilities.function.settings = utilities.settings
        
        NSLog("[Initialization] Starting up Malachite")
        #if !targetEnvironment(simulator)
        cameraPreview?.frame.size = self.view.frame.size
        NSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = AVCaptureSession()
        
        NSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        NSLog("[Camera Input] Still initializing, getting compatible devices")
        ultraWideDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back)
        NSLog("[Camera Input] Check for builtInUltraWideCamera completed")
        wideAngleDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        NSLog("[Camera Input] Check for builtInWideAngleCamera completed")
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        cameraSession?.sessionPreset = AVCaptureSession.Preset.photo
        cameraSession?.addOutput(photoOutput)
        self.photoOutput = photoOutput
        
        NSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
        cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
        if utilities.settings.defaults.bool(forKey: "format.preview.fill") {
            cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        } else {
            cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
        }
        
        cameraPreview?.connection?.videoOrientation = transformOrientation(orientation: .portrait)
        runInputSwitch()
        
        
        let replicator = CAReplicatorLayer()
        cameraPreview?.frame.size = CGSize(width: (self.view.frame.size.width * 5), height: (self.view.frame.size.height * 5))
        cameraPreview?.frame.origin.x = 0 - (self.view.frame.size.width * 2)
        cameraPreview?.frame.origin.y = 0 - (self.view.frame.size.height * 2)
        replicator.frame.size = self.view.frame.size
        replicator.instanceCount = 2
        replicator.instanceTransform = CATransform3DMakeScale(0.20, 0.20, 2)
        replicator.addSublayer(cameraPreview!)
        
        self.view.layer.addSublayer(replicator)
        NSLog("[Initialization] Starting session stream")
        DispatchQueue.global(qos: .background).async {
            self.cameraSession?.startRunning()
        }
        #else
        NSLog("[Initialization] Detected iOS simulator, skipping to user interface bringup")
        #endif
        
        NSLog("[Initialization] Setting up notification observer for orientation changes")
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAspectFill), name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeExposureLimit), name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStabilizerMode), name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NSLog("[Initialization] Presenting user interface")
        setupView()
    }
    
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        default:
            return .portrait
        }
    }
    
    func setupView(){
        self.view.backgroundColor = .black
        
#if targetEnvironment(simulator)
        let lmaoView = UIImageView(image: utilities.views.returnImageForSimulator())
        lmaoView.frame = self.view.frame
        self.view.addSubview(lmaoView)
        
        NSLayoutConstraint.activate([
            lmaoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lmaoView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
        
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        exposureSlider.translatesAutoresizingMaskIntoConstraints = false
        focusLockButton.alpha = 0.0
        exposureLockButton.alpha = 0.0
        
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
        settingsButton.addTarget(self, action: #selector(self.presentAboutView), for: .touchUpInside)
        
        zoomRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(runZoomController))
        autofocusRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runAutoFocusController))
        uiHiderRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runUIHider))
        uiHiderRecognizer.numberOfTouchesRequired = 2
        
        self.view.addGestureRecognizer(zoomRecognizer)
        self.view.addGestureRecognizer(autofocusRecognizer)
        self.view.addGestureRecognizer(uiHiderRecognizer)
        
        var lockButtonsX = -80.0
        var lockButtonsY = 0.0
        
        if self.view.frame.size.width >= 370 {
            NSLog("[Initialization] Device screen is capable of displaying lock button inline")
            lockButtonsX = -300.0
        } else {
            NSLog("[Initialization] Device screen is too small for inline lock button")
            lockButtonsY = 70.0
        }
        
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 60),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cameraButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            
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
            
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
        ])
        
        utilities.tooltips.tooltipFlow(viewForBounds: self.view)
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        cameraPreview?.frame = view.bounds
    }
    
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            NSLog("[Permissions] User has given permission to use the camera")
            return
        case .denied:
            NSLog("[Permissions] User has denied permission to use the camera")
            abort()
        case .notDetermined:
            NSLog("[Permissions] Unknown authorization state, requesting access")
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in if(!authorized){ abort() } })
        case .restricted:
            NSLog("[Permissions] User cannot give camera access due to restrictions")
            abort()
        @unknown default:
            NSLog("[Permissions] the what")
            fatalError()
        }
    }
    
    @objc func changeAspectFill() {
        UIView.animate(withDuration: 20) { [self] in
            if utilities.settings.defaults.bool(forKey: "format.preview.fill") {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
    }
    
    @objc func changeExposureLimit() {
        do {
            try selectedDevice?.lockForConfiguration()
            defer { selectedDevice?.unlockForConfiguration() }
            selectedDevice?.exposureMode = .continuousAutoExposure
        } catch {
            NSLog("[Change Exposure Limit] Couldn't lock device for configuration")
        }
        
        UIView.animate(withDuration: 0.5) {
            self.exposureSlider.value = 0.0
        }
    }
    
    @objc func changeStabilizerMode() {
        if utilities.settings.defaults.bool(forKey: "capture.stblz.enabled") {
            if #available(iOS 17.0, *) {
                if ((selectedDevice?.activeFormat.isVideoStabilizationModeSupported(.previewOptimized)) != nil) {
                    NSLog("[Preview Stabilization] Enabling enhanced stabilization mode")
                    cameraPreview?.connection!.preferredVideoStabilizationMode = .previewOptimized
                    return
                }
            }
            
            if ((selectedDevice?.activeFormat.isVideoStabilizationModeSupported(.standard)) != nil) {
                NSLog("[Preview Stabilization] Enabling standard stabilization mode")
                cameraPreview?.connection!.preferredVideoStabilizationMode = .standard
            }
        } else {
            cameraPreview?.connection!.preferredVideoStabilizationMode = .off
        }
    }
    
    @objc func presentAboutView() {
        var aboutView = MalachiteAboutAndSettingsView()
        aboutView.utilities = self.utilities
        let hostingController = UIHostingController(rootView: aboutView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func runInputSwitch() {
        if ultraWideDevice == nil && !initRun {
            NSLog("[Camera Input] AVCaptureDevice for builtInUltraWideCamera unavailable, showing error")
            let alert = UIAlertController(title: "Switching cameras unsupported", message: "The camera switcher cannot be used as your device does not have an ultra-wide camera available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("[Camera Input] Dialog has been dismissed")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.focusSlider.value = 0.0
            self.exposureSlider.value = 0.0
        }
        utilities.function.switchInput(session: &cameraSession!,
                                       uwDevice: &ultraWideDevice,
                                       waDevice: &wideAngleDevice!,
                                       device: &selectedDevice,
                                       input: &selectedInput,
                                       button: &cameraButton,
                                       waInUse: &wideAngleInUse,
                                       firstRun: &initRun)
    }
    
    @objc func runFlashlightToggle() {
        utilities.function.toggleFlash(captureDevice: &selectedDevice!,
                                       flashlightButton: &flashlightButton)
    }
    
    @objc func runImageCapture() {
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
                NSLog("[Capture Photo] PHPhotoLibrary not authorized, showing error")
                let alert = UIAlertController(title: "Cannot capture photos", message: "The capture images feature cannot be used because Malachite has not been given access to the photos library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("[Capture Photo] Dialog has been dismissed")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
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
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true, completion: nil)
        NotificationCenter.default.addObserver(photoPreview, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func runZoomController() {
        utilities.function.zoom(sender: zoomRecognizer,
                                captureDevice: &selectedDevice!,
                                lastZoomFactor: &lastZoomFactor,
                                hapticClass: utilities.haptics)
    }
    
    @objc func runAutoFocusController() {
        utilities.function.autofocus(sender: autofocusRecognizer,
                                     captureDevice: &selectedDevice!,
                                     viewForScale: self.view,
                                     hapticClass: utilities.haptics)
    }
    
    @objc func runManualFocusController() {
        utilities.function.manualFocus(captureDevice: &selectedDevice!,
                                       sender: focusSlider)
    }
    
    @objc func runManualExposureUIHider() {
        manualExposureSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualExposureSliderIsActive,
                                                                            optionButton: exposureButton,
                                                                            lockButton: exposureLockButton,
                                                                            associatedSliderButton: exposureSliderButton)
    }
    
    @objc func runManualExposureLockController() {
        manualExposureLockIsActive = utilities.views.runLockControllers(lockIsActive: manualExposureLockIsActive,
                                                                        lockButton: &exposureLockButton,
                                                                        associatedSlider: &exposureSlider,
                                                                        associatedGestureRecognizer: nil,
                                                                        viewForRecognizers: self.view)
    }
    
    @objc func runManualExposureController() {
        utilities.function.manualExposure(captureDevice: &selectedDevice!,
                                          sender: exposureSlider)
    }
    
    @objc func runManualFocusUIHider() {
        manualFocusSliderIsActive = utilities.views.runSliderControllers(sliderIsShown: manualFocusSliderIsActive,
                                                                         optionButton: focusButton,
                                                                         lockButton: focusLockButton,
                                                                         associatedSliderButton: focusSliderButton)
    }
    
    @objc func runManualFocusLockController() {
        manualFocusLockIsActive = utilities.views.runLockControllers(lockIsActive: manualFocusLockIsActive,
                                                                     lockButton: &focusLockButton,
                                                                     associatedSlider: &focusSlider,
                                                                     associatedGestureRecognizer: autofocusRecognizer,
                                                                     viewForRecognizers: self.view)
    }
    
    @objc func runUIHider() {
        if uiHiderRecognizer.state != UITapGestureRecognizer.State.began { return }
        
        let gestureRecognizers = [ zoomRecognizer, autofocusRecognizer ]
        
        if !uiIsHidden {
            UIView.animate(withDuration: 0.25) { [self] in
                for subview in self.view.subviews {
                    if subview == focusLockButton {
                        if manualFocusSliderIsActive { subview.alpha = 0.0 }
                    } else if subview == exposureLockButton {
                        if manualExposureSliderIsActive { subview.alpha = 0.0 }
                    } else {
                        subview.alpha = 0.0
                    }
                }
            }
            for gestureRecognizer in gestureRecognizers {
                self.view.removeGestureRecognizer(gestureRecognizer)
            }
        } else {
            UIView.animate(withDuration: 0.25) { [self] in
                for subview in self.view.subviews {
                    if subview == focusLockButton {
                        if manualFocusSliderIsActive { subview.alpha = 1.0 }
                    } else if subview == exposureLockButton {
                        if manualExposureSliderIsActive { subview.alpha = 1.0 }
                    } else {
                        subview.alpha = 1.0
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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}
