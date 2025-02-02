import SwiftUI
import AVKit
import AVFoundation

// VideoPlayerView for playing the video
struct VideoPlayerView: View {
    @Binding var player: AVPlayer? // Binding to the player passed from ContentView
    var videoURL: URL // URL of the video to play
    var onVideoEnd: () -> Void // Closure to notify when the video ends
    
    var body: some View {
        VStack {
            if let player = player {
                // VideoPlayer is used to display the video
                VideoPlayer(player: player)
                    .onAppear {
                        playVideo()
                    }
                    .onDisappear {
                        player.pause() // Pause when leaving the view
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.6) // Reduce height to leave room for buttons
            } else {
                Text("Loading video...")
                    .padding()
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    // Set up the AVPlayer
    func setupPlayer() {
        DispatchQueue.main.async {
            self.player = AVPlayer(url: videoURL)
            // Add observer to know when the video finishes
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                onVideoEnd() // Call the closure when video ends
            }
        }
    }
    
    // Function to play the video
    func playVideo() {
        player?.play()
    }
}

// ContentView where the video is fetched and the user can pick a video
struct ContentView: View {
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedVideoURL: URL? // The optional video URL for selected video
    @State private var videoURLFromAPI: URL? // The video URL fetched from API
    @State private var videos: [VideoItem] = [] // Array to hold videos fetched from the API
    @State private var selectedImage: UIImage? = nil // State for the selected image
    @State private var isVideoPlayerVisible: Bool = false // State to toggle video player visibility
    @State private var isVideoExpanded: Bool = false // State to expand video and thumbnails to full screen
    @State private var isMainScreenVisible: Bool = true // State to toggle between main screen and video content
    @State private var currentVideo: VideoItem? // Store current video for playback
    @State private var player: AVPlayer? // Keep track of the AVPlayer instance (now in ContentView)
    @State private var isPlayerReady: Bool = false // Flag to check if the player is ready to play a video
    
    var body: some View {
        ZStack {
            // Main Content View (Background)
            LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Main Screen View
            if isMainScreenVisible {
                VStack {
                    Text("CleanBucket")
                        .font(.system(size: 35, weight: .bold)) // Heavy SF Pro
                        .foregroundColor(.orange)
                        .overlay(
                            Text("CleanBucket")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.white) // Outline color
                            .offset(x: 1, y: 1) // Offset to create the outline effect
                        )
                        .padding(.top, 50)
                    
                    Image("cleanbucketlogo") // Replace with your logo image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20)) // Apply rounded rectangle shape
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 4)) // Optional: Add a border with rounded corners
                        .shadow(color: Color.teal.opacity(0.7), radius: 10) // Optional: Add shadow for a more elevated look
                        .padding(.bottom, 40)

                    // Button to show the video content (thumbnails + video player)
                    Button(action: {
                        withAnimation {
                            isVideoExpanded.toggle() // Toggle full-screen video content
                            isMainScreenVisible = false // Hide the main screen
                        }
                    }) {
                        Text("Watch Videos 👀")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 50)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.teal)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 10)
                    
                    // "Pick a Video" button
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        Text("Pick a Video")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 50)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.green)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 10)
                }
            }
            
            // Video Content View (Thumbnails + Video Player)
            if !isMainScreenVisible {
                VStack {
                    // Show the video list (thumbnails) in a horizontal leaderboard-like format
                    if !videos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(videos) { video in
                                    VStack {
                                        if let imageData = Data(base64Encoded: video.thumbnail),
                                           let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 120) // Thumbnail size
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .shadow(radius: 5)
                                                .onTapGesture {
                                                    // On tap, fetch and play the video
                                                    playVideoFromAPI(video)
                                                }
                                        }
                                        Text(video.videoName)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.bottom, 10)
                                }
                            }
                            .padding()
                        }
                    }

                    // Back to the main screen button
                    Button(action: {
                        withAnimation {
                            isMainScreenVisible = true // Show the main screen again
                            isVideoExpanded = false
                            stopVideo() // Stop the video playback
                        }
                    }) {
                        Text("Back to Main")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 50)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 10)
                    
                    // Show the video player if the button is pressed
                    if let currentVideo = currentVideo, isVideoExpanded {
                        if isPlayerReady {
                            VideoPlayerView(player: $player, videoURL: URL(string: "https://video.cleanbucket.co/api/videos/\(currentVideo.videoName)")!,
                                         onVideoEnd: {
                                             // When the video ends, show options to watch another video
                                             showWatchAnotherOption()
                                         })
                                .transition(.slide) // Optional animation for the appearance of the video player
                        } else {
                            Text("Loading video...")
                                .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchVideos() // Fetch videos from API on appearance
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL, mediaTypes: ["public.movie"])
        }
    }
    
    // Fetch videos from the API
    func fetchVideos() {
        let urlString = "https://video.cleanbucket.co/api/topvid"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let videosResponse = try decoder.decode([String: Video].self, from: data)
                    DispatchQueue.main.async {
                        // Map the decoded data into an array and assign to videos state
                        self.videos = videosResponse.values.map { video in
                            VideoItem(videoName: video.videoName, thumbnail: video.thumbnail)
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            } else {
                print("Invalid response or status code.")
            }
        }
        
        task.resume()
    }
    
    // Play video when thumbnail is tapped
    func playVideoFromAPI(_ video: VideoItem) {
        // Stop the current video if it's playing
        stopVideo()
        
        // Reset the current video and reinitialize the player
        self.currentVideo = video // Set the current video to play
        self.isPlayerReady = false // Reset the player readiness flag
        self.isVideoExpanded = true // Show the video player
        
        // Initialize the player asynchronously
        DispatchQueue.global().async {
            let videoURL = URL(string: "https://video.cleanbucket.co/api/videos/\(video.videoName)")!
            self.player = AVPlayer(url: videoURL)
            DispatchQueue.main.async {
                self.isPlayerReady = true // Set player to ready
                self.player?.play() // Start playback
            }
        }
    }
    
    // Stop the current video
    func stopVideo() {
        player?.pause() // Pause the current video
        player = nil // Reset the player
        isPlayerReady = false // Reset player readiness
    }

    // Show options after video ends
    func showWatchAnotherOption() {
        // Show options like "Watch Another Video"
        print("Video ended. Show options to watch another video.")
    }
}

// Video item for displaying in ContentView (using Identifiable for List)
struct VideoItem: Identifiable {
    let id = UUID()
    let videoName: String
    let thumbnail: String
}
