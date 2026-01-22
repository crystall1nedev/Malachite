//
//  SettingsView+Preview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct Preview: View {
        /// A State variable used for determining the current aspect ratio for the ``cameraPreview``.
        @State private var previewAspect = Int()
        /// A State variable used for determining whether or not to stabilize the ``cameraPreview``.
        @State private var shouldStabilize = Bool()
        /// A State variable used for determining whether or not to skip opening ``MalachitePhotoPreview`` and save the photo.
        @State private var shouldUseFastPath = Bool()
        /// A State variable used for determining what the maximum zoom level for each camera should be.
        @State private var zoomMaximum = Int()
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
        
        /// A variable to hold the preview settings section.
        var body: some View {
            Section(header: Text("settings.header.preview")) {
                MalachiteCellViewUtils(
                    icon: "aspectratio",
                    disabled: false,
                    dangerous: false)
                {
                    Picker("settings.option.preview.aspect_ratio", selection: $previewAspect) {
                        Text("settings.option.preview.aspect_ratio.fit")
                            .tag(0)
                        Text("settings.option.preview.aspect_ratio.fill")
                            .tag(1)
                    }
                }
                MalachiteCellViewUtils(
                    icon: "level",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("settings.option.preview.sbtlz", isOn: $shouldStabilize)
                }
                // Testing things out
                if utilities.versionType == "INTERNAL" {
                    MalachiteCellViewUtils(
                        icon: "forward",
                        disabled: nil,
                        dangerous: false)
                    {
                        Toggle("settings.option.preview.fastpath", isOn: $shouldUseFastPath)
                    }
                }
                MalachiteCellViewUtils(
                    icon: "plus.magnifyingglass",
                    disabled: nil,
                    dangerous: false)
                {
                    Stepper {
                        Text("settings.option.preview.zoom_maximum")
                    } onIncrement: {
                        if zoomMaximum < 10 { zoomMaximum += 1 }
                    } onDecrement: {
                        if zoomMaximum > 5 { zoomMaximum -= 1 }
                    }
                    Text(String(format: "%lldx", Int(zoomMaximum)))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            // Called when the preview's aspect ratio is changed.
            .onChange(of: previewAspect) {_ in
                utilities.preferences.preview.aspect = (previewAspect == 1)
                
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
            }
            // Called when the user enables/disables preview stabilization.
            .onChange(of: shouldStabilize) {_ in
                utilities.preferences.preview.stablize = shouldStabilize
                
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
            }
            // Called when the user enables/disables the fast path.
            .onChange(of: shouldUseFastPath) {_ in
                utilities.preferences.preview.fastPath = shouldUseFastPath
            }
            // Called when the maximum zoom level changes.
            .onChange(of: zoomMaximum) {_ in
                utilities.preferences.capture.maximumZoom = zoomMaximum
            }
        }
        
        func onAppear() {
            shouldStabilize = utilities.preferences.preview.stablize
            shouldUseFastPath = utilities.preferences.preview.fastPath
            zoomMaximum = utilities.preferences.capture.maximumZoom
            previewAspect = utilities.preferences.preview.aspect ? 1 : 0
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
            
            utilities.preferences.preview.aspect = (previewAspect == 1)
            utilities.preferences.preview.stablize = shouldStabilize
            utilities.preferences.preview.fastPath = shouldUseFastPath
            utilities.preferences.capture.maximumZoom = zoomMaximum
        }
    }
}
