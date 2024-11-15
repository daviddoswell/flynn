//
//  AboutView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct AboutView: View {
  @EnvironmentObject private var manager: AutoProgressManager
  @State private var currentPage = 0
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      TabView(selection: $currentPage) {
        AboutPageView(
          image: "analyze",
          title: "AI Analysis",
          description: "Flynn uses advanced AI to analyze your hair health from photos"
        )
        .tag(0)
        
        AboutPageView(
          image: "assess",
          title: "Health Assessment",
          description: "Get detailed insights about your hair's current condition"
        )
        .tag(1)
        
        AboutFinalPageView(
          image: "award",
          title: "Personalized Plan",
          description: "Receive customized recommendations for your hair health journey",
          onContinue: {
            manager.moveToNextStep()
          }
        )
        .tag(2)
      }
      .tabViewStyle(.page)
      .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
  }
}

struct AboutPageView: View {
  let image: String
  let title: String
  let description: String
  
  var body: some View {
    VStack {
      Spacer()
      
      VStack(spacing: 32) {
        Image(image)
          .resizable()
          .scaledToFit()
          .frame(height: 88)
        
        VStack(spacing: 16) {
          Text(title)
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
          
          Text(description)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
      }
      
      Spacer()
    }
  }
}

struct AboutFinalPageView: View {
  let image: String
  let title: String
  let description: String
  let onContinue: () -> Void
  
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        
        VStack(spacing: 32) {
          Image(image)
            .resizable()
            .scaledToFit()
            .frame(height: 88)
          
          VStack(spacing: 16) {
            Text(title)
              .font(.system(size: 32, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
            
            Text(description)
              .font(.system(size: 18, weight: .bold, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }
        }
        
        Spacer()
      }
      
      VStack {
        Spacer()
        
        Button(action: onContinue) {
          Text("Continue")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 180)
      }
    }
  }
}

#Preview {
  AboutView()
}
