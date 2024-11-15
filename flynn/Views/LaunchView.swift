//
//  LaunchView.swift
//  hairmax
//
//  Created by David Doswell on 11/9/24.
//

import SwiftUI

struct LaunchView: View {
  @EnvironmentObject private var appState: AppState
  @State private var isLoading = true
  @State private var error: Error?
  @State private var scale: CGFloat = 0.8
  @State private var launchOpacity: CGFloat = 1.0
  
  var body: some View {
    ZStack {
      ContentView()
      
      if isLoading {
        Color.appBackground
          .ignoresSafeArea()
          .opacity(launchOpacity)
        
        Image("logo")
          .resizable()
          .scaledToFit()
          .frame(width: 120, height: 120)
          .scaleEffect(scale)
          .opacity(launchOpacity)
          .animation(
            Animation
              .easeInOut(duration: 1.0)
              .repeatForever(autoreverses: true),
            value: scale
          )
          .onAppear {
            scale = 1.0
          }
      }
    }
    .task {
      do {
        withAnimation(.easeOut(duration: 0.3)) {
          launchOpacity = 0
        }
        
        try await Task.sleep(nanoseconds: 300_000_000)
        isLoading = false
      } catch {
        self.error = error
        isLoading = false
      }
    }
    .alert("Error", isPresented: .constant(error != nil)) {
      Button("OK") {
        error = nil
      }
    } message: {
      Text(error?.localizedDescription ?? "Unknown error occurred")
    }
  }
}
