//
//  video.swift
//  CleanBucket
//
//  Created by Isaac Kim on 2/2/25.
//

// File: Models/Video.swift

import Foundation

// Model for each video object returned by the API
struct Video: Codable {
    let videoName: String
    let thumbnail: String  // Base64 encoded image string
    
    enum CodingKeys: String, CodingKey {
        case videoName = "video_name"
        case thumbnail
    }
}

// The response from the API is a dictionary, where the keys are video IDs
typealias VideosResponse = [String: Video]
