//
//  StoryPreviewVC.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 30/10/23.
//

import UIKit

protocol NewStory {
    func addStory (storyimage : UIImage,isCloseFriedStory : Bool)
}

class StoryPreviewVC: UIViewController {
    
    @IBOutlet var storyPreviewImageView: UIImageView!
    
    @IBOutlet var yourStoryImage : UIImageView!
    
    @IBOutlet var closeFriendImage : UIImageView!
    
    @IBOutlet var yourStoryLbl : UILabel!
    
    @IBOutlet var closeFriendsLbl : UILabel!
    
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet var nextBtn: UIButton!
    
    @IBOutlet var yourStoryView: UIView! {
        didSet {
            yourStoryView.isUserInteractionEnabled = true
            yourStoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addToYourStory)))
        }
    }
    @objc func addToYourStory() {
        self.dismiss(animated: true)
        delegate?.addStory(storyimage: storyImage, isCloseFriedStory: false)
        
//        navigationController?.popViewController(animated: true)
        
        
    }
    @IBOutlet var closedFriendView: UIView! {
        didSet {
            closedFriendView.isUserInteractionEnabled = true
            closedFriendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addToCloseFriendStory)))
        }
    }
    @objc func addToCloseFriendStory() {
        self.dismiss(animated: true)
        delegate?.addStory(storyimage: storyImage, isCloseFriedStory: true)
        
//        navigationController?.popViewController(animated: true)
    }
    
    var storyImage : UIImage!
    var delegate : NewStory?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.isModalInPresentation = true
        prePareUI()
    }
    
    func prePareUI() {
        yourStoryView.layer.layoutIfNeeded()
        yourStoryView.layer.cornerRadius = yourStoryView.frame.size.height / 2
        closedFriendView.layer.layoutIfNeeded()
        closedFriendView.layer.cornerRadius = yourStoryView.frame.size.height / 2
        yourStoryImage.makeCircularImage()
        closeFriendImage.makeCircularImage()
        backBtn.makeCircularViewBtn()
        nextBtn.makeCircularViewBtn()
        storyPreviewImageView.image = storyImage
        storyPreviewImageView.layoutIfNeeded()
        storyPreviewImageView.layer.cornerRadius = 8.0
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let addStory = UIAlertAction(title: "Add to story", style: .default, handler: { (action) -> Void in
            self.addToYourStory()
        })
        let  closedFriend = UIAlertAction(title: "Closed Friends", style: .default, handler: { (action) -> Void in
            self.addToCloseFriendStory()
        })
        let  message = UIAlertAction(title: "Send message", style: .default, handler: { (action) -> Void in
            print("Send Message")
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        alertController.addAction(addStory)
        alertController.addAction(closedFriend)
        alertController.addAction(message)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
    
}
