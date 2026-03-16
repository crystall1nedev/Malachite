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
        /// An existing instance of the ``Camera`` class.
        var parent: Camera
        
        /// Initailizer function for the ``Camera/Input`` class.
        init( parent: Camera ) { self.parent = parent }
        
        /**
         Changes the current device providing input to ``Camera/session``.
         
         A quick rundown of this function:
         - Checks whether or not there is a camera available for switching using ``selectDeviceForSwitch()``
         - Checks whether or not there is a camera already providing an input to ``Camera.session``, and removing it
         - Configures the currently active format on the new camera to the highest quality and resolution possible
         - Sends notifications about unsupported features such as focus or exposure with ``handleUnsupportedFeaturesOnSwitch(supported:notification:)``
         - Creates and attaches an input with the ``Camera/device`` object to ``Camera/session``
         */
        @objc func runInputSwitch() {
            parent.device = selectDeviceForSwitch()
            guard let device = parent.device else { return }
            
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
        
        /**
         Returns a new `AVCaptureDevice` object to be used for camera switching.
         
         > Warning: Don't call this function manually if using ``runInputSwitch()`` - it's already called there.
         
         > Info: The camera that's chosen depends on how the user initiated this call. If they used the Camera Control on iPhone
         16 and later, this function switches to the specific camera they chose in the overlay. Otherwise, this function simply chooses
         the next available camera in ``Camera/cameras``, or the first if the existing camera is at the end of the array.
         */
        public func selectDeviceForSwitch() -> AVCaptureDevice? {
            if parent.cameras.count > 0 {
                if parent.index != nil { return parent.cameras[parent.index!] } else {
                    if parent.session.inputs.isEmpty {
                        return parent.cameras.first
                    } else {
                        if let devicePosition = parent.cameras.firstIndex(of: parent.device!) {
                            return parent.cameras[(devicePosition == (parent.cameras.count - 1)) ? 0 : devicePosition + 1]
                        }
                    }
                }
            }
            return nil
        }
        
        /**
         Enables or disables HDR on the passed `AVCaptureDevice`
         
         MalachiteKit's HDR implementation is built on Apple's APIs from iOS 14.1 on iPhone 12 and later. The user
         is also provided with the facility to disable HDR should they need or want to.
         
         > Info: Supporting HDR on older iPhone models is being researched and will be available in a future release.
         */
        public func setHDREnabledOnDevice(device: AVCaptureDevice) {
            parent.compatibility.checkDeviceForHDRCompatibility(device: device)
            
            parent.utilities.debugNSLog("[Camera Input] Checking if we should enable HDR: supportedByDevice: \(parent.utilities.preferences.compatibility.hdr), enabledInPreferences: \(parent.utilities.preferences.capture.hdr)")
            
            device.automaticallyAdjustsVideoHDREnabled = false
            
            if parent.utilities.preferences.compatibility.hdr { device.isVideoHDREnabled = parent.utilities.preferences.capture.hdr }
            
            parent.utilities.debugNSLog("[Camera Input]" + (device.isVideoHDREnabled ? "Disabling HDR" : " Enabling HDR"))
            
            if device.activeFormat.isGlobalToneMappingSupported { device.isGlobalToneMappingEnabled = false }
        }
        
        /**
         Changes the maxPhotoDimensions property on the passed `AVCapturePhotoOutput`.
         
         MalachiteKit supports 8MP, 12MP, and 48MP cameras. See Apple's Tech Specs page for information on the capabilities
         of specific devices.
         */
        @available(iOS 16.0, *)
        @objc public func switchInputMegapixels(device: AVCaptureDevice, photoOutput: AVCapturePhotoOutput) {
            guard device.position == .back else { return }
            
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
            }
        }
    }
}
