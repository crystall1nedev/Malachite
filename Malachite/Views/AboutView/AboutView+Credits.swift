//
//  AboutView+Credits.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension AboutView {
    struct Credits: View {
        private struct AppIcon {
            let id = UUID()
            let name: String
            let description: String
            let image: String
            let symbol: Bool
            let icon: String?
            let achievement: String?
        }
        /// A variable used to determine the currently available app icons.
        private var appIcons = [
            AppIcon(name: "crystall1nedev", description: "about.credits.crystall1nedev", image: "crystall1nedev", symbol: false, icon: nil, achievement: "icon.default"),
            AppIcon(name: "ThatStella7922", description: "about.credits.thatstella7922", image: "thatstella7922", symbol: false, icon: "thatsniceguy", achievement: "icon.wifey"),
            AppIcon(name: "ASentientBot", description: "about.credits.asentientbot", image: "asentientbot", symbol: false, icon: "asb_approved", achievement: "icon.marimo"),
            AppIcon(name: "The Sanctuary Discord", description: "about.credits.discord", image: "", symbol: true, icon: nil, achievement: nil),
            AppIcon(name: "Apple", description: "about.credits.apple", image: "applelogo", symbol: true, icon: nil, achievement: nil)
        ]
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
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
}
