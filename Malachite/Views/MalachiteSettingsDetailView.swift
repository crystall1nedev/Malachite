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
                Text("view.title.about")
                    .bold()
            }
        }
    }
    
    /// A variable to hold the preview settings section.
    var previewSettingsSection: some View {
        Section(header: Text("settings.header.preview"), footer: Text("settings.footer.preview")) {
            Text("settings.option.preview.aspect_ratio")
            Text("settings.option.preview.sbtlz")
        }
    }
    
    /// A variable to hold the photo settings section.
    var photoSettingsSection: some View {
        Section(header: Text("settings.header.photo")) {
            Text("settings.option.photo.file_format")
            Text("settings.option.photo.hdr")
            Text("settings.option.photo.max_exposure")
        }
    }
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("settings.header.watermark")) {
            Text("settings.option.watermark.enable")
            Text("settings.option.watermark.text")
        }
    }
    
    /// A variable to hold the debug settings section. Only available with debug builds.
    var debugSettingsSection: some View {
        Section(header: Text("settings.header.debug")) {
            Text("settings.option.debug.erase_userdefaults")
            Text("settings.option.debug.erase_gamekit")
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
