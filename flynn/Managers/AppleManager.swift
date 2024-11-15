//
//  AppleManager.swift
//  hairmax
//
//  Created by David Doswell on 10/31/24.
//

import SwiftUI
import AuthenticationServices

class AppleManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  private var completion: ((Result<String, Error>) -> Void)?
  
  func signIn() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
      let provider = ASAuthorizationAppleIDProvider()
      let request = provider.createRequest()
      request.requestedScopes = [.fullName, .email]
      
      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      
      completion = { result in
        switch result {
        case .success(let token):
          continuation.resume(returning: token)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
      
      controller.performRequests()
    }
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first else {
      fatalError("No window found")
    }
    return window
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let identityToken = appleIDCredential.identityToken,
          let token = String(data: identityToken, encoding: .utf8) else {
      completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get token"])))
      return
    }
    completion?(.success(token))
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    completion?(.failure(error))
  }
}
