//
//  ProductsView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct ProductsView: View {
  @EnvironmentObject private var manager: AutoProgressManager
  @State private var selectedPreference: ProductInput.ProductPreference?
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      VStack(spacing: 32) {
        Text("What products do you prefer?")
          .font(.system(size: 32, weight: .heavy, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.top, 60)
        
        VStack(spacing: 16) {
          ForEach(ProductInput.ProductPreference.allCases, id: \.self) { preference in
            PreferenceButton(
              title: preference.title,
              description: preference.description,
              isSelected: selectedPreference == preference,
              action: {
                selectedPreference = preference
              }
            )
          }
        }
        .padding(.horizontal, 20)
        
        Spacer()
        
        Button(action: {
          if let preference = selectedPreference {
            let input = ProductInput(preference: preference)
            Task {
              await manager.updateAndProgress(input: input)
            }
          }
        }) {
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
        .disabled(selectedPreference == nil)
      }
    }
  }
}

struct PreferenceButton: View {
  let title: String
  let description: String
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(title)
            .font(.system(size: 18, weight: .bold, design: .rounded))
          Spacer()
          Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 24))
        }
        
        Text(description)
          .font(.system(size: 14, weight: .medium, design: .rounded))
          .opacity(0.8)
      }
      .foregroundStyle(.white.opacity(0.8))
      .padding()
      .background(Color.white.opacity(isSelected ? 0.3 : 0.2))
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

extension ProductInput.ProductPreference {
  var title: String {
    switch self {
    case .natural:
      return "Natural Products"
    case .prescription:
      return "Prescription Products"
    case .combination:
      return "Combination Approach"
    }
  }
  
  var description: String {
    switch self {
    case .natural:
      return "Plant-based remedies and natural treatments"
    case .prescription:
      return "FDA-approved medications and treatments"
    case .combination:
      return "Mix of natural and prescription solutions"
    }
  }
}

#Preview {
  ProductsView()
}
