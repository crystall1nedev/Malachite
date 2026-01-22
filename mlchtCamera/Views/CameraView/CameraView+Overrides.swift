//
//  CameraView+Overrides.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/30/25.
//

import UIKit

extension CameraView {
    /// Override function to force the status bar to never be shown.
    override var prefersStatusBarHidden: Bool { return true }
    
    /// Override function to force the app to be in portrait mode on iPhone.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if utilities.idiom == .phone { return .portrait }
        return .all
    }
    
    /// Override function to force the system to reject gestures from the bottom of the screen.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return utilities.preferences.evaintrnl.blockAccidentalGestures ? [.bottom] : []
    }
    
    /// Override function for layoutSubviews.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.view.frame = self.view.bounds
    }
    
    /// Override function to trigger actions when the screen rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [self] context in
            #if MAIN_APP
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                let orientation = windowScene.interfaceOrientation
                self.preview.previewLayer.connection!.videoOrientation = self.transformOrientation(orientation: orientation)
            }
            #endif
            self.preview.previewLayer.frame.size = self.view.frame.size
        })
    }
}
