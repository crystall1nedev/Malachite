//
//  QuickHelpView+Resolution.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct Resolution: View {
        /// A variable to hold the image resolution section.
        var body: some View {
            Section(header: Text("settings.header.resolution"), footer: Text("settings.footer.resolution")) {
                Builder(title: Text("settings.option.resolution.ultrawide"), subtitle: Text("settings.detail.resolution.ultrawide")) {}
                Builder(title: Text("settings.option.resolution.wide"), subtitle: Text("settings.detail.resolution.wide")) {}
                Builder(title: Text("settings.option.resolution.telephoto"), subtitle: Text("settings.detail.resolution.telephoto")) {}
            }
        }
    }
}
