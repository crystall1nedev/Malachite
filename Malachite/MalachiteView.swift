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
    var aboutButton = UIButton()
    var focusSlider = UISlider()
    var zoomRecognizer = UIPinchGestureRecognizer()
    var autofocusRecognizer = UILongPressGestureRecognizer()
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    
    var utilities = MalachiteClassesObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("[Initialization] Starting up Malachite")
        cameraPreview?.frame.size = self.view.frame.size
        NSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = AVCaptureSession()
        
        NSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        NSLog("[Camera Input] Still initializing, getting compatible devices")
        ultraWideDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back)
        NSLog("[Camera Input] Check for builtInUltraWideCamera completed")
        wideAngleDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        NSLog("[Camera Input] Check for builtInWideAngleCamera completed")
        runInputSwitch()
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        cameraSession?.addOutput(photoOutput)
        self.photoOutput = photoOutput
        
        NSLog("[Initialization] Bringing up AVCaptureVideoPreviewLayer")
        cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
        cameraPreview?.frame.size = self.view.frame.size
        cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreview?.connection?.videoOrientation = transformOrientation(orientation: .portrait)
        self.view.layer.addSublayer(cameraPreview!)
        
        NSLog("[Initialization] Starting session stream")
        DispatchQueue.global(qos: .background).async {
            self.cameraSession?.startRunning()
        }
        
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
        
        cameraButton = utilities.views.returnProperButton(symbolName: "camera", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 60),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            cameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        cameraButton.addTarget(self, action: #selector(self.runInputSwitch), for: .touchUpInside)
        
        flashlightButton = utilities.views.returnProperButton(symbolName: "flashlight.off.fill", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(flashlightButton)
        NSLayoutConstraint.activate([
            flashlightButton.widthAnchor.constraint(equalToConstant: 60),
            flashlightButton.heightAnchor.constraint(equalToConstant: 60),
            flashlightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            flashlightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        flashlightButton.addTarget(self, action: #selector(self.runFlashlightToggle), for: .touchUpInside)
        
        captureButton = utilities.views.returnProperButton(symbolName: "camera.aperture", viewForBounds: view, hapticClass: utilities.haptics)
        self.view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalToConstant: 60),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            captureButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            captureButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        captureButton.addTarget(self, action: #selector(self.runImageCapture), for: .touchUpInside)
        
        aboutButton = utilities.views.returnProperButton(symbolName: "info", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(aboutButton)
        NSLayoutConstraint.activate([
            aboutButton.widthAnchor.constraint(equalToConstant: 60),
            aboutButton.heightAnchor.constraint(equalToConstant: 60),
            aboutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            aboutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        aboutButton.addTarget(self, action: #selector(self.presentAboutView), for: .touchUpInside)
        
        zoomRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(runZoomController))
        self.view.addGestureRecognizer(zoomRecognizer)
        
        autofocusRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(runAutoFocusController))
        self.view.addGestureRecognizer(autofocusRecognizer)
        
        let focusButton = utilities.views.returnProperButton(symbolName: "", viewForBounds: self.view, hapticClass: utilities.haptics)
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        focusSlider.transform = CGAffineTransform(rotationAngle: CGFloat((3 * Double.pi) / 2))
        focusButton.addSubview(focusSlider)
        self.view.addSubview(focusButton)
        NSLayoutConstraint.activate([
            focusButton.widthAnchor.constraint(equalToConstant: 60),
            focusButton.heightAnchor.constraint(equalToConstant: 210),
            focusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 290),
            focusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            focusSlider.widthAnchor.constraint(equalToConstant: 180),
            focusSlider.heightAnchor.constraint(equalToConstant: 80),
            focusSlider.centerYAnchor.constraint(equalTo: focusButton.centerYAnchor),
            focusSlider.centerXAnchor.constraint(equalTo: focusButton.trailingAnchor, constant: -30),
        ])
        focusSlider.addTarget(self, action: #selector(self.controlManualFocus(sender:)), for: .valueChanged)
        focusSlider.addTarget(utilities.haptics, action: #selector(utilities.haptics.buttonMediumHaptics(_:)), for: .touchUpInside)
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
    
    @objc func presentAboutView() {
        let aboutView = MalachiteAboutView()
        let hostingController = UIHostingController(rootView: aboutView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func controlManualFocus(sender: UISlider) {
        if let device = selectedDevice {
            let lensPosition = sender.value
            do {
                try device.lockForConfiguration()
            } catch {
                NSLog("[Manual Focus] Couldn't lock device for configuration: %@", error.localizedDescription)
                return
            }
            
            device.setFocusModeLocked(lensPosition: lensPosition)
            NSLog("[Manual Focus] Changed lens position")
            device.unlockForConfiguration()
        }
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
        
        focusSlider.value = 0
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
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        let photoPreview = MalachitePhotoPreview()
        photoPreview.photoImageView.frame = view.frame
        photoPreview.photoImage = previewImage!
        let navigationController = UINavigationController(rootViewController: photoPreview)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(navigationController, animated: true, completion: nil)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}
