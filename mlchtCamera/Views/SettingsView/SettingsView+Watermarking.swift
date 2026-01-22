//
//  SettingsView+Watermarking.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct Watermarking: View {
        /// A State variable used for determining whether or not watermarking is enabled.
        @State private var watermarkSwitch = false
        /// A State variable used for determining the current watermark string.
        @State private var watermarkText = String()
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
            Section(header: Text("settings.header.watermark")) {
                MalachiteCellViewUtils(
                    icon: "textformat",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("settings.option.watermark.enable", isOn: $watermarkSwitch)
                }
                
                MalachiteCellViewUtils(
                    icon: "signature",
                    disabled: nil,
                    dangerous: false)
                {
                    Text("settings.option.watermark.text")
                    TextField("settings.option.watermark.text.placeholder", text: $watermarkText)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .keyboardType(.twitter)
                }
            }
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
            .onChange(of: watermarkSwitch) {_ in
                utilities.preferences.watermark.enabled = watermarkSwitch
            }
            .onChange(of: watermarkText) {_ in
                utilities.preferences.watermark.text = watermarkText.isEmpty ? "Shot with Malachite" : String(watermarkText.prefix(65))
            }
        }
        
        func onAppear() {
            watermarkText = utilities.preferences.watermark.text
            watermarkSwitch = utilities.preferences.watermark.enabled
        }
        
        func onDisappear() {
            utilities.preferences.watermark.enabled = watermarkSwitch
            utilities.preferences.watermark.text = watermarkText.isEmpty ? "Shot with Malachite" : String(watermarkText.prefix(65))
        }
    }
}
