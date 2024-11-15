//
//  ImagePickerError.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import Foundation

enum ImagePickerError: LocalizedError {
  case cameraUnavailable
  case failedToLoadCameraImage
  case photoLibraryError(Error)
  case invalidImageType
  case unsupportedImageType
  
  var errorDescription: String? {
    switch self {
    case .cameraUnavailable:
      "Camera is not available on this device"
    case .failedToLoadCameraImage:
      "Failed to capture image from camera"
    case .photoLibraryError(let error):
      "Photo library error: \(error.localizedDescription)"
    case .invalidImageType:
      "Selected item is not a valid image"
    case .unsupportedImageType:
      "Selected image type is not supported"
    }
  }
}
