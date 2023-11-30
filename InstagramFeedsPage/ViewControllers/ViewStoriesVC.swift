//
//  ViewStoriesVC.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 29/09/23.
//

import UIKit

class ViewStoriesVC: UIViewController {
    
    @IBOutlet var viewStoriesCollection: UICollectionView!
    
    var storiesList = [StoriesData]()
    var indexPathToScroll : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewStoriesCollection.register(UINib(nibName: "ViewStoriesCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ViewStoriesCollectionCell")
        if #available(iOS 16.0, *) {
            viewStoriesCollection.collectionViewLayout = compositionalLayout()
        } else {
            viewStoriesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        }
    }
    
    @available(iOS 16.0, *)
    func compositionalLayout () -> UICollectionViewCompositionalLayout {
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 0)
        let group = CompositionalLayout.createGroup(width: .fractionalWidth(1), height: .fractionalHeight(1), groupType: .horizontal, items: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return UICollectionViewCompositionalLayout(section: section)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewStoriesCollection.layoutSubviews()
        DispatchQueue.main.async {
            self.viewStoriesCollection.scrollToItem(at: self.indexPathToScroll!, at: .right, animated: false )
        }
    }
}
extension ViewStoriesVC: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storiesList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = viewStoriesCollection.dequeueReusableCell(withReuseIdentifier: "ViewStoriesCollectionCell", for: indexPath) as! ViewStoriesCollectionCell
        let post = storiesList[indexPath.row]
        cell.destinationVC = self
        cell.post = post
        cell.indexPath = indexPath
        cell.delegate = self
        cell.currentImageIndex = 0
        cell.setUpCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.8) {
            cell.alpha = 1
        }
    }
}

extension ViewStoriesVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}
extension ViewStoriesVC : ViewStoriesBtnClicks {
    func seekToLeftRight(indexPath: IndexPath, seekType: SeekType) {
        print("-------In ViewController-------")
        print("Current IndexPath : \(indexPath)")
        print("Previous IndexPath : \(indexPath.preViousindex)")
        print("Next IndexPath : \(indexPath.nextIndex)")
        switch seekType {
        case .right:
            if indexPath.nextIndex.row <= storiesList.count - 1 {
                DispatchQueue.main.async {
                    self.viewStoriesCollection.scrollToItem(at: indexPath.nextIndex, at: .right, animated: true)
                }
            } else {
                self.dismiss(animated: true)
            }
        case .left:
            if indexPath.preViousindex.row >= 0 && (storiesList[indexPath.preViousindex.row].storyImage.count > 0) {
                DispatchQueue.main.async {
                    self.viewStoriesCollection.scrollToItem(at: indexPath.preViousindex, at: .left, animated: true)
                }
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    func likeButtonClick(indexPath: IndexPath, post: StoriesData) {
        storiesList[indexPath.row].isStoryLiked = post.isStoryLiked
    }
}
