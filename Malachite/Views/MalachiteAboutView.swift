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
    let icon: String?
    let achievement: String
}

struct MalachiteAboutView: View {
    /// A State variable used for determining whether or not to enable Game Center integration.
    @State private var gamekitSwitch = false
    
    /// A variable used to determine the currently available app icons.
    private let appIcons = [
        AppIcon(name: "crystall1nedev", description: "Clueless lead developer", image: "crystall1nedev", icon: nil, achievement: "icon.default"),
        AppIcon(name: "ThatStella7922", description: "The reason I do any of this ❤️", image: "thatstella7922", icon: "thatsinceguy", achievement: "icon.wifey"),
        AppIcon(name: "ASentientBot", description: "Great tester, greater friend", image: "asentientbot", icon: "asb_approved", achievement: "icon.marimo")
    ]
    
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    /// A variable used to hold the function for dismissing with the toolbar item.
    var dismissAction: (() -> Void)
    
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
        Form {
            aboutSection
            storySection
            creditsSection
            gamekitSection
            
        }
        .onAppear() {
            gamekitSwitch = utilities.settings.defaults.bool(forKey: "internal.gamekit.enabled")
        }
        .onDisappear() {
            utilities.settings.defaults.set(gamekitSwitch, forKey: "internal.gamekit.enabled")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
        .navigationTitle("About Malachite")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.dismissAction()
                } label: {
                    Text("Done")
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
                        Text("Malachite")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        if utilities.versionBeta {
                            Text("v\(utilities.versionMajor).\(utilities.versionMinor).\(utilities.versionMinor) beta")
                                .font(.footnote)
                                .frame(alignment: .leading)
                        } else {
                            Text("v\(utilities.versionMajor).\(utilities.versionMinor).\(utilities.versionMinor)")
                                .font(.footnote)
                                .frame(alignment: .leading)
                        }
                        Spacer()
                    }
                }
                Spacer()
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 80, alignment: .trailing)
                    .clipShape(RoundedRectangle(cornerRadius: 17))
            }
            Text("Bringing camera control back to you.")
            Text("Designed by Eva with ❤️ in 2024")
                .bold()
        }
    }
    
    /// A variable for the story section.
    var storySection: some View {
        Section(header: Text("Story Time")) {
            Text("Malachite started as an app to help my love work on printed circuit boards with better clarity and manual controls that the stock iOS camera app can't provide, and it grew once my Discord community stood by, actually using it and suggesting new features. It's the first real test of my skills in Swift, and leading my own public project, and my goal is to now provide a free, all-inclusive experience to amazing macro photography - powered by your iPhone, iPad, or iPod touch.")
        }
    }
    
    /// A variable for the credits section.
    var creditsSection : some View {
        Section(header: Text("Credits")) {
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
                            Text(appIcon.description)
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        NSLog("[App Icon] Changing to \(appIcon.icon ?? "default")")
                        UIApplication.shared.setAlternateIconName(appIcon.icon) { (error) in
                            if let error = error {
                                print("Failed request to update the app’s icon: \(error)")
                            }
                        }
                        if utilities.games.gameCenterEnabled {
                            DispatchQueue.global(qos: .background).async { [self] in
                                let iconAchievement = utilities.games.achievements.pullAchievement(achievementName: appIcon.achievement)
                                iconAchievement.percentComplete = 100
                                utilities.games.achievements.pushAchievement(achievementBody: iconAchievement)
                            }
                        }
                    } label: {
                        Text("")
                    }
                    Image(appIcon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40, alignment: .trailing)
                        .clipShape(Circle())
                }
            }
            HStack {
                VStack {
                    HStack {
                        Text("Apple")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Text("For bankrupting me 😭")
                        Spacer()
                    }
                }
                Spacer()
                if #available(iOS 16.0, *) {
                    Image(systemName: "apple.logo" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30, alignment: .trailing)
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "applelogo" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30, alignment: .trailing)
                        .padding(.trailing, 5)
                }
            }
        }
    }
    
    /// A variable for the GameKit section.
    var gamekitSection : some View {
        Section(header: Text("A special treat...")) {
            Toggle("Enable Game Center", isOn: $gamekitSwitch)
        }
        .onChange(of: gamekitSwitch) {_ in
            utilities.settings.defaults.set(gamekitSwitch, forKey: "internal.gamekit.enabled")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
        }
    }
}
