//
//  DeveloperView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI
import UIKit

struct DeveloperView: View {
    /// A State variable used for determining whether or not this view is being presented as a modal.
    var dismissAction: (() -> Void)
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    
    var body: some View {
        Form {
            Settings(utilities: utilities)
            if utilities.versionType == "INTERNAL" { InternalSettings(utilities: utilities)}
            BuildInfo(utilities: utilities)
            DeviceInfo(utilities: utilities)
        }
        .navigationTitle("view.title.developer")
        .toolbar(content: {
            #warning("log export implementation eta")
            ToolbarItemGroup(placement: .topBarLeading) {
                if #available(iOS 26.0, *) { help }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if #unavailable(iOS 26.0) { help; }
                MalachiteToolbarUtils(action: self.dismissAction, image: "checkmark", primary: true)
            }
        })
    }
    
    var help: some View {
        NavigationLink(destination: QuickHelpViewDeveloper(utilities: utilities, dismissAction: dismissAction)) {
            if #available(iOS 26.0, *) {
                Image(systemName: "questionmark.circle")
            } else {
                Image(systemName: "questionmark.circle").tint(.primary)
            }
        }
    }
    
    struct createBuildInformation: View {
        var label: LocalizedStringKey
        var value: String
        var body: some View {
            HStack {
                Text(label)
                    .frame(alignment: .leading)
                Spacer()
                Text(value)
                    .frame(alignment: .trailing)
            }
        }
    }
}
