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

class MalachiteView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var cameraSession: AVCaptureSession?
    var selectedDevice: AVCaptureDevice?
    var ultraWideDevice: AVCaptureDevice?
    var wideAngleDevice: AVCaptureDevice?
    var selectedInput: AVCaptureDeviceInput?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var cameraPreview: AVCaptureVideoPreviewLayer?
    var wideAngleInUse = true
    var initRun = true
    
    var cameraButton = UIButton()
    var flashlightButton = UIButton()
    var captureButton = UIButton()
    var aboutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("[Initialization] Starting up Malachite")
        cameraPreview?.frame.size = self.view.frame.size
        NSLog("[Initialization] Bringing up AVCaptureSession")
        cameraSession = AVCaptureSession()
        
        NSLog("[Initialization] Bringing up AVCaptureDeviceInput")
        switchInput()
        
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
        
        cameraButton = returnProperButton(symbolName: "camera")
        self.view.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 60),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            cameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        cameraButton.addTarget(self, action: #selector(self.switchInput), for: .touchUpInside)
        
        flashlightButton = returnProperButton(symbolName: "flashlight.off.fill")
        self.view.addSubview(flashlightButton)
        NSLayoutConstraint.activate([
            flashlightButton.widthAnchor.constraint(equalToConstant: 60),
            flashlightButton.heightAnchor.constraint(equalToConstant: 60),
            flashlightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            flashlightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        flashlightButton.addTarget(self, action: #selector(self.toggleFlash), for: .touchUpInside)
        
        captureButton = returnProperButton(symbolName: "camera.aperture")
        self.view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalToConstant: 60),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            captureButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            captureButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        captureButton.addTarget(self, action: #selector(self.captureImage), for: .touchUpInside)
        
        aboutButton = returnProperButton(symbolName: "info")
        self.view.addSubview(aboutButton)
        NSLayoutConstraint.activate([
            aboutButton.widthAnchor.constraint(equalToConstant: 60),
            aboutButton.heightAnchor.constraint(equalToConstant: 60),
            aboutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            aboutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        aboutButton.addTarget(self, action: #selector(self.presentAboutView), for: .touchUpInside)
    }
    
    func returnProperButton(symbolName name: String) -> UIButton {
        let button = UIButton()
        let buttonImage = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        button.bringSubviewToFront(button.imageView!)
        button.insertSubview(blurView, at: 0)
        return button
    }
    
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                            { (authorized) in if(!authorized){ abort() } })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
    
    @objc func toggleFlash() {
        if ((selectedDevice?.hasTorch) != nil) {
            var buttonImage = UIImage()
            do {
                try selectedDevice?.lockForConfiguration()
                if (selectedDevice?.torchMode == AVCaptureDevice.TorchMode.on) {
                    NSLog("[Flashlight] Flash is already on, turning off")
                    selectedDevice?.torchMode = AVCaptureDevice.TorchMode.off
                    buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                } else {
                    do {
                        NSLog("[Flashlight] Flash is off, turning on")
                        try selectedDevice?.setTorchModeOn(level: 1.0)
                        buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
                    } catch {
                        print(error)
                        buttonImage = (UIImage(systemName: "flashlight.off.fill")?.withRenderingMode(.alwaysTemplate))!
                    }
                }
                flashlightButton.setImage(buttonImage, for: .normal)
                selectedDevice?.unlockForConfiguration()
            } catch {
                print(error)
                buttonImage = (UIImage(systemName: "flashlight.on.fill")?.withRenderingMode(.alwaysTemplate))!
            }
        }
    }
    
    @objc func switchInput(){
        if ultraWideDevice == nil && !initRun {
            NSLog("[Camera Input] AVCaptureDevice for builtInUltraWideCamera unavailable, showing error")
            let alert = UIAlertController(title: "Switching cameras unsupported", message: "The camera switcher cannot be used as your device does not have an ultra-wide camera available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("[Camera Input] Dialog has been dismissed")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        cameraButton.isUserInteractionEnabled = false
        NSLog("[Camera Input] Getting ready to configure session")
        cameraSession?.beginConfiguration()
        
        if !initRun {
            NSLog("[Camera Input] Removing currently active camera input")
            cameraSession?.removeInput(selectedInput!)
        } else {
            NSLog("[Camera Input] Still initializing, getting compatible devices")
            ultraWideDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back)
            NSLog("[Camera Input] Check for builtInUltraWideCamera completed")
            wideAngleDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
            NSLog("[Camera Input] Check for builtInWideAngleCamera completed")
            initRun = false
        }
        
        if wideAngleInUse == true && ultraWideDevice != nil {
            NSLog("[Camera Input] builtInUltraWideCamera is available, selecting as device")
            selectedDevice = ultraWideDevice
            wideAngleInUse = false
        } else {
            NSLog("[Camera Input] builtInWideAngle is available, selecting as device")
            selectedDevice = wideAngleDevice
            wideAngleInUse = true
        }
        
        NSLog("[Camera Input] Attempting to attach device input to session")
        do { selectedInput = try AVCaptureDeviceInput(device: selectedDevice!) }
        catch {
            print(error)
        }
        
        NSLog("[Camera Input] Attached input, finishing configuration")
        cameraSession?.addInput(selectedInput!)
        cameraSession?.commitConfiguration()
        cameraButton.isUserInteractionEnabled = true
    }
    
    @objc func captureImage() {
        
    }
    
    @objc func presentAboutView() {
        let aboutView = MalachiteAboutView() // swiftUIView is View
        let hostingController = UIHostingController(rootView: aboutView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}
