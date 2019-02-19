//
//  MediaPickerProtocol.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit

protocol MediaPickerDelegate: class {
    
    /// Delegate method for image picked
    ///
    /// - Parameter image: selected image (from camera or library)
    func didPickImage(_ image: UIImage)
    
    /// Delegate method for media picker view controller to be closed
    ///
    /// - Parameter viewController: media picker view controller instance
    func didClose(viewController: MediaPickerViewController)
    
    /// Url path for the video picked/recorded
    ///
    /// - Parameter withPath: URL
    func didPickVideo(_ withPath : URL)
    
    /// Error Message
    ///
    /// - Parameter message: String errror message
    func showErrorMessage(_ message: String)
}
