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
    @Binding var presentedAsModal: Bool
    /// A State variable used for determining whether or not to enable Game Center integration.
    @State private var gamekitSwitch = false
    
    /// A variable used to determine the currently available app icons.
    private let appIcons = [
        AppIcon(name: "crystall1nedev", description: "about.credits.crystall1nedev", image: "crystall1nedev", symbol: false, icon: nil, achievement: "icon.default"),
        AppIcon(name: "ThatStella7922", description: "about.credits.thatstella7922", image: "thatstella7922", symbol: false, icon: "thatsinceguy", achievement: "icon.wifey"),
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
            if utilities.settings.defaults.bool(forKey: "internal.gamekit.found") {
                gamekitSection
            }
            
        }
        .onAppear() {
            gamekitSwitch = utilities.settings.defaults.bool(forKey: "internal.gamekit.enabled")
        }
        .onDisappear() {
            utilities.settings.defaults.set(gamekitSwitch, forKey: "internal.gamekit.enabled")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
        .navigationTitle("view.title.about")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.presentedAsModal = false
                } label: {
                    Text("action.done_button")
                }
            }
        })
    }
    
    /// A variable for the about section.
    var aboutSection: some View {
        Section {
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
                    if utilities.versionType == "debug" || utilities.versionType == "internal" {
                        HStack {
                            Text("\(utilities.versionType) - \(utilities.versionHash) - \(utilities.versionDate)")
                                .font(.footnote)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                    }
                }
                Spacer()
                Button {
                    utilities.settings.showGameKitOptionInAbout()
                } label: {
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 80, alignment: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                }
            }
            Text("about.description")
            Text("about.author_note")
                .bold()
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
                    if appIcon.icon != nil {
                        Button {
                            NSLog("[App Icon] Changing to \(appIcon.icon ?? "default")")
                            UIApplication.shared.setAlternateIconName(appIcon.icon) { (error) in
                                if let error = error {
                                    print("Failed request to update the app’s icon: \(error)")
                                }
                            }
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
    
    /// A variable for the GameKit section.
    var gamekitSection : some View {
        Section(header: Text("about.header.special")) {
            MalachiteCellViewUtils(
                icon: "gamecontroller",
                title: "about.option.gamekit",
                subtitle: "about.detail.gamekit",
                disabled: nil,
                dangerous: true)
            {
                Toggle("", isOn: $gamekitSwitch)
            }
        }
        .onChange(of: gamekitSwitch) {_ in
            utilities.settings.defaults.set(gamekitSwitch, forKey: "internal.gamekit.enabled")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
    }
}
