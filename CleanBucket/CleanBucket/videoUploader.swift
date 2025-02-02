import Foundation
import UIKit

class VideoUpload: NSObject {

    // This function uploads a video to the server
    static func uploadVideo(videoURL: URL, completion: @escaping (Bool, String?) -> Void) {
        
        // 1. Create a URL object for the upload endpoint
        guard let url = URL(string: "http://video.cleanbucket.co/api/upload") else {
            completion(false, "Invalid URL")
            return
        }
        
        // 2. Create the boundary string for the multipart form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // 3. Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 4. Create the data body
        var body = Data()

        // Add the video data to body
        let videoData = try? Data(contentsOf: videoURL)
        if let videoData = videoData {
            let filename = videoURL.lastPathComponent
            let mimeType = "video/mp4"  // Assuming video is in mp4 format
            
            // Add video data
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(videoData)
            body.append("\r\n")
        }
        
        // Close the body
        body.append("--\(boundary)--\r\n")
        
        // 5. Set the HTTP body
        request.httpBody = body
        
        // 6. Create a URLSession to send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // 7. Check for errors
            if let error = error {
                completion(false, "Upload failed: \(error.localizedDescription)")
                return
            }
            
            // 8. Check the response status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, "Video uploaded successfully.")
            } else {
                completion(false, "Upload failed. Server returned an error.")
            }
        }
        
        // 9. Start the upload task
        task.resume()
    }
}

// Helper extension to append data to the HTTP body
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
