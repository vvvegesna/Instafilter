//
//  ContentView.swift
//  UIKitIntegration
//
//  Created by Vegesna, Vijay V EX1 on 8/14/20.
//  Copyright © 2020 Vegesna, Vijay V. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var inputImage: UIImage?
    @State private var isPresentingSheet = false
    @State private var showActionSheet = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var processedImage: UIImage?
    @State private var filterTitle = "Change Filter"
    @State private var showTransitionView = false
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double> (
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyingProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    if showTransitionView {
                        Text("Error!, please select an image")
                            .foregroundColor(Color.red)
                            .padding()
                            .background(Rectangle())
                            .transition(.move(edge: .top))
                            .animation(.easeInOut)
                    }
                    
                }
                .onTapGesture {
                    self.isPresentingSheet = true
                }
                
                HStack {
                    Text("Filter Intesity")
                    Slider(value: intensity)
                }.padding(.vertical)
                
                HStack {
                    Button("\(filterTitle)") {
                        self.showActionSheet = true
                    }
                    Spacer()
                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            self.showTransitionView = true
                            return
                        }
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Image saved!")
                        }
                        imageSaver.errorHandler = {
                            print("Error Occured! " + $0.localizedDescription)
                        }
                        imageSaver.writeToPhotosAlbum(processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $isPresentingSheet, onDismiss: loadImage) {
                ImagePicker(inputImage: self.$inputImage)
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize(), title: "Crystallize") },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges(), title: "Edges") },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur(), title: "Gaussian Blur") },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate(), title: "Pixellate") },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone(), title: "Sepia Tone") },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask(), title: "Unsharp Mask") },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette(), title: "Vignette") },
                    .cancel()
                ])
            }
        }
    }
    
    func setFilter(_ filter: CIFilter, title: String) {
        currentFilter = filter
        filterTitle = title
        loadImage()
    }
    
    func loadImage() {
        if let uiImage = inputImage {
            let beginImage = CIImage(image: uiImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyingProcessing()
        }
    }
    
    func applyingProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
            showTransitionView = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
