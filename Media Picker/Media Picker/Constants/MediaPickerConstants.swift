//
//  MediaPickerConstants.swift
//  Media Picker
//
//  Created by Insight Workshop on 2/18/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import Foundation

typealias MPConstants = MediaPickerConstants

struct MediaPickerConstants {
    
    struct strings {
        static let controllerName = "MediaPickerViewController"
        static let errorPickingMedia = "Error picking up media"
        static let mediaCropTitle = "Are you sure, you do not want to crop the image?"
        static let cropBtnTitle = "Crop"
        static let noAccessTypeAvailable = "No access type available to select from"
        static let cameraPermissionError = "App needs camera permission to capture media"
        static let noCameraAvailable = "No camera available."
        static let noLibraryAvailable = "No  library available."
    }
    
    struct usageDescription {
        static let cameraUsage = "NSCameraUsageDescription"
        static let libraryUsage = "NSPhotoLibraryUsageDescription"
        static let microPhoneUsage = "NSMicrophoneUsageDescription"
    }
}
