//
//  CameraView+Preview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/26/25.
//

import AVFoundation
import Foundation
import UIKit

extension CameraView {
    class Preview {
        /// The existing instance of ``CameraView`` to act on.
        var delegate = CameraView()
        /// The `AVCaptureVideoPreviewLayer` used to allow users to see a preview of their camera before taking a shot with ``photoOutput``.
        var previewLayer = AVCaptureVideoPreviewLayer()
        
        init(delegate: CameraView) { self.delegate = delegate }
        
        func createPreviewLayer() {
            previewLayer = AVCaptureVideoPreviewLayer(session: delegate.camera.session)
            previewLayer.frame.size = delegate.view.frame.size
        }
        
        func configurePreviewLayer() {
            var statusBarOrientation = UIInterfaceOrientation.portrait
            #if MAIN_APP
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
                statusBarOrientation = windowScene.interfaceOrientation
            }
            #endif
            previewLayer.frame = delegate.view.layer.bounds
            let videoOrientation: AVCaptureVideoOrientation = (statusBarOrientation.videoOrientation)
            if let connection = previewLayer.connection { connection.videoOrientation = videoOrientation }
            
            if delegate.utilities.preferences.preview.aspect {
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            } else {
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
        
        func addPreviewLayer() {
            delegate.view.layer.addSublayer(previewLayer)
        }
        
        func initPreviewLayer() {
            createPreviewLayer()
            configurePreviewLayer()
            addPreviewLayer()
        }
    }
}
