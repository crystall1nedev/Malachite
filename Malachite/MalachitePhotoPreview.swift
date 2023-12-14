//
//  MalachitePhotoPreview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/27/23.
//

import Foundation
import UIKit
import Photos

class MalachitePhotoPreview : UIViewController {
    var utilities = MalachiteClassesObject()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var photoImageData = Data()
    var photoImage = UIImage()
    var watermarkedImage = UIImage()
    
    var savePhotoButton = UIButton()
    var dismissButton = UIButton()
    
    let fixedOrientation = UIDevice.current.orientation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        
        var rotation = -1.0
        var rotatedImage = UIImage()
        
        switch UIDevice.current.orientation {
        case .unknown:
            NSLog("[Rotation] How did I get here?")
            rotation = Double.pi * 2
        case .portrait:
            NSLog("[Rotation] Device has rotated portrait, with front camera on the top")
            rotation = Double.pi * 2
        case .portraitUpsideDown:
            NSLog("[Rotation] Device has rotated portrait, with front camera on the bottom")
            rotation = Double.pi
        case .landscapeLeft:
            NSLog("[Rotation] Device has rotated landscape, with front camera on the left")
            rotation = Double.pi / 2
        case .landscapeRight:
            NSLog("[Rotation] Device has rotated landscape, with front camera on the right")
            rotation = -Double.pi / 2
        case .faceUp:
            NSLog("[Rotation] Unneeded rotation, ignoring")
            rotation = Double.pi * 2
        case .faceDown:
            NSLog("[Rotation] Unneeded rotation, ignoring")
            rotation = Double.pi * 2
        @unknown default:
            abort()
        }
        
        rotatedImage = photoImage.rotate(radians: Float(rotation))!
        photoImageView.image = rotatedImage
        
        var currentY = (self.navigationController?.navigationBar.frame.size.height)!  - 28
        self.view.addSubview(photoImageView)
        dismissButton = utilities.views.returnProperButton(symbolName: "xmark", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 60),
            dismissButton.heightAnchor.constraint(equalToConstant: 60),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: currentY),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        dismissButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        
        currentY = currentY + 69
        
        savePhotoButton = utilities.views.returnProperButton(symbolName: "square.and.arrow.down", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(savePhotoButton)
        NSLayoutConstraint.activate([
            savePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 60),
            savePhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: currentY),
            savePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        savePhotoButton.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        
        orientationChanged()
    }
    
    @objc private func dismissView() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    @objc func orientationChanged() {
        utilities.views.rotateButtonsWithOrientation(buttonsToRotate: [ dismissButton, savePhotoButton ])
    }
    
    @objc private func savePhoto() {
        do {
            try PHPhotoLibrary.shared().performChangesAndWait { [self] in
                let createRequest = PHAssetCreationRequest.forAsset()
                var data = Data()
                let rawImage = CIImage(data: self.photoImageData)
                let watermarkImage = CIImage(image: self.watermark(watermark: utilities.settings.defaults.string(forKey: "textForWatermark")!,
                                                                   imageToWatermark: photoImage))
                let outputImage = watermarkImage!.composited(over: rawImage!)
                let outputImageWithProps = outputImage.settingProperties(rawImage!.properties)
                
                let enableHEIF = utilities.settings.defaults.bool(forKey: "shouldUseHEIF")
                let enableHEIF10 = utilities.settings.defaults.bool(forKey: "shouldUseHEIF10Bit")
                
                if enableHEIF {
                    data = returnHEIC(enable10Bit: enableHEIF10, imageForRepresentation: outputImageWithProps)
                } else {
                    data = returnJPEG(imageForRepresentation: outputImageWithProps)
                }
                
                createRequest.addResource(with: .photo, data: data, options: nil)
                NSLog("[Capture Photo] Photo has been saved to the user's library")
                self.utilities.haptics.triggerNotificationHaptic(type: .success)
                self.dismissView()
            }
        } catch let error {
            NSLog("[Capture Photo] Photo couldn't be saved to the user's library: %@", error.localizedDescription)
        }
    }
        
    
    func watermark(watermark text: String, imageToWatermark image: UIImage) -> UIImage
    {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        if image.size.width < image.size.height {
            imageView.frame = CGRect(x:0, y:0, width:image.size.height, height:image.size.width)
        } else {
            imageView.frame = CGRect(x:0, y:0, width:image.size.width, height:image.size.height)
        }
        
        if utilities.settings.defaults.bool(forKey: "enableWatermark") {
            NSLog("[Watermarking] User has opted to show a watermark")
            var label = UILabel()
            label = UILabel(frame: CGRect(x:50, y:20, width:image.size.width, height:120))
            label.textAlignment = .left
            label.textColor = UIColor.white
            label.text = text
            label.font = UIFont(name: "Menlo", size: 70)
            
            imageView.addSubview(label)
        }
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return imageWithText!
    }
    
    func returnHEIC(enable10Bit extraBits: Bool, imageForRepresentation image: CIImage) -> Data {
        let types = CGImageDestinationCopyTypeIdentifiers() as NSArray
        if types.contains("public.heic") {
            if #available(iOS 15.0, *) {
                if extraBits {
                    do {
                        NSLog("[Capture Photo] HEIF 10-bit is enabled, saving 10-bit HEIF representation")
                        return try CIContext().heif10Representation(of: image, colorSpace: CGColorSpace(name: CGColorSpace.itur_2020)!)
                    } catch {
                        NSLog("[Capture Photo] HEIF 10-bit representation failed, falling back to HEIF")
                    }
                } else {
                    NSLog("[Capture Photo] HEIF is enabled, saving HEIF representation")
                }
            } else {
                NSLog("[Capture Photo] HEIF EDR was enabled, but we're on iOS 14")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIF10Bit")
            }
            
            return CIContext().heifRepresentation(of: image, format: .ARGB8, colorSpace: CGColorSpace(name: CGColorSpace.itur_709)!)!
        } else {
            NSLog("[Capture Photo] Device does not support encoding HEIF, falling back to JPEG")
            utilities.settings.defaults.set(false, forKey: "shouldUseHEIF")
            return returnJPEG(imageForRepresentation: image)
        }
    }
    
    func returnJPEG(imageForRepresentation image: CIImage) -> Data {
        NSLog("[Capture Photo] HEIF is disabled, saving JPEG representation")
        return CIContext().jpegRepresentation(of: image, colorSpace: CGColorSpace(name: CGColorSpace.itur_709)!)!
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

