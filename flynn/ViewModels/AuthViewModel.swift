//
//  AuthViewModel.swift
//  hairmax
//
//  Created by David Doswell on 10/31/24.
//

import Foundation
import SwiftUI
import Supabase

enum AuthError: Error {
  case userNotAuthenticated
}

@MainActor
class AuthViewModel: ObservableObject {
  @AppStorage("pendingVerificationEmail") private(set) var pendingEmail: String?
  
  // MARK: - Published Properties
  @Published var isAuthenticated = false
  @Published var isLoading = false
  @Published var error: String?
  @Published var email = ""
  @Published var password = ""
  @Published private(set) var userId: UUID?
  @Published private(set) var isNewUser = false
  
  // MARK: - Private Properties
  private let authManager: AuthManagerProtocol
  private let supabaseClient: SupabaseClient
  private let networkService: NetworkServiceProtocol
  private var sessionTask: Task<Void, Never>?
  
  // MARK: - Initialization
  init(authManager: AuthManagerProtocol, supabaseClient: SupabaseClient, networkService: NetworkServiceProtocol) {
    self.authManager = authManager
    self.supabaseClient = supabaseClient
    self.networkService = networkService
    
    // Start monitoring session
    monitorSession()
  }
  
  deinit {
    sessionTask?.cancel()
  }
  
  // MARK: - Public Methods
  
  func getAuthenticatedUserId() async throws -> UUID {
    guard let userId = userId else {
      throw AuthError.userNotAuthenticated
    }
    return userId
  }
  
  /// Signs in user with email
  func signInWithEmail() async {
    guard !email.isEmpty, !password.isEmpty else {
      error = "Please fill in all fields"
      return
    }
    
    isLoading = true
    error = nil
    
    do {
      let response = try await supabaseClient.auth.signIn(
        email: email,
        password: password
      )
      
      try await createUserIfNeeded(for: response.user.id)
      userId = response.user.id
      isNewUser = false
      isAuthenticated = true
      email = ""
      password = ""
      
    } catch {
      self.error = error.localizedDescription
      isAuthenticated = false
      userId = nil
      isNewUser = false
    }
    
    isLoading = false
  }
  
  /// Signs up user with email
  func signUpWithEmail() async {
    guard !email.isEmpty else {
      error = "Please enter an email"
      return
    }
    
    isLoading = true
    error = nil
    
    do {
      try await supabaseClient.auth.signInWithOTP(
        email: email,
        shouldCreateUser: true
      )
      pendingEmail = email
      isNewUser = true
      
    } catch {
      self.error = error.localizedDescription
      isNewUser = false
    }
    
    isLoading = false
  }
  
  func verifyOTP(_ code: String) async {
    guard let email = pendingEmail else { return }
    
    isLoading = true
    error = nil
    
    do {
      let response = try await supabaseClient.auth.verifyOTP(
        email: email,
        token: code,
        type: .email
      )
      
      userId = response.user.id
      pendingEmail = nil
      isAuthenticated = true
      isNewUser = true
      
    } catch {
      self.error = error.localizedDescription
    }
    
    isLoading = false
  }
  
  func resendOTP() async {
    guard let email = pendingEmail else { return }
    
    isLoading = true
    error = nil
    
    do {
      try await supabaseClient.auth.resend(
        email: email,
        type: .signup
      )
    } catch {
      self.error = error.localizedDescription
    }
    
    isLoading = false
  }
  
  /// Signs in user with Apple
  func signInWithApple() async {
    isLoading = true
    error = nil
    
    do {
      let response = try await authManager.signInWithApple()
      try await createUserIfNeeded(for: response.id)
      userId = response.id
      isNewUser = false
      isAuthenticated = true
    } catch {
      self.error = error.localizedDescription
      isAuthenticated = false
      userId = nil
      isNewUser = false
    }
    
    isLoading = false
  }
  
  /// Signs up user with Apple
  func signUpWithApple() async {
    isLoading = true
    error = nil
    
    do {
      let response = try await authManager.signInWithApple()
      userId = response.id
      isNewUser = true
      isAuthenticated = true
    } catch {
      self.error = error.localizedDescription
      isAuthenticated = false
      userId = nil
      isNewUser = false
    }
    
    isLoading = false
  }
  
  /// Signs out the current user
  // In AuthViewModel
  func signOut() async {
    isLoading = true
    error = nil
    
    do {
      try await supabaseClient.auth.signOut()
      
      if let domain = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: domain)
      }
      
      withAnimation(.easeOut(duration: 0.3)) {
        isAuthenticated = false
        userId = nil
      }
    } catch {
      self.error = error.localizedDescription
    }
    
    isLoading = false
  }
  
  private func createUserIfNeeded(for userId: UUID) async throws {
    do {
      _ = try await networkService.fetchUser(from: "users", userId: userId) as User
      return
    } catch NetworkError.failedToFetchUser {
      let newUser = User(
        id: userId,
        username: nil,
        firstName: nil,
        lastName: nil,
        birthYear: nil,
        city: nil,
        state: nil,
        hasSubscribed: false
      )
      try await networkService.insert(newUser, table: "users")
    }
  }
  
  private func monitorSession() {
    sessionTask = Task { [weak self] in
      guard let self = self else { return }
      
      do {
        if let session = try? await supabaseClient.auth.session {
          self.userId = session.user.id
          self.isAuthenticated = true
        } else {
          self.userId = nil
          self.isAuthenticated = false
        }
        
        for await event in supabaseClient.auth.authStateChanges {
          switch event.event {
          case .signedIn, .tokenRefreshed, .userUpdated:
            self.userId = event.session?.user.id
            self.isAuthenticated = true
          case .signedOut:
            self.userId = nil
            self.isAuthenticated = false
            UserDefaults.standard.set("signIn", forKey: "defaultAuthScreen")
          case .initialSession:
            self.userId = event.session?.user.id
            self.isAuthenticated = event.session != nil
          default:
            break
          }
        }
      }
    }
  }
  
  private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}

// MARK: - Preview Helper
extension AuthViewModel {
  static var preview: AuthViewModel {
    let supabaseClient = SupabaseClient(
      supabaseURL: Client.supabaseURL,
      supabaseKey: Client.supabaseKey
    )
    let authManager = AuthManager(supabaseClient: supabaseClient)
    let networkService = NetworkService(supabaseClient: supabaseClient)
    return AuthViewModel(authManager: authManager, supabaseClient: supabaseClient, networkService: networkService)
  }
}
