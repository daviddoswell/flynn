//
//  Container.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import Foundation
import Supabase

@Observable
final class Container {
  var networkService: NetworkService
  var imageAnalysisService: ImageAnalysisServiceProtocol
  var analysisManager: AnalysisManagerProtocol
  var authManager: AuthManagerProtocol
  var supabaseClient: SupabaseClient
  
  init() {
    let supabaseClient = SupabaseClient(
      supabaseURL: URL(string: Constants.Config.supabaseURL)!,
      supabaseKey: Constants.Config.supabaseKey
    )
    self.supabaseClient = supabaseClient
    
    let networkService = NetworkService(supabaseClient: supabaseClient)
    self.networkService = networkService
    
    let authManager = AuthManager(supabaseClient: supabaseClient)
    self.authManager = authManager
    
    let imageAnalysisService = ImageAnalysisService(
      apiKey: Constants.Config.claudeKey,
      networkService: networkService
    )
    self.imageAnalysisService = imageAnalysisService
    
    self.analysisManager = AnalysisManager(
      networkService: networkService,
      imageAnalysisService: imageAnalysisService
    )
  }
}
