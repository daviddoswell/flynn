//
//  ImagePickerConfig.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import UIKit

struct ImagePickerConfig {
  var compressionQuality: CGFloat = 0.8
  var maximumSize: CGSize?
  
  static let `default` = ImagePickerConfig()
}
