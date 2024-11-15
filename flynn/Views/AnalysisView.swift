//
//  AnalysisView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct AnalyzeView: View {
  @EnvironmentObject var appState: AppState
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: AnalysisViewModel
  @State private var selectedImage: UIImage?
  @State private var showImagePicker: Bool = false
  @State private var showCameraPicker: Bool = false
  @State private var imagePickerResult = ImagePickerResult()
  @State private var navigateToAnalysis: Bool = false
  @State private var showAnalysisError: Bool = false
  @State private var shouldReturnHome = false
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 32) {
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
          
          if let selectedImage {
            Button(action: {
              let generator = UIImpactFeedbackGenerator(style: .heavy)
              generator.impactOccurred()
              showImagePicker = true
            }) {
              Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
          } else {
            Button(action: {
              let generator = UIImpactFeedbackGenerator(style: .heavy)
              generator.impactOccurred()
              showImagePicker = true
            }) {
              Image("good-photo")
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Take a photo of your head or select an image for our assistant to analyze")
              .font(.system(size: 16, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
              .multilineTextAlignment(.center)
          }
          
          VStack(spacing: 24) {
            Button("Take a Photo") {
              let generator = UIImpactFeedbackGenerator(style: .heavy)
              generator.impactOccurred()
              showCameraPicker = true
            }
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button("Select Image") {
              let generator = UIImpactFeedbackGenerator(style: .heavy)
              generator.impactOccurred()
              showImagePicker = true
            }
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button(viewModel.isLoading ? "Analyzing..." : "Analyze") {
              let generator = UIImpactFeedbackGenerator(style: .heavy)
              generator.impactOccurred()
              
              viewModel.isLoading = true
              
              Task {
                await performAnalysis()
                viewModel.isLoading = false
              }
            }
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .disabled(viewModel.isLoading || selectedImage == nil)
          }
          .padding(.horizontal, 20)
          
          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .foregroundStyle(.red)
              .padding(.horizontal)
          }
          
          Spacer()
        }
        .padding(16)
      }
      .navigationTitle("")
      .navigationBarBackButtonHidden(true)
      .interactiveDismissDisabled()
      .sheet(isPresented: $showImagePicker) {
        ImagePicker.photoLibrary(
          result: $imagePickerResult,
          onError: { error in
            viewModel.errorMessage = error.localizedDescription
          }
        )
      }
      .sheet(isPresented: $showCameraPicker) {
        ImagePicker.camera(
          result: $imagePickerResult,
          onError: { error in
            viewModel.errorMessage = error.localizedDescription
          }
        )
      }
      .onChange(of: imagePickerResult) { oldResult, newResult in
        selectedImage = newResult.image
      }
      .navigationDestination(isPresented: $navigateToAnalysis) {
        if let analysis = viewModel.currentAnalysis {
          CreateDetailView(analysis: analysis)
            .onDisappear {
              if shouldReturnHome {
                dismiss()
              }
            }
        }
      }
      .alert("Analysis Failed", isPresented: $showAnalysisError) {
        Button("Try Again", role: .none) {
          Task {
            await performAnalysis()
          }
        }
        Button("Cancel", role: .cancel) {
          selectedImage = nil
        }
      } message: {
        Text("Unable to analyze the image. Please try again with a different photo or angle.")
      }
      
      if viewModel.isLoading {
        VStack {
          CustomProgressView()
            .frame(width: 200, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.5))
        .ignoresSafeArea()
      }
    }
  }
  
  private func performAnalysis() async {
    do {
      let image = try selectedImage.unwrapOrThrow(AnalysisError.imageProcessingFailed)
      
      let resizedImage = try resizeImage(image, targetSize: CGSize(width: 512, height: 512))
        .unwrapOrThrow(AnalysisError.imageProcessingFailed)
      let imageData = try resizedImage.jpegData(compressionQuality: 0.8)
        .unwrapOrThrow(AnalysisError.imageProcessingFailed)
      
      await viewModel.analyze(image: image, imageData: imageData)
      
      if viewModel.currentAnalysis != nil {
        navigateToAnalysis = true
      } else {
        showAnalysisError = true
      }
    } catch {
      viewModel.errorMessage = error.localizedDescription
      showAnalysisError = true
    }
  }
}

extension Optional {
  func unwrapOrThrow(_ error: Error) throws -> Wrapped {
    guard let value = self else {
      throw error
    }
    return value
  }
}
