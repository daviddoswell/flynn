//
//  ImagePickerCoordinator.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import UIKit
import PhotosUI

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
  var parent: ImagePicker
  
  init(_ parent: ImagePicker) {
    self.parent = parent
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let image = info[.originalImage] as? UIImage {
      let processedImage = processImage(image)
      parent.result.image = processedImage
    } else {
      DispatchQueue.main.async {
        self.parent.onError?(.failedToLoadCameraImage)
      }
    }
    parent.dismiss()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    parent.dismiss()
  }
  
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    parent.dismiss()
    
    guard let result = results.first else { return }
    
    if parent.includeLivePhotos {
      loadLivePhoto(from: result)
    }
    
    if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
      result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
        DispatchQueue.main.async {
          if let error = error {
            self?.parent.onError?(.photoLibraryError(error))
            return
          }
          
          guard let image = image as? UIImage else {
            self?.parent.onError?(.invalidImageType)
            return
          }
          
          let processedImage = self?.processImage(image)
          self?.parent.result.image = processedImage
        }
      }
    } else {
      DispatchQueue.main.async {
        self.parent.onError?(.unsupportedImageType)
      }
    }
  }
  
  private func loadLivePhoto(from result: PHPickerResult) {
    let identifier = UTType.livePhoto.identifier
    if result.itemProvider.hasItemConformingToTypeIdentifier(identifier) {
      result.itemProvider.loadFileRepresentation(forTypeIdentifier: identifier) { [weak self] url, error in
        if let error = error {
          DispatchQueue.main.async {
            self?.parent.onError?(.photoLibraryError(error))
          }
          return
        }
        
        guard let url = url else { return }
        
        PHLivePhoto.request(withResourceFileURLs: [url], placeholderImage: nil, targetSize: .zero, contentMode: .aspectFit) { livePhoto, _ in
          DispatchQueue.main.async {
            self?.parent.result.livePhoto = livePhoto
          }
        }
      }
    }
  }
  
  private func processImage(_ image: UIImage) -> UIImage {
    var processedImage = image
    
    if let maxSize = parent.qualityConfiguration.maximumSize {
      processedImage = processedImage.resize(to: maxSize)
    }
    
    return processedImage
  }
}
