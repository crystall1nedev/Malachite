//
//  CompatibilityView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 10/21/24.
//

import SwiftUI

public struct CompatibilityView: View {
    /// A State variable used for determining whether or not this view is being presented as a modal.
    var dismissAction: (() -> Void)
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    
    public var body: some View {
        Form {
            Section {
                Text("compatibility.note")
            }
            Cameras(utilities: utilities)
            Resolutions(utilities: utilities)
            Formats(utilities: utilities)
            Misc(utilities: utilities)
        }
        .navigationTitle("view.title.compatibility")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                MalachiteToolbarUtils(action: self.dismissAction, image: "checkmark", primary: true)
            }
        })
    }
    
    @available(*, deprecated, message: "Avoid using the Misc structure. When possible, build into a more descriptive structure.")
    struct Misc: View {
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section {
                MalachiteCompatibilityViewUtils(title: "compatibility.title.hdr", available: utilities.preferences.compatibility.hdr)
            }
        }
    }
}
