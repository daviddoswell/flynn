//
//  Client.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import Foundation
import Supabase

struct Client {
  static var supabaseURL: URL {
    URL(string: Constants.Config.supabaseURL)!
  }
  
  static var supabaseKey: String {
    Constants.Config.supabaseKey
  }
  
  static var claudeKey: String {
    Constants.Config.claudeKey
  }
  
  static func config() -> (supabase: URL, String) {
    return (supabaseURL, supabaseKey)
  }
}
