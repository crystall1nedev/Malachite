//
//  MalachitePhotoPreview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/27/23.
//

import Foundation
import UIKit
import Photos

class PhotoPreviewView : UIViewController, UIScrollViewDelegate {
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities: MalachiteClassesObject!
    
    var location: Location!
    /// A variable used to hold a copy of ``Photo``.
    var photo: Photo!
    
    /// The scroll view that holds the image view for zooming and panning.
    var photoScrollView = UIScrollView()
    
    var controls: controls?
    
    /** 
     The image view that holds the captuerd image for user review.
     
     FIX: There's currently a bug with iPadOS where this will be too big for the presented modal view.
     */
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// The data of the image that was just taken.
    var photoImageData = Data()
    /// The image that was just taken.
    var photoImage = UIImage()
    /// A watermarked image that was created using the `photoImage` frame.
    var watermarkedImage = UIImage()
    
    /// The data of the image after all adjustments are made.
    var finalizedImage = Data()
    
    /// A `UIButton` that enables users to leave the view.
    var dismissButton = UIButton()
    /// A `UIButton` that enables users to save the image.
    var savePhotoButton = UIButton()
    /// A `UIButton` that enables users to share the image directly from Malachite.
    var sharePhotoButton = UIButton()
    
    /// The title for the dismiss button in ``MalachitePhotoPreview``
    var dismissTitle = UILabel()
    /// The title for the save photo button in ``MalachitePhotoPreview``
    var savePhotoTitle = UILabel()
    /// The title for the share photo button in ``MalachitePhotoPreview``
    var sharePhotoTitle = UILabel()
    
    /// A variable to store the device's last known orientation.
    let fixedOrientation = UIDevice.current.orientation
    
    /// A variable to store whether or not HDR is enabled.
    let enableHDR = MalachitePreferencesUtils.shared.preferences.capture.hdr
    /// A variable to store whether or not the HEIC file format is enabled.
    let enableHEIC = MalachitePreferencesUtils.shared.preferences.capture.format.heic
    
