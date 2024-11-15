//
//  UIImage+Processing.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import UIKit

extension UIImage {
  func resize(to targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height
    let ratio = min(widthRatio, heightRatio)
    
    let newSize = CGSize(
      width: size.width * ratio,
      height: size.height * ratio
    )
    
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { context in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
}
