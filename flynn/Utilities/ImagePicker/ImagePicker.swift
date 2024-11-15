//
//  ImagePicker.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
  let sourceType: UIImagePickerController.SourceType
  @Binding var result: ImagePickerResult
  @Environment(\.dismiss) var dismiss
  
  // Configuration options
  var selectionLimit: Int = 1
  var photoLibraryFilter: PHPickerFilter = .images
  var preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic
  var includeLivePhotos: Bool = false
  var qualityConfiguration: ImagePickerConfig = .default
  
  // Error handling
  var onError: ((ImagePickerError) -> Void)?
  
  func makeUIViewController(context: Context) -> UIViewController {
    switch sourceType {
    case .camera:
      guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
        DispatchQueue.main.async {
          onError?(.cameraUnavailable)
          dismiss()
        }
        return UIViewController()
      }
      
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = context.coordinator
      return picker
      
    case .photoLibrary, .savedPhotosAlbum:
      var config = PHPickerConfiguration()
      config.filter = includeLivePhotos ? .any(of: [.images, .livePhotos]) : photoLibraryFilter
      config.selectionLimit = selectionLimit
      config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
      
      let picker = PHPickerViewController(configuration: config)
      picker.delegate = context.coordinator
      return picker
      
    @unknown default:
      fatalError()
    }
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
  
  func makeCoordinator() -> ImagePickerCoordinator {
    ImagePickerCoordinator(self)
  }
}

// MARK: - Factory Methods
extension ImagePicker {
  static func photoLibrary(
    result: Binding<ImagePickerResult>,
    includeLivePhotos: Bool = false,
    qualityConfiguration: ImagePickerConfig = .default,
    selectionLimit: Int = 1,
    filter: PHPickerFilter = .images,
    representationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
    onError: ((ImagePickerError) -> Void)? = nil
  ) -> ImagePicker {
    ImagePicker(
      sourceType: .photoLibrary,
      result: result,
      selectionLimit: selectionLimit,
      photoLibraryFilter: filter,
      preferredAssetRepresentationMode: representationMode,
      includeLivePhotos: includeLivePhotos,
      qualityConfiguration: qualityConfiguration,
      onError: onError
    )
  }
  
  static func camera(
    result: Binding<ImagePickerResult>,
    qualityConfiguration: ImagePickerConfig = .default,
    onError: ((ImagePickerError) -> Void)? = nil
  ) -> ImagePicker {
    ImagePicker(
      sourceType: .camera,
      result: result,
      qualityConfiguration: qualityConfiguration,
      onError: onError
    )
  }
}
