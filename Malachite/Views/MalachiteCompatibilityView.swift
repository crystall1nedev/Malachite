//
//  MalachiteCompatibilityView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 10/21/24.
//

import SwiftUI

public struct MalachiteCompatibilityView: View {
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    /// A variable used to hold the function for dismissing with the toolbar item.
    var dismissAction: (() -> Void)
    
    public var body: some View {
        Form {
            Section {
                // Ultra wide megapixel capabilities
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.8mp.ultrawide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "8"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.12mp.ultrawide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "12"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.48mp.ultrawide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "48"))
                // Wide angle megapixel capabilities
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.8mp.wide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "8"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.12mp.wide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "12"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.48mp.wide"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "48"))
                // Telephoto megapixel capabilities
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.12mp.telephoto"), available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.telephoto", key: "12"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.jpeg"), available: utilities.settings.defaults.bool(forKey: "compatibility.jpeg"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.heif"), available: utilities.settings.defaults.bool(forKey: "compatibility.heif"))
                MalachiteCompatibilityViewUtils(title: Text("compatibility.title.hdr"), available: utilities.settings.defaults.bool(forKey: "compatibility.hdr"))
            }
        }
        .navigationTitle("view.title.compatibility")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    self.dismissAction()
                } label: {
                    Text("action.done_button")
                }
            }
        })
    }
}
