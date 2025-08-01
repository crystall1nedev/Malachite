//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 2/18/24.
//

import SwiftUI
import GameKit

private struct AppIcon {
    let id = UUID()
    let name: String
    let description: String
    let image: String
    let symbol: Bool
    let icon: String?
    let achievement: String?
}

struct MalachiteAboutView: View {
    /// A State variable used for determining whether or not this view is being presented as a modal.
    var dismissAction: (() -> Void)
    /// A State variable used for determining whether or not to enable Game Center integration.
    @State private var gamekitSwitch = false
    /// A State variable used for determining whether or not to uncap the exposure slider.
    @State private var exposureUnlimiterSwitch = false
    
    /// A variable used to determine the currently available app icons.
    private let appIcons = [
        AppIcon(name: "crystall1nedev", description: "about.credits.crystall1nedev", image: "crystall1nedev", symbol: false, icon: nil, achievement: "icon.default"),
        AppIcon(name: "ThatStella7922", description: "about.credits.thatstella7922", image: "thatstella7922", symbol: false, icon: "thatsniceguy", achievement: "icon.wifey"),
        AppIcon(name: "ASentientBot", description: "about.credits.asentientbot", image: "asentientbot", symbol: false, icon: "asb_approved", achievement: "icon.marimo"),
        AppIcon(name: "The Sanctuary Discord", description: "about.credits.discord", image: "", symbol: true, icon: nil, achievement: nil),
        AppIcon(name: "Apple", description: "about.credits.apple", image: "applelogo", symbol: true, icon: nil, achievement: nil)
    ]
    
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    /// A variable used to hold the function for dismissing with the toolbar item.
    ///var dismissAction: (() -> Void)
    
    /**
     A variable used to hold the entire view.
     
     SwiftUI is weird...
     Currently holds:
     - Other variables to avoid type counting time issues.
     - Handles initialization of variables required to show current settings.
     - Navigation title of "About Malachite"
     - Toolbar item for dismissing the view
     */
    var body: some View {
        MalachiteNagivationViewUtils() { guts }
    }
    
    var guts: some View {
        Form {
            aboutSection
            storySection
            creditsSection
            funniesSection
            
        }
        .onAppear() {
            gamekitSwitch = utilities.preferences.general.gamekit.enabled
            exposureUnlimiterSwitch = utilities.preferences.capture.unlimitedISO
        }
        .onDisappear() {
            utilities.preferences.general.gamekit.enabled = gamekitSwitch
            utilities.preferences.capture.unlimitedISO = exposureUnlimiterSwitch
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
        .navigationTitle("view.title.about")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    Button {
                        self.dismissAction()
                    } label: {
                        Image(systemName: "checkmark")
                            .tint(.primary)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        self.dismissAction()
                    } label: {
                        Image(systemName: "checkmark")
                            .tint(.primary)
                    }
                }
            }
        })
    }
    
    /// A variable for the about section.
    var aboutSection: some View {
        Section(footer: aboutSectionFooter){
            HStack {
                VStack {
                    HStack {
                        Text("appname")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Text("\(utilities.versionMajor).\(utilities.versionMinor).\(utilities.versionMinor)")
                            .font(.footnote)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                }
                Spacer()
                Button {
                    if utilities.versionType == "INTERNAL" {
                        utilities.preferences.ext.showGameKitOptionInAbout(in: &utilities.preferences)
                    }
                } label: {
                    if #available(iOS 26.0, *) {
                        Image("icon26")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80, alignment: .trailing)
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                    } else {
                        Image("icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80, alignment: .trailing)
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                    }
                }
            }
            Text("about.description")
            Text("about.author_note")
                .bold()
        }
    }
    
    var aboutSectionFooter: some View {
        VStack {
            if utilities.versionType == "DEBUG" || utilities.versionType == "INTERNAL" {
                HStack {
                    Text("\(utilities.versionType) - \(utilities.versionHash) - \(utilities.versionDate)")
                        .font(.footnote)
                        .frame(alignment: .leading)
                    Spacer()
                }
            }
            if utilities.versionType == "INTERNAL" {
                HStack {
                    Text("Built by \(utilities.versionUser) on \(utilities.versionHost)")
                        .font(.footnote)
                        .frame(alignment: .leading)
                    Spacer()
                }
            }
        }
    }
    
    /// A variable for the story section.
    var storySection: some View {
        Section(header: Text("about.header.story")) {
            Text("about.story")
        }
    }
    
    /// A variable for the credits section.
    var creditsSection : some View {
        Section(header: Text("about.header.credits")) {
            ForEach(appIcons, id: \.id) {appIcon in
                HStack {
                    VStack {
                        HStack {
                            Text(appIcon.name)
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(LocalizedStringKey(appIcon.description))
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        utilities.debugNSLog("[App Icon] Changing to \(appIcon.icon ?? "default")")
                        #if MAIN_APP
                        UIApplication.shared.setAlternateIconName(appIcon.icon) { (error) in
                            if let error = error {
                                print("Failed request to update the app’s icon: \(error)")
                            }
                        }
                        #endif
                        if utilities.games.gameCenterEnabled && appIcon.achievement != nil {
                            DispatchQueue.global(qos: .background).async { [self] in
                                let iconAchievement = utilities.games.achievements.pullAchievement(achievementName: appIcon.achievement!)
                                iconAchievement.percentComplete = 100
                                utilities.games.achievements.pushAchievement(achievementBody: iconAchievement)
                            }
                        }
                    } label: {
                        Text("")
                    }
                    if !appIcon.symbol {
                        Image(appIcon.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 40, alignment: .trailing)
                            .clipShape(Circle())
                    } else {
                        if #available(iOS 16.0, *) {
                            Image(systemName: appIcon.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 30, alignment: .trailing)
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: appIcon.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 30, alignment: .trailing)
                                .padding(.trailing, 5)
                        }
                    }
                }
            }
        }
    }
    
    /// A variable for the funnies section.
    var funniesSection : some View {
        Section(header: Text("about.header.special")) {
            MalachiteCellViewUtils(
                icon: "sun.max",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.photo.max_exposure", isOn: $exposureUnlimiterSwitch)
            }
            if utilities.preferences.general.gamekit.found {
                MalachiteCellViewUtils(
                    icon: "gamecontroller",
                    disabled: nil,
                    dangerous: true)
                {
                    Toggle("", isOn: $gamekitSwitch)
                }
            }
        }
        .onChange(of: gamekitSwitch) {_ in
            utilities.preferences.general.gamekit.enabled = gamekitSwitch
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
        .onChange(of: exposureUnlimiterSwitch) { _ in
            utilities.debugNSLog("[Settings View] Lol")
            utilities.preferences.capture.unlimitedISO = exposureUnlimiterSwitch
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        }
    }
}
