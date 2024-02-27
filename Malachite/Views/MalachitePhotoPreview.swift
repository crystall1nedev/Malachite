//
//  MalachitePhotoPreview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/27/23.
//

import Foundation
import UIKit
import Photos
import LinkPresentation

class MalachitePhotoPreview : UIViewController {
    var utilities = MalachiteClassesObject()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var photoImageData = Data()
    var photoImage = UIImage()
    var watermarkedImage = UIImage()
    
    var finalizedImage = Data()
    
    var dismissButton = UIButton()
    var savePhotoButton = UIButton()
    var sharePhotoButton = UIButton()
    
    let fixedOrientation = UIDevice.current.orientation
    
    let enableHDR = MalachiteClassesObject().settings.defaults.bool(forKey: "format.hdr.enabled")
    let enableHEIF = MalachiteClassesObject().settings.defaults.bool(forKey: "format.type.heif")
    
    override func viewDidLoad() {
        self.finalizedImage = self.finalizeImageForExport()
        
        super.viewDidLoad()
        self.view.backgroundColor = .red
        
        var rotation = -1.0
        var rotatedImage = UIImage()
        
        if utilities.idiom == .phone {
            switch fixedOrientation {
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
        } else {
            rotation = Double.pi * 2
        }
        
        rotatedImage = photoImage.rotate(radians: Float(rotation))!
        let blurredBackgroundView = UIImageView(frame: self.view.bounds)
        blurredBackgroundView.image = rotatedImage
        blurredBackgroundView.layer.contentsGravity = .resizeAspectFill
        blurredBackgroundView.addSubview(utilities.views.returnProperBlur(viewForBounds: self.view, blurStyle: .systemUltraThinMaterialDark))
        blurredBackgroundView.clipsToBounds = true
        
        photoImageView.image = rotatedImage
        photoImageView.layer.contentsGravity = .resizeAspect
        
        self.view.addSubview(blurredBackgroundView)
        self.view.addSubview(photoImageView)
        
        
        dismissButton = utilities.views.returnProperButton(symbolName: "xmark", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 60),
            dismissButton.heightAnchor.constraint(equalToConstant: 60),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        dismissButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        
        savePhotoButton = utilities.views.returnProperButton(symbolName: "photo.on.rectangle", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(savePhotoButton)
        NSLayoutConstraint.activate([
            savePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 60),
            savePhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            savePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        savePhotoButton.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        
        sharePhotoButton = utilities.views.returnProperButton(symbolName: "square.and.arrow.up", cornerRadius: 30, viewForBounds: self.view, hapticClass: utilities.haptics)
        self.view.addSubview(sharePhotoButton)
        NSLayoutConstraint.activate([
            sharePhotoButton.widthAnchor.constraint(equalToConstant: 60),
            sharePhotoButton.heightAnchor.constraint(equalToConstant: 60),
            sharePhotoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            sharePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        sharePhotoButton.addTarget(self, action: #selector(self.sharePhoto), for: .touchUpInside)
        
        orientationChanged()
        
        utilities.tooltips.capturedTooltipFlow(viewForBounds: self.view)
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
                // I can move some of these variables out of this function and class-wide
                let createRequest = PHAssetCreationRequest.forAsset()
                createRequest.addResource(with: .photo, data: finalizedImage, options: nil)
                NSLog("[Capture Photo] Photo has been saved to the user's library")
                self.utilities.haptics.triggerNotificationHaptic(type: .success)
                self.dismissView()
            }
        } catch let error {
            NSLog("[Capture Photo] Photo couldn't be saved to the user's library: %@", error.localizedDescription)
        }
    }
    
    @objc private func sharePhoto() {
        let shareableData = try! dataToShareable(data: finalizedImage, title: "Image captured with Malachite")
        let shareSheet = UIActivityViewController(activityItems: [shareableData], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = self.view
        self.present(shareSheet, animated: true)
    }
    
    func finalizeImageForExport() -> Data {
        var data = Data()
        var rawImage = CIImage()
        var gainMapImage = CIImage()
        
        if enableHDR {
            rawImage = CIImage(data: self.photoImageData)!
        } else {
            rawImage = CIImage(data: self.photoImageData, 
                               options: [.toneMapHDRtoSDR : true])!
        }
        
        var imageProperties = rawImage.properties
        let watermarkImage = CIImage(image: self.watermark())
        let outputImage = watermarkImage!.composited(over: rawImage)
        
        if enableHDR {
            gainMapImage = returnGainMap(properties: &imageProperties)
        }
        
        for prop in imageProperties {
            print("[Capture Photo]", prop)
        }
        
        let outputImageWithProps = outputImage.settingProperties(imageProperties)
        
        if enableHEIF {
            data = returnHEIC(imageForRepresentation: outputImageWithProps, imageForGainMap: gainMapImage, imageColorspace: rawImage.colorSpace?.name)
        } else {
            data = returnJPEG(imageForRepresentation: outputImageWithProps, imageForGainMap: gainMapImage, imageColorspace: rawImage.colorSpace?.name)
        }
        
        return data
    }
    
    func watermark() -> UIImage
    {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        
        if photoImage.size.width < photoImage.size.height {
            imageView.frame = CGRect(x:0, y:0, width:photoImage.size.height, height:photoImage.size.width)
        } else {
            imageView.frame = CGRect(x:0, y:0, width:photoImage.size.width, height:photoImage.size.height)
        }
        
        if utilities.settings.defaults.bool(forKey: "wtrmark.enabled") {
            NSLog("[Watermarking] User has opted to show a watermark")
            var label = UILabel()
            label = UILabel(frame: CGRect(x:50, y:20, width:photoImage.size.width - 100, height:120))
            label.textAlignment = .left
            label.textColor = .white
            label.text = utilities.settings.defaults.string(forKey: "wtrmark.text")
            label.font = UIFont(name: "Menlo", size: 70)
            
            imageView.addSubview(label)
        }
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return imageWithText!
    }
    
    func returnHEIC(imageForRepresentation image: CIImage, imageForGainMap hdrImage: CIImage?, imageColorspace colorSpace: CFString?) -> Data {
        let types = CGImageDestinationCopyTypeIdentifiers() as NSArray
        if types.contains("public.heic") {
            if enableHDR && (hdrImage != nil){
                return CIContext().heifRepresentation(of: image, format: .RGBA8, colorSpace: CGColorSpace(name: colorSpace!)!, options:  [ .hdrGainMapImage : hdrImage! ])!
            } else {
                return CIContext().heifRepresentation(of: image, format: .RGBA8, colorSpace: CGColorSpace(name: colorSpace!)!)!
            }
        } else {
            NSLog("[Capture Photo] Device does not support encoding HEIF, falling back to JPEG")
            utilities.settings.defaults.set(false, forKey: "format.type.heif")
            return returnJPEG(imageForRepresentation: image, imageForGainMap: hdrImage, imageColorspace: colorSpace)
        }
    }
    
    func returnJPEG(imageForRepresentation image: CIImage, imageForGainMap hdrImage: CIImage?, imageColorspace colorSpace: CFString?) -> Data {
        NSLog("[Capture Photo] HEIF is disabled, saving JPEG representation")
        if enableHDR && (hdrImage != nil) {
            return CIContext().jpegRepresentation(of: image, colorSpace: CGColorSpace(name: colorSpace!)!, options: [ .hdrGainMapImage : hdrImage! ])!
        } else {
            return CIContext().jpegRepresentation(of: image, colorSpace: CGColorSpace(name: colorSpace!)!)!
        }
    }
    
    func returnGainMap(properties props: inout [String: Any]) -> CIImage {
        var gainMapImage = CIImage()
        if let gainMapDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(CGImageSourceCreateWithData(NSData(data: self.photoImageData), nil)!, 0, kCGImageAuxiliaryDataTypeHDRGainMap) as? Dictionary<CFString, Any> {
            NSLog("[Capture Photo] Saving gain map properties from image")
            let gainMapData = gainMapDataInfo[kCGImageAuxiliaryDataInfoData] as! Data
            let gainMapDescription = gainMapDataInfo[kCGImageAuxiliaryDataInfoDataDescription]! as! [String: Int]
            let gainMapSize = CGSize(width: gainMapDescription["Width"]!, height: gainMapDescription["Height"]!)
            let gainMapciImage = CIImage(bitmapData: gainMapData,
                                         bytesPerRow: gainMapDescription["BytesPerRow"]!,
                                         size: gainMapSize,
                                         format: .L8, colorSpace: nil)
            let gainMapcgImage = CIContext().createCGImage(gainMapciImage,
                                                           from: CGRect(origin: CGPoint(x: 0, y: 0), size: gainMapSize))!
            let gainMapOutputData = NSMutableData()
            let gainMapDest = CGImageDestinationCreateWithData(gainMapOutputData, UTType.bmp.identifier as CFString, 1, nil)
            CGImageDestinationAddImage(gainMapDest!, gainMapcgImage, [:] as CFDictionary)
            CGImageDestinationFinalize(gainMapDest!)
            
            gainMapImage = CIImage(data: gainMapOutputData as Data)!
            
            var applDict = extractEXIFData(properties: props, dictionary: kCGImagePropertyMakerAppleDictionary)
            var exifDict = extractEXIFData(properties: props, dictionary: kCGImagePropertyExifDictionary)
            
            applDict["33"] = 0.0
            applDict["48"] = 0.0
            exifDict["CustomRendered"] = 2
            
            props[kCGImagePropertyMakerAppleDictionary as String] = applDict
            props[kCGImagePropertyExifDictionary as String] = exifDict
        } else {
            NSLog("[Capture Photo] Couldn't save the gain map properties. Opting to ignore.")
        }
        
        return gainMapImage
    }
    
    func extractEXIFData(properties props: [String : Any], dictionary dict: CFString) -> [String : Any] {
        return props[dict as String] as? [String: Any] ?? [:]
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
}


final class dataToShareable: NSObject, UIActivityItemSource {
    let data: Data
    let title: String
    
    init(data: Data, title: String) throws {
        self.title = title
        self.data = data
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        data
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        data
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        return metadata
    }
}
