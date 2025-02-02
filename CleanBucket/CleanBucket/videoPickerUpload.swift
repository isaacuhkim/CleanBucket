import Foundation
import Alamofire
import UIKit

class YourViewController: UIViewController {
    
    var arrVideo: [URL] = [] // Make sure this is populated with the video URL

    func uploadVideo() {
        guard let postContent = "Some post content here" as String? else {
            return
        }
        
        let url = URL(string: "http://video.cleanbucket.co/api/upload")
        
        guard let token = UserDefaults.standard.string(forKey: "Key") else {
            print("No token found")
            return
        }
        
        let header: HTTPHeaders = ["token": token]
        let parameter: [String: Any] = ["post_content": postContent, "type": "image"]
        
        AF.upload(multipartFormData: { [weak self] multipartFormData in
            for (key, value) in parameter {
                if let value = value as? String, let data = value.data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            
            // Ensure the video URL is valid before using it
            guard let videoURL = self?.arrVideo.first else {
                print("No video URL found")
                return
            }
            
            do {
                let videoData = try Data(contentsOf: videoURL)
                print("Video data:", videoData)
                multipartFormData.append(videoData, withName: "media_file", fileName: "album_file.mp4", mimeType: "mp4")
            } catch {
                debugPrint("Couldn't get Data from URL")
            }
        }, to: url!, method: .post, headers: header).responseJSON { [weak self] response in
            print("This is the result", response.result)
            switch response.result {
            case .failure(let error):
                if let code = error.responseCode {
                    print("Unable to upload the video and create a post. Response code:", code)
                }
            case .success(let success):
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
}
