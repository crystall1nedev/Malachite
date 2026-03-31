//
//  Photo.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/17/26.
//

import AVFoundation
import Foundation
import Photos
import UIKit

class Photo: NSObject {
    var imageData = Data()
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities: MalachiteClassesObject!
    
    var location: Location!
    
    init(
        data: Data,
        utilities: MalachiteClassesObject,
        location: Location
    ) {
        self.imageData = data
        self.utilities = utilities
        self.location = location
    }
    /// A variable to store whether or not HDR is enabled.
    let enableHDR = MalachitePreferencesUtils.shared.preferences.capture.hdr
    /// A variable to store whether or not the HEIC file format is enabled.
    let enableHEIC = MalachitePreferencesUtils.shared.preferences.capture.format.heic
    
    /**
     Function to prepare the image for final export.
     
     Currently, this function does the following:
     - Creates an image from the ``photoImageData`` that was passed on creation of the view controller.
     - If ``enableHDR`` is enabled, creates a gain map image with HDR data inside.
     - If the user has enabled watermarking, creates an image with the watermark and the original image's dimensions.
     - If ``enableHEIC`` is enabled, create a HEIC representation of all above images combined. Otherwise, JPEG is used.
     */
    public func finalizeImageForExport(imageData: Data) -> Data {
        guard let rawImage = CIImage(data: imageData, options: [.toneMapHDRtoSDR : (enableHDR ? true : false)]) else { return Data() }

        let exifOrientationValue = (rawImage.properties[kCGImagePropertyOrientation as String] as? NSNumber)?.intValue
        let orientedCI: CIImage
        if let exif = exifOrientationValue, let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(exif)) {
            orientedCI = rawImage.oriented(cgOrientation)
        } else {
            orientedCI = rawImage
        }

        let context = CIContext()
        guard let cg = context.createCGImage(orientedCI, from: orientedCI.extent) else { return Data() }
        let upright = CIImage(cgImage: cg)
        
        var imageProperties = rawImage.properties
        
