//
//  DeveloperView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI

struct DeveloperView: View {
    /// A State variable used for determining whether or not this view is being presented as a modal.
    var dismissAction: (() -> Void)
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    
    var body: some View {
        Form {
            Settings(utilities: utilities)
            BuildInfo(utilities: utilities)
            DeviceInfo(utilities: utilities)
        }
        .navigationTitle("view.title.developer")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    Button {
                        self.dismissAction()
                    } label: {
                        Image(systemName: "checkmark")
                            .tint(.primary)
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    Button {
                        self.dismissAction()
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
        })
    }
}
