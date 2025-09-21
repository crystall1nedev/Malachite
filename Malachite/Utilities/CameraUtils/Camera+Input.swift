//
//  Camera+Input.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 9/11/25.
//

import AVFoundation
import Foundation

extension Camera {
    class Input {
        var parent: Camera
        
        init( parent: Camera ) { self.parent = parent }
        
        /// Function to switch cameras and attach new inputs to ``cameraSession``, and set settings based on the `activeFormat` of ``selectedDevice``.
        @objc func runInputSwitch() {
            parent.currentDevice = selectDeviceForSwitch()
            guard let device = parent.currentDevice else { return }
            
            parent.session.beginConfiguration()
            let sessionIsEmpty = parent.session.inputs.isEmpty
            parent.utilities.debugNSLog("[Camera Input] Getting ready to configure session")
            
            if !sessionIsEmpty {
                parent.utilities.debugNSLog("[Camera Input] Removing currently active camera input")
                parent.session.removeInput(parent.session.inputs[0])
            }
            
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                parent.utilities.debugNSLog("[Camera Input] Selected input: \(String(describing: device.formats[(device.formats.count) - 1]))")
                device.activeFormat = (device.formats[(device.formats.count) - 1])
                parent.utilities.function.continuousAEAF(device: device)
                
                handleUnsupportedFeaturesOnSwitch(supported: device.isLockingFocusWithCustomLensPositionSupported,
                                                  notification: MalachiteFunctionUtils.Notifications.unsupportedLensPositionNotification.name)
                
                handleUnsupportedFeaturesOnSwitch(supported: device.isExposureModeSupported(.custom),
                                                  notification: MalachiteFunctionUtils.Notifications.unsupportedISOValueNotification.name)
                
                self.setHDREnabledOnDevice(device: device)
            } catch {
                parent.utilities.debugNSLog("[Camera Input] Error adjusting device properties: \(error.localizedDescription)")
            }
            
            
            parent.utilities.debugNSLog("[Camera Input] Attempting to attach device input to session")
            var input: AVCaptureDeviceInput?
            do { input = try AVCaptureDeviceInput(device: device) }
            catch { print(error) }
            guard let input = input else { return }
            
            parent.utilities.debugNSLog("[Camera Input] Attached input, finishing configuration")
            if parent.session.canAddInput(input) && !parent.session.inputs.contains(input) { parent.session.addInput(input) }
            parent.setupPhotoOutput()
            if #available(iOS 16.0, *) { switchInputMegapixels(device: device, photoOutput: parent.output) }
            parent.session.commitConfiguration()
            
            if #available(iOS 16.0, *) {
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
            }
        }
        
        public func handleUnsupportedFeaturesOnSwitch(supported: Bool, notification: NSNotification.Name) {
            if !supported { NotificationCenter.default.post(name: notification, object: nil) }
        }
        
        public func selectDeviceForSwitch() -> AVCaptureDevice? {
            if parent.cameras.count > 0 {
                if parent.currentIndex != nil { return parent.cameras[parent.currentIndex!] } else {
                    if parent.session.inputs.isEmpty {
                        return parent.cameras.first
                    } else {
                        if let devicePosition = parent.cameras.firstIndex(of: parent.currentDevice!) {
                            return parent.cameras[(devicePosition == (parent.cameras.count - 1)) ? 0 : devicePosition + 1]
                        }
                    }
                }
            }
            return nil
        }
        
        public func setHDREnabledOnDevice(device: AVCaptureDevice) {
            parent.compatibility.checkDeviceForHDRCompatibility(device: device)
            
            parent.utilities.debugNSLog("[Camera Input] Checking if we should enable HDR: supportedByDevice: \(parent.utilities.preferences.compatibility.hdr), enabledInPreferences: \(parent.utilities.preferences.capture.hdr)")
            
            device.automaticallyAdjustsVideoHDREnabled = false
            device.isVideoHDREnabled = (parent.utilities.preferences.compatibility.hdr && parent.utilities.preferences.capture.hdr)
            
            parent.utilities.debugNSLog("[Camera Input]" + (device.isVideoHDREnabled ? "Disabling HDR" : " Enabling HDR"))
            
            if device.activeFormat.isGlobalToneMappingSupported { device.isGlobalToneMappingEnabled = false }
        }
        
        @available(iOS 16.0, *)
        @objc public func switchInputMegapixels(device: AVCaptureDevice, photoOutput: AVCapturePhotoOutput) {
            let maxDimensions = device.activeFormat.supportedMaxPhotoDimensions[device.activeFormat.supportedMaxPhotoDimensions.count - 1]
            
            var mpSetting = Int()
            
            switch device.deviceType {
            case .builtInUltraWideCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.ultrawide
            case .builtInWideAngleCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.wideangle
            case .builtInTelephotoCamera:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.telephoto
            default:
                mpSetting = MalachitePreferencesUtils.shared.preferences.capture.mp.wideangle
            }
            
            switch mpSetting {
            case 48:
                parent.utilities.debugNSLog("[Camera Input] Switching \(device.deviceType.rawValue) to 48MP mode")
                if maxDimensions.width == 8064 && maxDimensions.height == 6048 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 8064, height: 6048) }
            case 12:
                parent.utilities.debugNSLog("[Camera Input] Switching \(device.deviceType.rawValue) to 12MP mode")
                if maxDimensions.width == 4032 && maxDimensions.height == 3024 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024) }
            default:
                parent.utilities.debugNSLog("[Camera Input] Switching \(device.deviceType.rawValue) to 8MP mode")
                if maxDimensions.width == 3264 && maxDimensions.height == 2448 { photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 3264, height: 2448) }
            }
        }
    }
}