        if var tiff = imageProperties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            tiff[kCGImagePropertyTIFFOrientation as String] = 1
            imageProperties[kCGImagePropertyTIFFDictionary as String] = tiff
        }
        
        imageProperties[kCGImagePropertyOrientation as String] = 1
        
        if location.locationEnabled && utilities.versionType == "INTERNAL" && utilities.preferences.evaintrnl.locationEnabled, let loc = location.location.location {
            let gps       = NSMutableDictionary()
            let formatter = DateFormatter()
            
            // This is actually slightly more verbose than the stock camera app LOL
            gps[kCGImagePropertyGPSAltitude]          = (loc.altitude >= 0.0) ? loc.altitude : -loc.altitude
            gps[kCGImagePropertyGPSAltitudeRef]       = (loc.altitude >= 0.0) ? 0 : 1
            formatter.dateFormat = "yyyy:MM:dd"
            gps[kCGImagePropertyGPSDateStamp]         = formatter.string(from:loc.timestamp)
            gps[kCGImagePropertyGPSDOP]               = loc.horizontalAccuracy
            gps[kCGImagePropertyGPSHPositioningError] = loc.horizontalAccuracy
            gps[kCGImagePropertyGPSLatitudeRef]       = (loc.coordinate.latitude >= 0.0) ? "N" : "S"
            gps[kCGImagePropertyGPSLatitude]          = (loc.coordinate.latitude >= 0.0) ? loc.coordinate.latitude : -loc.coordinate.latitude
            gps[kCGImagePropertyGPSLongitudeRef]      = (loc.coordinate.longitude >= 0.0) ? "E" : "W"
            gps[kCGImagePropertyGPSLongitude]         = (loc.coordinate.longitude >= 0.0) ? loc.coordinate.longitude : -loc.coordinate.longitude
            gps[kCGImagePropertyGPSSpeedRef]          = "K"
            gps[kCGImagePropertyGPSSpeed]             = loc.speed
            formatter.dateFormat = "HH:mm:ss"
            gps[kCGImagePropertyGPSTimeStamp]         = formatter.string(from:loc.timestamp)
            
            if let heading = location.location.heading {
                gps[kCGImagePropertyGPSDestBearingRef] = "T"
                gps[kCGImagePropertyGPSDestBearing] = heading.trueHeading
                gps[kCGImagePropertyGPSImgDirectionRef] = "T"
                gps[kCGImagePropertyGPSImgDirection] = heading.trueHeading
            }
            
            imageProperties[kCGImagePropertyGPSDictionary as String] = gps
        }

        let canvasSize = upright.extent.size
        let watermarkUIImage = self.watermark(canvasSize: canvasSize)
        let watermarkImage = CIImage(image: watermarkUIImage)

        let outputImage = (watermarkImage ?? CIImage()).composited(over: upright)

        let gainMap = returnGainMap(properties: &imageProperties, imageData: imageData)
        let outputImageWithProps = outputImage.settingProperties(imageProperties)

        if utilities.preferences.debug.logging.imageProps {
            for prop in imageProperties {
                MalachiteClassesObject().internalNSLog("[Capture Photo] \(prop)")
            }
        }
        
        return returnImageFile(
            imageForRepresentation: outputImageWithProps,
            imageForGainMap: gainMap,
            imageColorspace: rawImage.colorSpace?.name,
            imageProperties: imageProperties
        )
    }
    
    /**
     Function to watermark the image that was taken.
     
     FIX: A lot of things here, primarly watermark and image rotation being misaligned.
     */
    func watermark(canvasSize: CGSize, inset: CGPoint = CGPoint(x: 20, y: 20)) -> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: canvasSize))
        imageView.backgroundColor = .clear

        guard utilities.preferences.watermark.enabled else {
            UIGraphicsBeginImageContextWithOptions(canvasSize, false, 1)
            let img = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return img
        }

        let text = utilities.preferences.watermark.text
        let font = UIFont.monospacedSystemFont(ofSize: 70, weight: .regular)

        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.text = text
        label.font = font
        label.backgroundColor = .clear
        label.numberOfLines = 1

        label.sizeToFit()
        
        let originalSize = label.bounds.size
        
        label.frame = CGRect(origin: .zero, size: originalSize)
        label.transform = CGAffineTransform(rotationAngle: .pi / 2)
        let finalX = canvasSize.width - inset.x - originalSize.height
        let finalY = inset.y
        label.frame.origin = CGPoint(x: finalX, y: finalY)

        imageView.addSubview(label)

        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 1)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageWithText
    }
    
    /// Function to return a HEIC representation of the passed image  with its colorspace and an optional gain map image.
    func returnImageFile(imageForRepresentation image: CIImage, imageForGainMap hdrImage: CIImage?, imageColorspace colorSpace: CFString?, imageProperties: [String: Any]) -> Data {
        let context = CIContext()
        
        let finalSpace = CGColorSpace(name: colorSpace ?? CGColorSpace.sRGB)!
        let metadataKey = CIImageRepresentationOption(rawValue: kCGImageDestinationMetadata as String)
        
        var options: [CIImageRepresentationOption: Any] = [ metadataKey: imageProperties ]
        if enableHDR, let hdr = hdrImage { options[.hdrGainMapImage] = hdr }
        
        let types = CGImageDestinationCopyTypeIdentifiers() as NSArray
        let useHEIC = enableHEIC && types.contains("public.heic")
        
        if useHEIC {
            utilities.debugNSLog("[Capture Photo] Saving HEIC representation")
            return context.heifRepresentation(
                of: image,
                format: .RGBAf,
                colorSpace: finalSpace,
                options: options
            ) ?? Data()
        } else {
            utilities.debugNSLog("[Capture Photo] Saving JPEG representation")
            return context.jpegRepresentation(
                of: image,
                colorSpace: finalSpace,
                options: options
            ) ?? Data()
        }
    }

    
    /// Function to extract gain map data from the image.
    func returnGainMap(properties props: inout [String: Any], imageData: Data) -> CIImage? {
        if !enableHDR { return nil }
        var gainMapImage = CIImage()

        guard let source = CGImageSourceCreateWithData(NSData(data: imageData), nil) else { return nil }

        let propsDict = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let orientationCF = propsDict?[kCGImagePropertyOrientation] as? NSNumber
        let sourceOrientation = orientationCF.flatMap { CGImagePropertyOrientation(rawValue: $0.uint32Value) }
        let key: CFString
        
        if #available(iOS 18.0, *) { key = kCGImageAuxiliaryDataTypeISOGainMap }
        else { key = kCGImageAuxiliaryDataTypeHDRGainMap }

        if let gainMapDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, key) as? Dictionary<CFString, Any> {
            utilities.debugNSLog("[Capture Photo] Saving gain map properties from image")
            let gainMapData = gainMapDataInfo[kCGImageAuxiliaryDataInfoData] as! Data
            let gainMapDescription = gainMapDataInfo[kCGImageAuxiliaryDataInfoDataDescription]! as! [String: Int]
            let gainMapSize = CGSize(width: gainMapDescription["Width"]!, height: gainMapDescription["Height"]!)
            let gainMapciImage = CIImage(bitmapData: gainMapData,
                                         bytesPerRow: gainMapDescription["BytesPerRow"]!,
                                         size: gainMapSize,
                                         format: .L8, colorSpace: nil)

            let orientedGainMap: CIImage
            if let srcOri = sourceOrientation {
                orientedGainMap = gainMapciImage.oriented(srcOri)
            } else {
                orientedGainMap = gainMapciImage
            }

            let context = CIContext()
            let gainMapcgImage = context.createCGImage(orientedGainMap,
                                                       from: CGRect(origin: CGPoint(x: 0, y: 0), size: orientedGainMap.extent.size))!
            let gainMapOutputData = NSMutableData()
            let gainMapDest = CGImageDestinationCreateWithData(gainMapOutputData, UTType.bmp.identifier as CFString, 1, nil)
            CGImageDestinationAddImage(gainMapDest!, gainMapcgImage, [:] as CFDictionary)
            CGImageDestinationFinalize(gainMapDest!)

            gainMapImage = CIImage(data: gainMapOutputData as Data)!

            var applDict = extractEXIFData(properties: props, dictionary: kCGImagePropertyMakerAppleDictionary)
            var exifDict = extractEXIFData(properties: props, dictionary: kCGImagePropertyExifDictionary)

            applDict["33"]             = 0.0
            applDict["48"]             = 0.0
            applDict["HDRImageType"]   = 3
            exifDict["CustomRendered"] = 2

            props[kCGImagePropertyMakerAppleDictionary as String] = applDict
            props[kCGImagePropertyExifDictionary as String] = exifDict
        } else {
            utilities.debugNSLog("[Capture Photo] Couldn't save the gain map properties. Opting to ignore.")
        }

        return gainMapImage
    }
    
    /**
     Function to extract EXIF properties from the image.
     
     Currently used to extract MakerApple and the EXIFDictionary for HDR.
     */
    func extractEXIFData(properties props: [String : Any], dictionary dict: CFString) -> [String : Any] {
        return props[dict as String] as? [String: Any] ?? [:]
    }
    
}
