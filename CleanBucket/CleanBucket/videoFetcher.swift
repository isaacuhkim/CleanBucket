//
//  videoFetcher.swift
//  CleanBucket
//
//  Created by Isaac Kim on 2/2/25.
//

import Foundation

func fetchVideos() {
    // The URL of the API endpoint
    let urlString = "https://video.cleanbucket.co/api/topvid"
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    // Create a data task to fetch the JSON data
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle errors
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        // Check if the response is valid
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Decode the JSON into the VideosResponse model
            do {
                let decoder = JSONDecoder()
                let videos = try decoder.decode(VideosResponse.self, from: data)
                
                // Handle decoded videos
                for (key, video) in videos {
                    print("Video ID: \(key), Name: \(video.videoName)")
                    
                    // Handle base64 encoded thumbnail here, decode and display it
                    if let imageData = Data(base64Encoded: video.thumbnail) {
                        print("Thumbnail data size: \(imageData.count) bytes")
                        // You can now use this image data (e.g., display in an image view)
                    } else {
                        print("Invalid base64 string for thumbnail.")
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        } else {
            print("Invalid response or status code.")
        }
    }
    
    // Start the request
    task.resume()
}

