//
//  CreateView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI
import Supabase

struct CreateView: View {
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.appBackground
          .ignoresSafeArea()
        
        VStack {
          if appState.analysisViewModel.analyses.isEmpty {
            EmptyStateView()
          } else {
            AnalysesList(analyses: appState.analysisViewModel.analyses)
          }
        }
        .navigationBarHidden(true)
      }
    }
  }
}

struct EmptyStateView: View {
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    VStack {
      Spacer()
      
      NavigationLink(destination: AnalyzeView(viewModel: appState.analysisViewModel)) {
        VStack(spacing: 16) {
          Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 100)
          Text("Create Your First Analysis")
            .font(.system(size: 40, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
        }
      }
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct AnalysesList: View {
  let analyses: [Analysis]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 20) {
        ForEach(analyses) { analysis in
          Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
          }) {
            NavigationLink(destination: CreateDetailView(analysis: analysis)) {
              AnalysisCard(analysis: analysis)
            }
          }
          .buttonStyle(PlainButtonStyle())
        }
      }
      .padding()
    }
  }
}

struct AnalysisCard: View {
  let analysis: Analysis
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Image("logo")
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)
      }
      
      VStack(alignment: .leading) {
        HStack(spacing: 4) {
          Text("Ready for Review")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .bold()
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
          
          Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 24))
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal)
        
        Spacer()
        
        HStack {
          Text(analysis.createdAt, style: .date)
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .foregroundStyle(.gray)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
          Spacer()
          Text(analysis.createdAt.timeAgoDisplay())
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .foregroundStyle(.gray)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
        }
      }
      .padding(.horizontal)
      
      Spacer()
    }
    .frame(width: 300, height: 400)
    .background(.gray.opacity(0.2))
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
  let container = Container()
  let appState = AppState(container: container)
  return CreateView()
    .environmentObject(appState)
}
