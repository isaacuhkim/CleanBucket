import Foundation
import Alamofire
import UIKit

let url = URL(string: "http://google.com")
let header : HTTPHeaders = ["token": UserDefaults.standard.string(forKey: "Key")!]
let parameter : [String: Any] = ["post_content" : post.text!, "type": "image",
]
.upload(multipartFormData: { (multipartFormData) in
for (key, value) in parameter{
multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
}
let diceRoll = Int(arc4random_uniform(UInt32(100000)))
do {
let videoData = try Data(contentsOf: self.arrVideo[0])
print("",videoData)
multipartFormData.append(videoData, withName: "media_file", fileName: "album_file.mp4", mimeType: "mp4")
} catch {
debugPrint("Couldn't get Data from URL")
}
}, to: url!, method: .post, headers: header ).responseJSON(completionHandler: { (res) in
print("This is the result", res.result)
switch res.result {
case .failure(let err):
if let code = err.responseCode{
print("unable to upload the image and create a post ",code)
break
}
case .success(let sucess):
self.dismiss(animated: false, completion: nil)
}
})
