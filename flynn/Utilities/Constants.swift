//
//  Constants.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import Foundation

enum Constants {
  enum Config {
    static let supabaseURL = "https://jbbcwwdidceawzzxjask.supabase.co/"
  }
  
  enum Storage {
    static let bucketName = "heads"
    static let imagePath = "images"
  }
  
  enum Tables {
    static let heads = "heads"
  }
  
  enum Error {
    static let imageUploadFailed = "Failed to upload image"
    static let analysisError = "Failed to analyze image"
    static let networkError = "Network connection error"
  }
}
