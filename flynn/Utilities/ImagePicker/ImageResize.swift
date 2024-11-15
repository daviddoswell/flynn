//
//  ImageResize.swift
//  hairmax
//
//  Created by David Doswell on 11/4/24.
//

import UIKit

func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
  let size = image.size
  
  let widthRatio  = targetSize.width  / size.width
  let heightRatio = targetSize.height / size.height
  
  // Determine the scale factor
  let scaleFactor = min(widthRatio, heightRatio)
  
  // Compute the new image size
  let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
  
  // Draw and return the resized UIImage
  UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
  image.draw(in: CGRect(origin: .zero, size: scaledSize))
  let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return resizedImage
}
