//
//  Compatibility.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 9/21/25.
//

import AVFoundation
import Foundation

class Compatibility {
    private var utilities: MalachiteClassesObject
    
    init( utilities: MalachiteClassesObject ) {
        self.utilities = utilities
    }
    
    /// Determines if the passed device's activeFormat supports HDR.
    public func checkDeviceForHDRCompatibility(device: AVCaptureDevice) {
        if utilities.preferences.compatibility.hdr != device.activeFormat.isVideoHDRSupported {
            utilities.debugNSLog("[Compatibility] HDR compatibility has changed on the current camera's active format.")
            utilities.preferences.compatibility.hdr = device.activeFormat.isVideoHDRSupported
        }
    }
    
    /**
     Checks whether or not the current device is capable of encoding High Efficiency Image Format.
     
     If the device doesn't support HEIF, the option is disabled in preferences to prevent crashes.
     
     HEIF is supported on Apple devices with the A10 Fusion chip or later.
     */
    func checkDeviceForHEICCompatibility() {
        if !utilities.preferences.compatibility.device.changed { return }
        
        let supportedTypeIdentifiers = CGImageDestinationCopyTypeIdentifiers() as NSArray
        if utilities.preferences.compatibility.jpeg != supportedTypeIdentifiers.contains("public.jpeg") {
            utilities.debugNSLog("[Compatibility] JPEG compatibility has changed on this device.")
            utilities.preferences.compatibility.jpeg = supportedTypeIdentifiers.contains("public.jpeg")
        }
        if utilities.preferences.compatibility.heic != supportedTypeIdentifiers.contains("public.heic") {
            utilities.debugNSLog("[Compatibility] HEIC compatibility has changed on this device.")
            utilities.preferences.compatibility.heic = supportedTypeIdentifiers.contains("public.heic")
        }
    }
    
    /// Determines what resolutions that the passed ``AVCaptureDevice`` is capable of shooting.
    func checkCameraCapabilities(device: AVCaptureDevice) {
        var tmpDictionary = Dictionary<String, Bool>()
        for format in device.formats {
            var maxDimensions: CMVideoDimensions
            if #available (iOS 16.0, *) {
                maxDimensions = format.supportedMaxPhotoDimensions[format.supportedMaxPhotoDimensions.count - 1]
            } else {
                maxDimensions = format.highResolutionStillImageDimensions
            }
            if format == device.formats[0] { utilities.debugNSLog("[Compatibility] Querying supported modes of \(device.deviceType.rawValue)") }
            if maxDimensions.width == 3264 && maxDimensions.height == 2448 { tmpDictionary["8"] = true }
            if maxDimensions.width == 4032 && maxDimensions.height == 3024 { tmpDictionary["12"] = true }
            if maxDimensions.width == 8064 && maxDimensions.height == 6048 { tmpDictionary["48"] = true }
            switch device.deviceType {
            case .builtInUltraWideCamera:
                utilities.preferences.compatibility.ultrawide = tmpDictionary
            case .builtInWideAngleCamera:
                utilities.preferences.compatibility.wideangle = tmpDictionary
            case .builtInTelephotoCamera:
                utilities.preferences.compatibility.telephoto = tmpDictionary
            default:
                break
            }
        }
        utilities.debugNSLog("[Compatibility] \(device.deviceType.rawValue): \(tmpDictionary)")
    }
}
