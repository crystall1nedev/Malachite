//
//  SettingsView+Help.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 3/14/24.
//

import SwiftUI

extension SettingsView {
    struct Help: View {
        
        /// A variable used to hold the function for dismissing with the toolbar item.
        var dismissAction: (() -> Void)
        
        /// A variable used to hold the entire view.
        var body: some View {
            
            Form {
                aboutSection
                previewSettingsSection
                resolutionSettingsSection
                photoSettingsSection
                watermarkSettingsSection
                uiSettingsSection
                debugSettingsSection
            }
            .navigationTitle("view.title.help")
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
        
        /// A variable to hold the about section.
        var aboutSection: some View {
            Section {
                Builder(title: Text("view.title.about"), subtitle: Text("view.detail.about")) {}
            }
        }
        
        /// A variable to hold the preview settings section.
        var previewSettingsSection: some View {
            Section(header: Text("settings.header.preview"), footer: Text("settings.footer.preview")) {
                Builder(title: Text("settings.option.preview.aspect_ratio"), subtitle: Text("settings.detail.preview.aspect_ratio")) {}
                Builder(title: Text("settings.option.preview.sbtlz"), subtitle: Text("settings.detail.preview.sbtlz")) {}
                Builder(title: Text("settings.option.preview.zoom_maximum"), subtitle: Text("settings.detail.preview.zoom_maximum")) {}
            }
        }
        
        /// A variable to hold the image resolution section.
        var resolutionSettingsSection: some View {
            Section(header: Text("settings.header.resolution"), footer: Text("settings.footer.resolution")) {
                Builder(title: Text("settings.option.resolution.ultrawide"), subtitle: Text("settings.detail.resolution.ultrawide")) {}
                Builder(title: Text("settings.option.resolution.wide"), subtitle: Text("settings.detail.resolution.wide")) {}
                Builder(title: Text("settings.option.resolution.telephoto"), subtitle: Text("settings.detail.resolution.telephoto")) {}
            }
        }
        
        /// A variable to hold the photo settings section.
        var photoSettingsSection: some View {
            Section(header: Text("settings.header.photo"), footer: Text("settings.footer.photo")) {
                Builder(title: Text("settings.option.photo.fileformat"), subtitle: Text("settings.detail.photo.fileformat")) {}
                Builder(title: Text("settings.option.photo.hdr"), subtitle: Text("settings.detail.photo.hdr")) {}
                Builder(title: Text("settings.option.photo.continuous"), subtitle: Text("settings.detail.photo.continuous")) {}
            }
        }
        
        var uiSettingsSection: some View {
            Section(header: Text("settings.header.ui"), footer: Text("settings.footer.ui")) {
                Builder(title: Text("settings.option.ui.tapgesture"), subtitle: Text("settings.detail.ui.tapgesture")) {}
                Builder(title: Text("settings.option.ui.hiddengestures"), subtitle: Text("settings.detail.ui.hiddengestures")) {}
                Builder(title: Text("settings.option.ui.idletimer"), subtitle: Text("settings.detail.ui.idletimer")) {}
                Builder(title: Text("settings.option.ui.haptics"), subtitle: Text("settings.detail.ui.haptics")) {}
                Builder(title: Text("settings.option.ui.hiddenonlaunch"), subtitle: Text("settings.detail.ui.hiddenonlaunch")) {}
            }
        }
        
        /// A variable to hold the watermark settings section.
        var watermarkSettingsSection: some View {
            Section(header: Text("settings.header.watermark"), footer: Text("settings.footer.watermark")) {
                Builder(title: Text("settings.option.watermark.enable"), subtitle: Text("settings.detail.watermark.enable")) {}
                Builder(title: Text("settings.option.watermark.text"), subtitle: Text("settings.detail.watermark.text")) {}
            }
        }
        
        /// A variable to hold the debug settings section. Only available with debug builds.
        var debugSettingsSection: some View {
            Section(header: Text("developer.header.debug"), footer: Text("developer.footer.debug")) {
                Builder(title: Text("developer.option.debug.logging.userdefaults"), subtitle: Text("developer.detail.debug.logging.userdefaults")) {}
                Builder(title: Text("developer.option.debug.erase.userdefaults"), subtitle: Text("developer.detail.debug.erase.userdefaults")) {}
                Builder(title: Text("developer.option.debug.erase.gamekit"), subtitle: Text("developer.detail.debug.erase.gamekit")) {}
            }
        }
        
        struct Builder<Content : View>: View {
            var title: Text
            var subtitle: Text
            let content: Content?
            
            init(
                title: Text,
                subtitle: Text,
                @ViewBuilder content: () -> Content?
            ) {
                self.title = title
                self.subtitle = subtitle
                self.content = content() ?? nil
            }
            
            var body: some View {
                VStack {
                    HStack {
                        title
                            .bold()
                        Spacer()
                        
                    }
                    HStack {
                        subtitle
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
        }
    }
}
