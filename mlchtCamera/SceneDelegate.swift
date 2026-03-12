//
//  SceneDelegate.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/25/23.
//

import UIKit
import WatchConnectivity

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let utilities = MalachiteClassesObject()
    
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let initialization = Init(utilities: utilities)
        let rootVC = CameraView()
        
        initialization.initMalachite()
        rootVC.utilities = utilities
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene)  {
        utilities.watch.notifyOfForegroundChange()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        utilities.watch.notifyOfForegroundChange()
    }
}
