//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 2/18/24.
//

import SwiftUI

private struct AppIcon {
    let id = UUID()
    let name: String
    let description: String
    let image: String
    let icon: String?
}

struct MalachiteAboutView: View {
    private let appIcons = [
            AppIcon(name: "crystall1nedev", description: "Clueless lead developer", image: "crystall1nedev", icon: nil),
            AppIcon(name: "ThatStella7922", description: "The reason I do any of this ❤️", image: "thatstella7922", icon: "thatsinceguy"),
            AppIcon(name: "ASentientBot", description: "Great tester, greater friend", image: "asentientbot", icon: "asb_approved")
        ]
    
    var body: some View {
        Form {
            storySection
            creditsSection
            
        }
        .navigationTitle("About Malachite")
    }
    
    var storySection: some View {
        Section() {
            Text("Story time.")
                .font(.largeTitle)
                .bold()
            Text("Malachite started as an app to help my love work on printed circuit boards with better clarity and manual controls that the stock iOS camera app can't provide, and it grew once my Discord community stood by, actually using it and suggesting new features. It's the first real test of my skills in Swift, and leading my own public project, and my goal is to now provide a free, all-inclusive experience to amazing macro photography - powered by your iPhone, iPad, or iPod touch.")
        }
    }
    
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
}

#Preview {
    MalachiteAboutView()
}
