//
//  CreateDetailView.swift
//  flynnapp
//
//  Created by David Doswell on 11/15/24.
//

import SwiftUI

struct ReturnToCreateHandler: ViewModifier {
  let shouldReturnHome: Binding<Bool>?
  let dismiss: DismissAction
  
  func body(content: Content) -> some View {
    if let returnHome = shouldReturnHome {
      content.onChange(of: returnHome.wrappedValue) { _, shouldReturn in
        if shouldReturn {
          dismiss()
        }
      }
    } else {
      content
    }
  }
}

struct CreateDetailView: View {
  // MARK: - Properties
  
  // Environment Objects
  @EnvironmentObject private var appState: AppState
  @Environment(\.dismiss) private var dismiss
  
  // State Variables
  @State private var showingTips = false
  @State private var showingOptions = false
  @State private var shouldReturnToAnalysis = false
  
  // Bindings and Data
  var shouldReturnHome: Binding<Bool>? = nil
  var analysis: Analysis
  
  // MARK: - Body
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {
          headerSection
          imageSection
          timelineSection
          riskSection
          delayHairLossButton
          patternDetailsSection
          moreOptionsButton
        }
        .padding(16)
      }
      .navigationTitle("")
      .navigationBarBackButtonHidden(true)
      .confirmationDialog("Options", isPresented: $showingOptions) {
//        Button("Save Analysis") {
//          let generator = UIImpactFeedbackGenerator(style: .heavy)
//          generator.impactOccurred()
//          Task {
//            do {
//              try await appState.analysisViewModel.saveAnalysis(analysis)
//              await appState.homeViewModel.fetchAnalyses()
//              if let returnHome = shouldReturnHome {
//                returnHome.wrappedValue = true
//              }
//              dismiss()
//            } catch {
//              print("Save error: \(error.localizedDescription)")
//            }
//          }
//        }
        
        Button("Delete Analysis", role: .destructive) {
          let generator = UIImpactFeedbackGenerator(style: .heavy)
          generator.impactOccurred()
          shouldReturnToAnalysis = true
          dismiss()
        }
        
        Button("Return Home", role: .cancel) {
          let generator = UIImpactFeedbackGenerator(style: .heavy)
          generator.impactOccurred()
          if let returnHome = shouldReturnHome {
            returnHome.wrappedValue = true
          }
          dismiss()
        }
      } message: {
        Text("Choose an action")
      }
      .onChange(of: shouldReturnToAnalysis) { _, shouldReturn in
        if shouldReturn {
          dismiss()
        }
      }
      .modifier(ReturnToCreateHandler(shouldReturnHome: shouldReturnHome, dismiss: dismiss))
    }
  }
  
  // MARK: - View Components
  
  private var headerSection: some View {
    HStack {
      Button(action: {
        dismiss()
      }) {
        HStack {
          Image(systemName: "chevron.left")
          Text("Back")
        }
        .foregroundStyle(.white.opacity(0.8))
        .font(.system(size: 18, weight: .bold, design: .rounded))
      }
      Spacer()
    }
    .padding(.top, 16)
  }
  
  private var imageSection: some View {
    AsyncImage(url: URL(string: analysis.imageURL)) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    } placeholder: {
      ProgressView()
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .padding(.bottom, 8)
  }
  
  private var timelineSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Predicted Hair Loss by")
        .font(.system(size: 24, weight: .heavy, design: .rounded))
        .fontWeight(.heavy)
        .foregroundStyle(.white.opacity(0.8))
      Text(analysis.timeline)
        .font(.system(size: 32, weight: .heavy, design: .rounded))
        .foregroundStyle(riskColor(for: analysis.riskLevel.rawValue))
    }
    .padding(.horizontal)
    .padding(.bottom, 8)
  }
  
  private var riskSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        let riskLevelText = "\(analysis.riskLevel.rawValue.capitalized) Risk"
        Image(systemName: riskIcon(for: analysis.riskLevel.rawValue))
          .font(.system(size: 24, weight: .heavy, design: .rounded))
          .foregroundStyle(riskColor(for: analysis.riskLevel.rawValue))
        Text(riskLevelText)
          .font(.system(size: 16, weight: .heavy, design: .rounded))
          .foregroundStyle(riskColor(for: analysis.riskLevel.rawValue))
        Spacer()
      }
      
      Text(analysis.currentStage)
        .font(.system(size: 16, weight: .heavy, design: .rounded))
        .foregroundStyle(.white.opacity(0.8))
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 4)
    }
    .padding(.horizontal)
    .padding(.bottom, 8)
  }
  
  private var delayHairLossButton: some View {
    Button {
      showingTips = true
    } label: {
      HStack {
        Text("Delay Hair Loss")
          .font(.system(size: 16, weight: .heavy, design: .rounded))
        Image(systemName: "arrow.right.circle.fill")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(.gray.opacity(0.2))
      .foregroundStyle(.white.opacity(0.8))
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(.horizontal)
    .padding(.bottom)
    .navigationDestination(isPresented: $showingTips) {
      DelayHairLossView(
        timeline: analysis.timeline,
        riskLevel: analysis.riskLevel.rawValue
      )
    }
  }
  
  private var patternDetailsSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Pattern Details")
        .font(.system(size: 24, weight: .heavy, design: .rounded))
        .foregroundStyle(.white.opacity(0.8))
        .padding(.bottom)
      
      ForEach(analysis.patternDetails, id: \.area) { detail in
        VStack(alignment: .leading, spacing: 8) {
          Text(detail.area)
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.gray)
          
          Text(detail.description)
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
        }
        .padding(.bottom, 8)
      }
    }
    .padding(.horizontal)
    .padding(.bottom)
  }
  
  private var moreOptionsButton: some View {
    Button {
      showingOptions = true
    } label: {
      Text("More Options")
        .font(.system(size: 16, weight: .heavy, design: .rounded))
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .foregroundStyle(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(.horizontal)
    .padding(.bottom)
  }
  
  // MARK: - Helper Functions
  
  private func riskColor(for level: String) -> Color {
    switch level {
    case "Low": return .green
    case "Medium": return .yellow
    case "High": return .red
    default: return .secondary
    }
  }
  
  private func riskIcon(for level: String) -> String {
    switch level {
    case "Low": return "checkmark.circle.fill"
    case "Medium": return "exclamationmark.circle.fill"
    case "High": return "xmark.circle.fill"
    default: return "circle.fill"
    }
  }
}
