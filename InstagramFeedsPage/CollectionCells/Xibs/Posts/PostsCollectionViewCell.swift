//
//  PostsCollectionViewCell.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 26/09/23.
//

import UIKit
import AVFoundation

protocol PostsButtonClicks {
    func likeButttonClick (indexPath : IndexPath,post : PostDetails)
    func doubleTapLike (indexPath : IndexPath,post : PostDetails)
    func addTOCollectionButtonClick (indexPath : IndexPath,post : PostDetails)
    func captionLabeLSizeIncrease (indexPath : IndexPath,height : CGFloat)
}

class PostsCollectionViewCell: UICollectionViewCell , MultiPostLike{
    func doubleTapLike() {
        likeButton.animateWith(namedImage: "liked")
        if post.isLIkedPost {

        } else {
            post.isLIkedPost = true
            post.totalLikesCount += 1
        }
        totalLikesLabel.text = "\(post.totalLikesCount) likes"
        delegate?.doubleTapLike(indexPath: indexPath!, post: post)
    }
    
    @IBOutlet var superViewImage : UIView!
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var moreImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var totalLikesLabel: UILabel!
    
    @IBOutlet var captionLabel: UILabel! {
        didSet {
            captionLabel.isUserInteractionEnabled = true
            captionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(captionLabelHeightEvent)))
        }
    }
    
    
    @IBOutlet var multipleImagesCountLbl: UILabel!
    
    @objc func captionLabelHeightEvent() {
        let padding = 593.0
        let height = captionLabel.getLabelHeight + padding
        captionLabel.numberOfLines = 0
        delegate?.captionLabeLSizeIncrease(indexPath: indexPath!, height: height)
    }
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var multiplePostCollectionView: UICollectionView!
    @IBOutlet var commentButton: UIButton!
    
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var addToCollectionButton: UIButton!
    
    @IBOutlet var viewAllCommentsButton: UIButton!
    
    var delegate : PostsButtonClicks?
    var indexPath: IndexPath?
    var post : PostDetails!
    var currentVisibleCell : multiplePostsCell?
    var postImages : [String]!
    
    var isViewsHidden = true
    override func awakeFromNib() {
        super.awakeFromNib()
        multiplePostCollectionView.delegate = self
        multiplePostCollectionView.dataSource = self
        if #available(iOS 16.0, *) {
            multiplePostCollectionView.collectionViewLayout = compositionalLayout()
        } else {
            multiplePostCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        }
        multiplePostCollectionView.register(UINib(nibName: "multilePostsCell", bundle: nil), forCellWithReuseIdentifier: "multilePostsCell")
    }
    
    func prepareCellUI() {
        DispatchQueue.main.async {
            self.multiplePostCollectionView.reloadData()
            self.multipleImagesCountLbl.layer.masksToBounds = true
            self.multipleImagesCountLbl.layer.cornerRadius = self.multipleImagesCountLbl.frame.size.height / 2
            
            self.multipleImagesCountLbl.text = " 1/\(self.postImages.count) "
        }
        
        post.isLIkedPost ? likeButton.setImage(UIImage(named: "liked"), for: .normal) : likeButton.setImage(UIImage(named: "love"), for: .normal)
        post.isInCollection ? addToCollectionButton.setImage(UIImage(named: "ribbonFill"), for: .normal) : addToCollectionButton.setImage(UIImage(named: "saved"), for: .normal)
        if post.isCaptionExtended {
            captionLabel.numberOfLines = 0
        }
        profileImageView.image = UIImage(named: post.postProfilePicture)
        viewAllCommentsButton.setTitle("View all \(post.totalComments) Comments", for: .normal)
        setupImageView()
        userNameLabel.text = post.postUserId
        totalLikesLabel.text = "\(post.totalLikesCount) likes"
        captionLabel.text = "@\(post.postUserId) \(post.captionText)"
        self.layoutSubviews()
    }
    
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        post.isLIkedPost.toggle()
        if post.isLIkedPost {
            likeButton.animateWith(namedImage: "liked")
            post.totalLikesCount += 1
        } else {
            likeButton.setImage(UIImage(named: "love"), for: .normal)
            post.totalLikesCount -= 1
        }
        totalLikesLabel.text = "\(post.totalLikesCount) likes"
        delegate?.likeButttonClick(indexPath: indexPath!,post : post)
        
    }
    
    @IBAction func addToCollectionButtonClick (_ sender: UIButton) {
        post.isInCollection.toggle()
        post.isInCollection ? addToCollectionButton.animateWith(namedImage: "ribbonFill") : addToCollectionButton.setImage(UIImage(named: "saved"), for: .normal)
        delegate?.addTOCollectionButtonClick(indexPath: indexPath!, post: post)
    }
    
    func setupImageView () {
        superViewImage.makeCircularView(with: .systemGray2, boarder: 1)
        profileImageView.makeCircularImage(with: .clear, boarder: 2)
    }
}

@available(iOS 16.0, *)
extension PostsCollectionViewCell {
    func compositionalLayout () -> UICollectionViewCompositionalLayout {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 0)
        let group = CompositionalLayout.createGroup(width: .fractionalWidth(1), height: .fractionalHeight(1), groupType: .horizontal, items: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension PostsCollectionViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if post.isVideoPost! {
            return post.PostVideo.count
        } else {
            return postImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = multiplePostCollectionView.dequeueReusableCell(withReuseIdentifier: "multilePostsCell", for: indexPath) as! multiplePostsCell
        cell.delegates = self
        
        if post.isVideoPost! {
            cell.videoPlayerView.isHidden = false
            cell.configure(with: post.PostVideo[indexPath.row])
        } else {
            cell.videoPlayerView.isHidden = true
            cell.postImageView.image = UIImage(named: postImages[indexPath.row])
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("\(#function)  \(indexPath)")
        if post.isVideoPost! {
            let playerCell = multiplePostCollectionView.dequeueReusableCell(withReuseIdentifier: "multilePostsCell", for: indexPath) as! multiplePostsCell
            playerCell.player?.pause()
        }
        
        
    }
}

extension PostsCollectionViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}
