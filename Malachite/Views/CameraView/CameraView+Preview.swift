//
//  CameraView+Preview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/26/25.
//

import AVFoundation
import Foundation

extension CameraView {
    class Preview {
        /// The existing instance of ``CameraView`` to act on.
        var delegate = CameraView()
        
        init(delegate: CameraView) { self.delegate = delegate }
        
        func createPreviewLayer(previewLayer: AVCaptureVideoPreviewLayer?) -> AVCaptureVideoPreviewLayer {
            guard let previewLayer = previewLayer else {
                let layer = AVCaptureVideoPreviewLayer()
                layer.frame.size = delegate.view.frame.size
                return layer
            }
            
            previewLayer.frame.size = delegate.view.frame.size
            return previewLayer
        }
    }
}
