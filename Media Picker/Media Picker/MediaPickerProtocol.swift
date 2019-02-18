//
//  MediaPickerProtocol.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation

protocol MediaPickerDelegate: class {
    func didClose(viewController: MediaPickerViewController)
}
