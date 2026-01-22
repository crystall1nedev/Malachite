//
//  QuickHelpView+Watermarking.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct Watermarking: View {
        /// A variable to hold the watermark settings section.
        var body: some View {
            Section(header: Text("settings.header.watermark"), footer: Text("settings.footer.watermark")) {
                createQuickHelpRow(title: Text("settings.option.watermark.enable"), subtitle: Text("settings.detail.watermark.enable")) 
                createQuickHelpRow(title: Text("settings.option.watermark.text"), subtitle: Text("settings.detail.watermark.text"))
            }
        }
    }
}
