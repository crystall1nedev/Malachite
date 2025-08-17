//
//  QuickHelpView+Resolution.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct Resolution: View {
        var utilities = MalachiteClassesObject()
        
        init(utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        /// A variable to hold the image resolution section.
        var body: some View {
            Section(header: Text("settings.header.resolution"), footer: Text("settings.footer.resolution")) {
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) {
                    createQuickHelpRow(title: Text("settings.option.resolution.ultrawide"), subtitle: Text("settings.detail.resolution.ultrawide"))
                }
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) {
                    createQuickHelpRow(title: Text("settings.option.resolution.wide"), subtitle: Text("settings.detail.resolution.wide"))
                }
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) {
                    createQuickHelpRow(title: Text("settings.option.resolution.telephoto"), subtitle: Text("settings.detail.resolution.telephoto"))
                }
            }
        }
    }
}
