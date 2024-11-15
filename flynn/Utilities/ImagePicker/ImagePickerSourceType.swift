//
//  ImagePickerSourceType.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import UIKit

enum ImagePickerSourceType {
  case camera
  case photoLibrary
  
  var pickerSourceType: UIImagePickerController.SourceType {
    switch self {
    case .camera:
        .camera
    case .photoLibrary:
        .photoLibrary
    }
  }
}
