//
//  StoriesCollectionViewCell.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 26/09/23.
//

import UIKit

class StoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet var superViewImage: UIView! 
    @IBOutlet var storyImageView: UIImageView!
    @IBOutlet var storyUserId : UILabel!
    
    @IBOutlet var storiesPlusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func prepareCellUI (story : StoriesData) {
        
        storiesPlusIcon.isHidden = story.isNotMyStory
        storyImageView.image = story.profilePicture
        story.isClosedFriendStory ? setUpImageView(color: .systemGreen) : setUpImageView(color: .systemYellow)
        storyUserId.text = story.storyProfileName
    }
    func setUpImageView(color: UIColor ) {
        superViewImage.makeCircularView(with: color, boarder: 1.7)
        storyImageView.makeCircularImage(with: UIColor.systemBackground, boarder: 5)
        storiesPlusIcon.makeCircularImage(with:  UIColor.systemBackground, boarder: 2)
        if storiesPlusIcon.isHidden == false {
            superViewImage.layer.borderColor = UIColor.systemGray2.cgColor
            storyImageView.contentMode = UIView.ContentMode.scaleAspectFit
            storyImageView.layer.borderWidth = 1
        }
    }
}
