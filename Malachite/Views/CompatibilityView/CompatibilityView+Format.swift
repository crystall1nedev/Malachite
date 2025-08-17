//
//  CompatibilityView+Format.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/17/25.
//

import SwiftUI

extension CompatibilityView {
    struct Formats: View {
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("compatibility.header.format")) {
                MalachiteCompatibilityViewUtils(title: "compatibility.title.jpeg", available: utilities.preferences.compatibility.jpeg)
                MalachiteCompatibilityViewUtils(title: "compatibility.title.heif", available: utilities.preferences.compatibility.heic)
            }
        }
    }
}
