//
//  ViewStoriesCollectionCell.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 03/10/23.
//

import UIKit

protocol ViewStoriesBtnClicks {
    func likeButtonClick (indexPath :IndexPath, post : StoriesData)
    func seekToLeftRight (indexPath : IndexPath,seekType : SeekType)
}

enum SeekType {
    case right
    case left
}

class ViewStoriesCollectionCell: UICollectionViewCell {
    
    @IBOutlet var leftView: UIView! {
        didSet {
            leftView.isUserInteractionEnabled = true
            leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftClickPrevious)))
        }
    }
    @objc func leftClickPrevious () {
        debugPrint(clickType: .left)
        if currentImageIndex == 0 {
            delegate?.seekToLeftRight(indexPath: indexPath!, seekType: .left)
        } else {
            currentImageIndex -= 1
        }
        if post.storyImage.count > 0 {
            storyImageView.image = post.storyImage[currentImageIndex]
        }
        
    }
    @IBOutlet var rightView: UIView! {
        didSet {
            rightView.isUserInteractionEnabled = true
            rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightClickNext)))
        }
    }
    @objc func rightClickNext () {
        debugPrint(clickType: .right)
        if currentImageIndex == post.storyImage.count - 1 {
            delegate?.seekToLeftRight(indexPath: indexPath!, seekType: .right)
        } else {
            currentImageIndex += 1
        }
        if post.storyImage.count > 0 {
            storyImageView.image = post.storyImage[currentImageIndex]
        }
        
    }
    @IBOutlet var storyImageView: UIImageView!  {
        didSet {
            storyImageView.isUserInteractionEnabled = true
            storyImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleImageViewLongPress(sender: ))))
        }
    }
    
    @objc func handleImageViewLongPress (sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            UIView.animate(withDuration: 0.1) {
                self.topView.layer.opacity = 0
                self.bottomView.layer.opacity = 0
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.1) {
                self.topView.layer.opacity = 1
                self.bottomView.layer.opacity = 1
            }
        }
    }
    
    
    @IBOutlet var moreBtn: UIImageView! {
        didSet {
            moreBtn.isUserInteractionEnabled = true
            moreBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreImageViewTap)))
        }
    }
    @objc func moreImageViewTap () {
        let alertController = UIAlertController(title: "Action Sheet", message: "What would you like to do?", preferredStyle: .actionSheet)

           let sendButton = UIAlertAction(title: "Send now", style: .default, handler: { (action) -> Void in
               print("Ok button tapped")
           })

           let  deleteButton = UIAlertAction(title: "Delete forever", style: .destructive, handler: { (action) -> Void in
               print("Delete button tapped")
           })

           let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
               print("Cancel button tapped")
           })


           alertController.addAction(sendButton)
           alertController.addAction(deleteButton)
           alertController.addAction(cancelButton)

        
        destinationVC?.present(alertController, animated: true)
    }
    
    @IBOutlet var profileImageVIew: UIImageView!
    
    @IBOutlet var sendMessageTfield: UITextField!
    
    @IBOutlet var locationLbl: UILabel!
    
    @IBOutlet var userNameLbl: UILabel!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var shareBtn: UIButton!
    
    @IBOutlet var topView: UIView!
    
    
    @IBOutlet var bottomView: UIView!
    
    var post : StoriesData!
    var indexPath : IndexPath?
    var delegate : ViewStoriesBtnClicks?
    var currentImageIndex : Int = 0
    var timer = Timer()
    var destinationVC : ViewStoriesVC?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sendMessageTfield.layoutIfNeeded()
        sendMessageTfield.layer.cornerRadius = sendMessageTfield.frame.size.height / 2
        sendMessageTfield.layer.borderWidth = 1.0
        sendMessageTfield.layer.borderColor = UIColor.white.cgColor
        sendMessageTfield.attributedPlaceholder = NSAttributedString(string: "Send message", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        let leftSpaceView = UIView()
        leftSpaceView.frame = CGRect(x: 0, y: 0, width: 10, height: sendMessageTfield.frame.size.height)
        sendMessageTfield.leftView = leftSpaceView
        sendMessageTfield.leftViewMode = .always
        storyImageView.layer.cornerRadius = 7.0
        //        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(rightClickNext), userInfo: nil, repeats: true)
        
    }
    
    override func prepareForReuse() {
        print(#function)
        currentImageIndex = 0
    }
    
    func debugPrint (clickType : SeekType) {
        switch clickType {
        case .right:
            print("++++++++ Right Click ++++++++")
        case .left:
            print("++++++++ Left Click ++++++++")
        }
        print("------Current in cell Button-------")
        print("Current IndexPath : \(indexPath!)")
        print("Previous IndexPath : \(indexPath!.preViousindex)")
        print("Next IndexPath : \(indexPath!.nextIndex)")
        print("Current image index \(currentImageIndex)")
    }
    
    @IBAction func likeBtnClick(_ sender: Any) {
        post.isStoryLiked.toggle()
        if post.isStoryLiked {
            likeButton.animateWith(namedImage: "liked",transFormScale: 1.3)
        } else {
            likeButton.setImage(UIImage(named: "loveD"), for: .normal)
        }
        delegate?.likeButtonClick(indexPath: indexPath!, post: post)
        
    }
    
    func setUpCell () {
        userNameLbl.text = post.storyProfileName
        profileImageVIew.image = post.profilePicture
        if post.storyImage.count > 0 {
            storyImageView.image = post.storyImage[currentImageIndex]
        }
        profileImageVIew.layoutIfNeeded()
        profileImageVIew.layer.cornerRadius = profileImageVIew.frame.size.width / 2
        post.isStoryLiked ? likeButton.setImage(UIImage(named: "liked"), for: .normal) : likeButton.setImage(UIImage(named: "loveD"), for: .normal)
        if post.isMusicOrLocationAvailable {
            locationLbl.isHidden = false
            locationLbl.text = post.musicOrLocation
        } else {
            locationLbl.isHidden = true
        }
    }
    
}


