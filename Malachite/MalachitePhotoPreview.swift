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
        
        watermarkedImage = self.watermark(watermark: utilities.settings.defaults.string(forKey: "textForWatermark")!, imageToWatermark: photoImage)
        rotatedImage = photoImage.rotate(radians: Float(rotation))!
        
        photoImageView.image = rotatedImage
        self.view.addSubview(photoImageView)
        dismissButton = utilities.views.returnProperButton(symbolName: "xmark", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 60),
            dismissButton.heightAnchor.constraint(equalToConstant: 60),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -28),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        dismissButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        
        savePhotoButton = utilities.views.returnProperButton(symbolName: "square.and.arrow.down", viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(savePhotoButton)
        NSLayoutConstraint.activate([
            savePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 60),
            savePhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 41),
            savePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        savePhotoButton.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
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
            try PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: self.watermarkedImage)
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
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.clear
        imageView.frame = CGRect(x:0, y:0, width:image.size.width, height:image.size.height)
        
        if utilities.settings.defaults.bool(forKey: "enableWatermark") {
            NSLog("[Watermarking] User has opted to show a watermark")
            var label = UILabel()
            if image.size.width < image.size.height {
                label = UILabel(frame: CGRect(x:image.size.width - 20, y:20, width:image.size.width, height:120))
                var transA = CGAffineTransformMakeTranslation(label.frame.size.width/2,label.frame.size.height/2);
                var transB = CGAffineTransformMakeRotation(Double.pi / 2);
                var transC = CGAffineTransformMakeTranslation(-label.frame.size.width/2,-label.frame.size.height/2);
                
                label.transform = CGAffineTransformConcat(CGAffineTransformConcat(transA,transB),transC);
            } else {
                label = UILabel(frame: CGRect(x:20, y:20, width:image.size.width, height:120))
            }
            label.textAlignment = .left
            label.textColor = UIColor.white
            label.text = text
            label.font = UIFont.boldSystemFont(ofSize: 70)
            
            imageView.addSubview(label)
        }
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return imageWithText!
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
