//
//  MalachiteSettingsDetailView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 3/14/24.
//

import SwiftUI

struct MalachiteSettingsDetailView: View {
    
    /// A variable used to hold the function for dismissing with the toolbar item.
    var dismissAction: (() -> Void)
    
    /// A variable used to hold the entire view.
    var body: some View {
        
        Form {
            aboutSection
            previewSettingsSection
            photoSettingsSection
            watermarkSettingsSection
            debugSettingsSection
        }
        .navigationTitle("view.title.help")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.dismissAction()
                } label: {
                    Text("action.done_button")
                }
            }
        })
    }
    
    /// A variable to hold the about section.
    var aboutSection: some View {
        Section {
            HStack {
                Text("About Malachite")
                    .bold()
            }
        }
    }
    
    /// A variable to hold the preview settings section.
    var previewSettingsSection: some View {
        Section(header: Text("Preview settings"), footer: Text("Use Fit if you wish to see your entire viewport. Use Fill if you want a more immersive and honed-in experience.")) {
            Text("Aspect ratio")
            Text("Enable preview stabilization")
        }
    }
    
    /// A variable to hold the photo settings section.
    var photoSettingsSection: some View {
        Section(header: Text("Photo settings"), footer: Text("format.footer")) {
            Text("Image file format")
            Text("Enable HDR")
            Text("Enable maximum exposure")
        }
    }
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("Watermark settings"), footer: Text("A fun little feature, you can enable a watermark on your images when you take them.")) {
            Text("Enable watermark")
            Text("Watermark text")
        }
    }
    
    /// A variable to hold the debug settings section. Only available with debug builds.
    var debugSettingsSection: some View {
        Section(header: Text("Debug settings"), footer: Text("Only available in debug builds, these settings are used to debug various parts of Malachite.")) {
            Text("Reset all settings")
            Text("Reset Game Center achievements")
        }
    }
}

struct MalachiteSettingsDetailUtils<Content : View>: View {
    var icon: String
    var title: String
    var subtitle: String
    var dangerous: Bool
    
    init(
        icon: String,
        title: String,
        subtitle: String?,
        dangerous: Bool
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle ?? ""
        self.dangerous = dangerous
    }
    
    var body: some View {
        HStack() {
            if dangerous {
                if #available(iOS 15.0, *) {
                    Image(systemName: icon)
                        .frame(maxWidth: 30)
                        .foregroundStyle(.red)
                        .symbolRenderingMode(.hierarchical)
                } else {
                    Image(systemName: icon)
                        .frame(maxWidth: 30)
                        .foregroundColor(.red)
                }
            } else {
                if #available(iOS 15.0, *) {
                    Image(systemName: icon)
                        .frame(maxWidth: 30)
                        .foregroundStyle(Color.accentColor)
                        .symbolRenderingMode(.hierarchical)
                } else {
                    Image(systemName: icon)
                        .frame(maxWidth: 30)
                        .foregroundColor(Color.accentColor)
                }
            }
            VStack {
                HStack {
                    if dangerous {
                        if #available(iOS 17.0, *) {
                            Text(LocalizedStringKey(title))
                                .foregroundStyle(.red)
                        } else {
                            Text(LocalizedStringKey(title))
                                .foregroundColor(.red)
                        }
                    } else {
                        Text(LocalizedStringKey(title))
                    }
                    Spacer()
                }
                if subtitle != "" {
                    HStack {
                        if dangerous {
                            if #available(iOS 17.0, *) {
                                Text(LocalizedStringKey(subtitle))
                                    .foregroundStyle(.red)
                                    .font(.footnote)
                            } else {
                                Text(LocalizedStringKey(subtitle))
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        } else {
                            Text(LocalizedStringKey(subtitle))
                                .font(.footnote)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
