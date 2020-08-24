//
//  ImageSaver.swift
//  UIKitIntegration
//
//  Created by Vegesna, Vijay V EX1 on 8/23/20.
//  Copyright © 2020 Vegesna, Vijay V. All rights reserved.
//

import UIKit

class ImageSaver: NSObject {
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotosAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(reportError), nil)
    }
    
    @objc func reportError(_ image: UIImage, didFinishSvaingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