    /**
     viewDidLoad override for the main user interface.
     
     This function currently serves to do the following:
     - Initialize and display the photo inside of ``photoImageView`` correctly.
     - Create a blurred background view the same way.
     - Create all buttons and gestures required to operate the user interface.
     - Register notifications for changes to orientation.
     */
    override func viewDidLoad() {
        // TODO: dev/malachitekit refactor this file
        self.finalizedImage = photo.finalizeImageForExport(imageData: self.photo.imageData)
        
        self.controls = PhotoPreviewView.controls(delegate: self)
        
        super.viewDidLoad()
		
		if #unavailable(iOS 18.0) { overrideUserInterfaceStyle = .dark }
        self.view.backgroundColor = .red
        
        var rotation = -1.0
        var rotatedImage = UIImage()
        
        if utilities.idiom == .phone {
            switch fixedOrientation {
            case .unknown:
                utilities.debugNSLog("[Rotation] How did I get here?")
                rotation = Double.pi * 2
            case .portrait:
                utilities.debugNSLog("[Rotation] Device has rotated portrait, with front camera on the top")
                rotation = Double.pi * 2
            case .portraitUpsideDown:
                utilities.debugNSLog("[Rotation] Device has rotated portrait, with front camera on the bottom")
                rotation = Double.pi
            case .landscapeLeft:
                utilities.debugNSLog("[Rotation] Device has rotated landscape, with front camera on the left")
                rotation = Double.pi / 2
            case .landscapeRight:
                utilities.debugNSLog("[Rotation] Device has rotated landscape, with front camera on the right")
                rotation = -Double.pi / 2
            default:
                utilities.debugNSLog("[Rotation] Unneeded or unknown rotation, ignoring")
            }
        } else {
            rotation = Double.pi * 2
        }
        
        rotatedImage = (rotation != -1) ? photoImage.rotate(radians: Float(rotation))! : photoImage
        let blurredBackgroundView = UIImageView(frame: self.view.bounds)
        blurredBackgroundView.image = rotatedImage
        blurredBackgroundView.layer.contentsGravity = .resizeAspectFill
        blurredBackgroundView.addSubview(utilities.views.returnProperEffectView(viewForBounds: self.view, effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
        blurredBackgroundView.clipsToBounds = true
        if rotatedImage.size.width < rotatedImage.size.height {
            photoImageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: rotatedImage.size.height / (rotatedImage.size.width / self.view.bounds.width))
        } else {
            photoImageView.frame = CGRect(x: 0, y: 0, width:rotatedImage.size.width / (rotatedImage.size.height / self.view.bounds.height), height: self.view.bounds.height)
        }
        photoImageView.image = rotatedImage
        photoImageView.layer.contentsGravity = .resizeAspect
        
        photoScrollView = UIScrollView(frame: self.view.bounds)
        
        photoScrollView.minimumZoomScale = 1
        photoScrollView.maximumZoomScale = 5
        photoScrollView.showsHorizontalScrollIndicator = false
        photoScrollView.showsVerticalScrollIndicator = false
        photoScrollView.delegate = self
        
        // Center photoImageView inside of photoScrollView
        let xOffset: CGFloat = (photoScrollView.bounds.width - photoImageView.bounds.width) / 2
        let yOffset: CGFloat = (photoScrollView.bounds.height - photoImageView.bounds.height) / 2
        
        photoScrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
        
        self.view.addSubview(blurredBackgroundView)
        photoScrollView.addSubview(photoImageView)
        self.view.addSubview(photoScrollView)
        
        self.controls!.bringUpControlLayer()
        
        orientationChanged()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if photoScrollView.zoomScale == 1 {
            photoScrollView.setZoomScale(2, animated: true)
        } else {
            photoScrollView.setZoomScale(1, animated: true)
        }
    }
    
    /// Function to allow the user to close the model view.
    @objc func dismissView() {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    /// Function to handle device rotation.
    @objc func orientationChanged() {
        utilities.views.rotateButtonsWithOrientation(buttonsToRotate: [ dismissButton, savePhotoButton, sharePhotoButton ])
    }
    
    /// Wrapper function to save the image to the user's Photos library, for the UIButton.
    @objc public func savePhotoWrapped() {
        self.savePhoto(finalImage: self.finalizedImage)
    }
    
    /// Function to save the image to the user's Photos library.
    public func savePhoto(finalImage: Data) {
        do {
            try PHPhotoLibrary.shared().performChangesAndWait { [self] in
                let createRequest = PHAssetCreationRequest.forAsset()
                createRequest.addResource(with: .photo, data: finalImage, options: nil)
                utilities.debugNSLog("[Capture Photo] Photo has been saved to the user's library")
                self.utilities.haptics.triggerNotificationHaptic(type: .success)
                self.dismissView()
            }
        } catch let error {
            utilities.debugNSLog("[Capture Photo] Photo couldn't be saved to the user's library: \(error.localizedDescription)")
        }
    }
    
    /// Function to share the image to other apps or people without saving to the Photos library.
    @objc func sharePhoto() {
        let shareableData = try! dataToShareable(data: finalizedImage, title: "sharable.title".localized)
        let shareSheet = UIActivityViewController(activityItems: [shareableData], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = sharePhotoButton
        if #available(iOS 26.0, *) {
            shareSheet.preferredTransition = .zoom { [self] _ in sharePhotoButton }
        }
        self.present(shareSheet, animated: true)
    }
    
    /**
     Function to extract EXIF properties from the image. 
     
     Currently used to extract MakerApple and the EXIFDictionary for HDR.
     */
    func extractEXIFData(properties props: [String : Any], dictionary dict: CFString) -> [String : Any] {
        return props[dict as String] as? [String: Any] ?? [:]
    }
    
    /// Override function to force the status bar to never be shown.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// Override function to force the system to reject gestures from the bottom of the screen.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}

