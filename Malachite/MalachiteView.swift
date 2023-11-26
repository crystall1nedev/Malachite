//
//  ViewController.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/25/23.
//

import UIKit
import AVFoundation

class MalachiteView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var cameraSession: AVCaptureSession?
    var selectedDevice: AVCaptureDevice?
    var selectedDeviceFallback: AVCaptureDevice?
    var ultraWideInput: AVCaptureDeviceInput?
    var wideInput: AVCaptureDeviceInput?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var cameraPreview: AVCaptureVideoPreviewLayer?
    var frame : CGRect?
    
    let flashlightButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cameraButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "switchcamera")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraPreview?.frame.size = self.view.frame.size
        
        cameraSession = AVCaptureSession()
        selectedDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back)
        selectedDeviceFallback = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        
        
        
        do { ultraWideInput = try AVCaptureDeviceInput(device: selectedDevice!) }
        catch {
            print(error)
        }
        
        do { wideInput = try AVCaptureDeviceInput(device: selectedDeviceFallback!) }
        catch {
            print(error)
        }
        
        if let ultraWideInput = ultraWideInput {
            cameraSession?.addInput(ultraWideInput)
            input = ultraWideInput
        } else {
            if let wideInput = wideInput {
                cameraSession?.addInput(wideInput)
            }
        }
        
        cameraPreview = AVCaptureVideoPreviewLayer(session: cameraSession!)
        cameraPreview?.frame.size = self.view.frame.size
        cameraPreview?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        cameraPreview?.connection?.videoOrientation = transformOrientation(orientation: .portrait)
        self.view.layer.addSublayer(cameraPreview!)
        
        DispatchQueue.global(qos: .background).async {
            self.cameraSession?.startRunning()
        }
    }
    
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        default:
            return .portrait
        }
    }
    
    func setupView(){
        self.view.backgroundColor = .black
        self.view.addSubview(cameraButton)
        self.view.addSubview(flashlightButton)
        
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30),
            cameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            flashlightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            flashlightButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            flashlightButton.widthAnchor.constraint(equalToConstant: 30),
            flashlightButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        cameraButton.addTarget(self, action: #selector(self.switchInput), for: .touchUpInside)
        flashlightButton.addTarget(self, action: #selector(self.toggleFlash), for: .touchUpInside)
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
            do {
                try selectedDevice?.lockForConfiguration()
                if (selectedDevice?.torchMode == AVCaptureDevice.TorchMode.on) {
                    selectedDevice?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try selectedDevice?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                selectedDevice?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @objc func switchInput(){
        cameraButton.isUserInteractionEnabled = false
        
        cameraSession?.beginConfiguration()
        if input == ultraWideInput {
            cameraSession?.removeInput(ultraWideInput!)
            cameraSession?.addInput(wideInput!)
        } else {
            cameraSession?.removeInput(wideInput!)
            cameraSession?.addInput(ultraWideInput!)
        }
        cameraSession?.commitConfiguration()
        cameraButton.isUserInteractionEnabled = true
    }
}
