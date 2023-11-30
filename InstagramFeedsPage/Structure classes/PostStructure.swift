//
//  PostStructure.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 26/09/23.
//

import Foundation
import UIKit

class PostDetails : Codable {
    var postUserId : String
    var postProfilePicture : String
    var isVideoPost : Bool?
    var postImage : [String]
    var PostVideo : [String]
    var isLIkedPost : Bool
    var isInCollection : Bool
    var totalLikesCount : Int
    var captionText : String
    var isCaptionExtended : Bool
    var totalComments : Int
    
//    enum CodingKeys : String, CodingKey {
//        case postUserId
//        case postProfilePicture
//        case isVideoPost
//        case postImage
//        case PostVideo
//        case isLIkedPost
//        case isInCollection
//        case totalLikesCount
//        case captionText
//        case isCaptionExtended
//        case totalComments
//    }
//    required init(from decoder : Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//    }

//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let profilePick = try container.decode(String.self, forKey: .profilePicture)
//        profilePicture = UIImage(named: profilePick)!
//        let imageNames = try container.decode([String].self, forKey: .storyImage)
//        storyImage = imageNames.map { name in
//            if let image = UIImage(named: name) {
//                return image
//            } else {
//                return UIImage()
//            }
//        }
//        storyProfileName = try container.decode(String.self, forKey: .storyProfileName)
//        isStoryLiked = try container.decode(Bool.self, forKey: .isStoryLiked)
//        isClosedFriendStory = try container.decode(Bool.self, forKey: .isClosedFriendStory)
//        isNotMyStory = try container.decode(Bool.self, forKey: .isNotMyStory)
//        isMusicOrLocationAvailable = try container.decode(Bool.self, forKey: .isMusicOrLocationAvailable)
//        musicOrLocation = try container.decode(String.self, forKey: .musicOrLocation)
//    }
    
}
