//
//  SettingsView+Photo.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct Photo: View {
        /// A State variable used for presenting the user with a footer based on capabilities.
        @State private var formatFooterText: String?
        /// A State variable used for determining the active photo format.
        @State private var photoFormat = Int()
        /// A State variable used for determining whether or not to capture in HDR.
        @State private var hdrSwitch = false
        /// A State variable used for determining whether or not to enable continuous auto exposure.
        @State private var continuousAEAF = Int()
        /// A State variable used for determining whether or not this view is being presented as a modal.
        var dismissAction: (() -> Void)
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
            dismissAction: @escaping (() -> Void)
        ) {
            self.utilities = utilities
            self.dismissAction = dismissAction
        }
        
        var body: some View {
            Section(header: Text("settings.header.photo"), footer: (formatFooterText != nil) ? Text(formatFooterText!) : nil) {
                MalachiteCellViewUtils(
                    icon: "square.and.arrow.down",
                    disabled: !utilities.preferences.compatibility.heic,
                    dangerous: false)
                {
                    Picker("settings.option.photo.fileformat", selection: $photoFormat) {
                        Text("settings.option.photo.fileformat.jpeg")
                            .tag(0)
                        Text("settings.option.photo.fileformat.heic")
                            .tag(1)
                    }
                }
                
                MalachiteCellViewUtils(
                    icon: "camera.filters",
                    disabled: !utilities.preferences.compatibility.hdr,
                    dangerous: false)
                {
                    Toggle("settings.option.photo.hdr", isOn: $hdrSwitch )
                }
                MalachiteCellViewUtils(
                    icon: "plus.viewfinder",
                    disabled: nil,
                    dangerous: false)
                {
                    Picker("settings.option.photo.continuous", selection: $continuousAEAF) {
                        Text("settings.option.reusable.aeaf")
                            .tag(0)
                        Text("settings.option.reusable.af")
                            .tag(1)
                        Text("settings.option.reusable.ae")
                            .tag(2)
                        Text("settings.option.reusable.off")
                            .tag(3)
                    }
                }
            }
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            .onChange(of: photoFormat) {_ in
                utilities.preferences.capture.format.jpeg = photoFormat == 0 ? true : false
                utilities.preferences.capture.format.heic = photoFormat == 1 ? true : false
            }
            .onChange(of: hdrSwitch) { _ in
                if utilities.preferences.compatibility.hdr { utilities.preferences.capture.hdr = hdrSwitch }
            }
            .onChange(of: continuousAEAF) { _ in
                switch continuousAEAF {
                case 0:
                    utilities.preferences.capture.continuous = ["ae", "af"]
                case 1:
                    utilities.preferences.capture.continuous = ["af"]
                case 2:
                    utilities.preferences.capture.continuous = ["ae"]
                default:
                    utilities.preferences.capture.continuous = ["off"]
                }
                
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
            }
        }
        
        func onAppear() {
            if !utilities.preferences.compatibility.heic { formatFooterText = "settings.footer.photo.heic".localized }
            
            if !utilities.preferences.compatibility.hdr {
                formatFooterText = (formatFooterText != nil) ? formatFooterText! + "settings.footer.photo.hdr".localized : "settings.footer.photo.hdr".localized
            } else {
                hdrSwitch = utilities.preferences.capture.hdr
            }
            
            // TODO: Better way to do this
            photoFormat = utilities.preferences.capture.format.jpeg ? 0 : 1
            photoFormat = utilities.preferences.capture.format.heic ? 1 : 0
            
            switch utilities.preferences.capture.continuous {
            case ["ae", "af"]:
                continuousAEAF = 0
            case ["af"]:
                continuousAEAF = 1
            case ["ae"]:
                continuousAEAF = 2
            default:
                continuousAEAF = 3
            }
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
            
            if utilities.preferences.compatibility.hdr { utilities.preferences.capture.hdr = hdrSwitch }
            utilities.preferences.capture.format.jpeg = photoFormat == 0 ? true : false
            utilities.preferences.capture.format.heic = photoFormat == 1 ? true : false
            
            switch continuousAEAF {
            case 0:
                utilities.preferences.capture.continuous = ["ae", "af"]
            case 1:
                utilities.preferences.capture.continuous = ["af"]
            case 2:
                utilities.preferences.capture.continuous = ["ae"]
            default:
                utilities.preferences.capture.continuous = ["off"]
            }
        }
    }
}
