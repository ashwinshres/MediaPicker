//
//  MediaPickerProtocol.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit

protocol MediaPickerDelegate: class {
    func didPickImage(_ image: UIImage)
    func didClose(viewController: MediaPickerViewController)
    func didPickVideo(_ withPath : URL)
    func showErrorMessage(_ message: String)
}
