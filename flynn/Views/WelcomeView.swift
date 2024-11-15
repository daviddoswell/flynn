//
//  WelcomeView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct WelcomeView: View {
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var manager: AutoProgressManager
  @State private var buttonScale: CGFloat = 1.0
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      ScrollView {
        VStack {
          Spacer(minLength: 100)
          
          VStack(spacing: 30) {
            Image("logo")
              .resizable()
              .scaledToFill()
              .frame(width: 100, height: 100)
              .opacity(0.8)
            
            Text("Flynn")
              .font(.system(size: 48, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
            
            Text("Get Your Hair Back")
              .font(.system(size: 24, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
              .multilineTextAlignment(.center)
            
            Button(action: {
              buttonTapped()
            }) {
              Text("Get Started")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .scaleEffect(buttonScale)
            .padding(.horizontal, 20)
          }
          .frame(maxWidth: .infinity)
          .padding(.horizontal, 20)
          
          Spacer(minLength: 50)
        }
      }
    }
  }
  
  private func buttonTapped() {
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
    
    withAnimation(.easeInOut(duration: 0.2)) {
      buttonScale = 0.90
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(.easeInOut(duration: 0.2)) {
        buttonScale = 1.0
      }
    }
    
    DispatchQueue.main.async {
      manager.moveToNextStep()
    }
  }
}

#Preview {
  WelcomeView()
}
