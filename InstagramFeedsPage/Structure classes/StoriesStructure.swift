//
//  StoriesStructure.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 26/09/23.
//

import Foundation
import UIKit

class StoriesData: Decodable {
    var profilePicture : UIImage
    var storyImage: [UIImage]
    var storyProfileName: String
    var isStoryLiked: Bool
    var isClosedFriendStory: Bool
    var isNotMyStory: Bool
    var isMusicOrLocationAvailable: Bool
    var musicOrLocation: String

    enum CodingKeys: String, CodingKey {
        case profilePicture
        case storyImage
        case storyProfileName
        case isStoryLiked
        case isClosedFriendStory
        case isNotMyStory
        case isMusicOrLocationAvailable
        case musicOrLocation
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let profilePick = try container.decode(String.self, forKey: .profilePicture)
        profilePicture = UIImage(named: profilePick)!
        let imageNames = try container.decode([String].self, forKey: .storyImage)
        storyImage = imageNames.map { name in
            if let image = UIImage(named: name) {
                return image
            } else {
                return UIImage()
            }
        }
        storyProfileName = try container.decode(String.self, forKey: .storyProfileName)
        isStoryLiked = try container.decode(Bool.self, forKey: .isStoryLiked)
        isClosedFriendStory = try container.decode(Bool.self, forKey: .isClosedFriendStory)
        isNotMyStory = try container.decode(Bool.self, forKey: .isNotMyStory)
        isMusicOrLocationAvailable = try container.decode(Bool.self, forKey: .isMusicOrLocationAvailable)
        musicOrLocation = try container.decode(String.self, forKey: .musicOrLocation)
    }
}
