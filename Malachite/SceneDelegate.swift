//
//  SceneDelegate.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/25/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootVC = MalachiteView()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        MalachiteSettingsUtils().ensurePreferences()
    }
}
