import SwiftUI

struct ContentView: View {
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? // The optional video URL
    
    var body: some View {
        VStack {
            Button(action: {
                isImagePickerPresented.toggle()
            }) {
                Text("Pick a Video")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // If a video is selected, show the URL path
            if let selectedVideoURL = selectedVideoURL {
                Text("Video URL: \(selectedVideoURL.lastPathComponent)")
                    .padding()
                
                // Button to upload video
                Button(action: {
                    // Ensure the URL is not nil before uploading
                    let videoURL = selectedVideoURL
                    
                    // Upload video using VideoUpload class
                    VideoUpload.uploadVideo(videoURL: videoURL) { success, message in
                        if success {
                            print("Upload success: \(message ?? "")")
                        } else {
                            print("Upload failed: \(message ?? "")")
                        }
                    }
                }) {
                    Text("Upload Video")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                // Show a message if no video has been selected
                Text("Please select a video to upload.")
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            // Pass the correct mediaTypes here (allowing only videos)
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL, mediaTypes: ["public.movie"])
        }
    }
}

#Preview {
    ContentView()
}
