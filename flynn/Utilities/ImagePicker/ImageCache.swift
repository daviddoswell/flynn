//
//  ImageCache.swift
//  hairmax
//
//  Created by David Doswell on 11/5/24.
//

import Foundation
import UIKit

final class ImageCache {
  static let shared = ImageCache()
  private var cache = NSCache<NSString, UIImage>()
  
  private init() {
    cache.countLimit = 100
  }
  
  func set(_ image: UIImage, for key: String) {
    cache.setObject(image, forKey: key as NSString)
  }
  
  func get(_ key: String) -> UIImage? {
    cache.object(forKey: key as NSString)
  }
  
  func remove(_ key: String) {
    cache.removeObject(forKey: key as NSString)
  }
}
