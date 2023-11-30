//
//  InstagramFeedsVC.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 26/09/23.
//

import UIKit

class InstagramFeedsVC: UIViewController {
    
    @IBOutlet var feedsCollectionView: UICollectionView!
    var storiesList = [StoriesData]()
    var postsList = [PostDetails]()
    
    var finalHeight = 610.0
    var indexPath : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        if #available(iOS 16.0, *) {
            feedsCollectionView.collectionViewLayout = compositionalLayout()
        } else {
            // Fallback on earlier versions
        }
        fetchData()
        fetchStoryData()
    }
    func registerNibs () {
        feedsCollectionView.register(UINib(nibName: "StoriesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoriesCollectionViewCell")
        feedsCollectionView.register(UINib(nibName: "CollectionReusableViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionReusableViewHeader")
        feedsCollectionView.register(UINib(nibName: "PostsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostsCollectionViewCell")
        feedsCollectionView.register(UINib(nibName: "PostVideosCell", bundle: nil), forCellWithReuseIdentifier: "PostVideosCell")
    }
    
    func fetchData (){
        guard let fileLocation = Bundle.main.url(forResource: "PostsList", withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: fileLocation)
            let receivedData = try JSONDecoder().decode([PostDetails].self, from: data)
            self.postsList = receivedData
            
        } catch {
            print(error.localizedDescription)
        }
    }
    func fetchStoryData (){
        guard let fileLocation = Bundle.main.url(forResource: "StoriesList", withExtension: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: fileLocation)
            let receivedData = try JSONDecoder().decode([StoriesData].self, from: data)
            self.storiesList = receivedData
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension InstagramFeedsVC : UICollectionViewDelegate, UICollectionViewDataSource  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return storiesList.count
        } else if section == 1 {
            return postsList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = feedsCollectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCollectionViewCell", for: indexPath) as! StoriesCollectionViewCell
            let story = storiesList[indexPath.row]
            cell.prepareCellUI(story: story)
            return cell
        } else if indexPath.section == 1 {
            let cell = feedsCollectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
            self.indexPath = indexPath
            let post = postsList[indexPath.row]
            cell.post = post
            cell.delegate = self
            cell.indexPath = indexPath
            cell.postImages = post.postImage
            cell.prepareCellUI()
            if post.isCaptionExtended {
                cell.captionLabelHeightEvent()
            } else {
                cell.captionLabel.numberOfLines = 2
                feedsCollectionView.performBatchUpdates {
                    feedsCollectionView.collectionViewLayout.invalidateLayout()
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    //Creating a header for collectionView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionReusableViewHeader", for: indexPath) as! CollectionReusableViewHeader
            return header
        default:
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 && (storiesList[0].storyImage.count == 0) {
                if let pageViewController = self.parent as? PageViewController {
                    pageViewController.setViewControllers([pageViewController.viewControllersList[0]], direction: .reverse, animated: true, completion: nil)
                }
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC = storyBoard.instantiateViewController(withIdentifier: "ViewStoriesVC") as! ViewStoriesVC
                destinationVC.indexPathToScroll = indexPath
                destinationVC.storiesList = self.storiesList
                self.present(destinationVC, animated: true)
            }
        }
    }
}
//MARK: - Compostitional Layout Method:-
@available(iOS 16.0, *)
extension InstagramFeedsVC {
    //Function for creating Compositional layout for collectionView
    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout.init { [self] sectionIndex,_  in
            ///Different custom sections design for different sections of collectionView
            switch sectionIndex {
            case 0 :
                /// creating an item
                /// creating a group using that item
                /// creating section using that group
                let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 0)
                let group = CompositionalLayout.createGroup(width: .absolute(80), height: .absolute(100), groupType: .horizontal, items: [item])
                let section = NSCollectionLayoutSection(group: group)
                ///setting the inter item spacings
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 0, leading: 15, bottom: 10, trailing: 10)
                ///setting the scroll direction of the current section of collectionView
                section.orthogonalScrollingBehavior = .continuous
                ///setting  the headerview for the current section
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                section.supplementaryContentInsetsReference = UIContentInsetsReference.none
                
                return section
            case 1 :
                let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 0)
                var groupHeight: NSCollectionLayoutDimension = .absolute(610.0)
                if indexPath != nil {
                    groupHeight = postsList[indexPath!.row].isCaptionExtended ? .estimated(finalHeight) : .absolute(610.0)
                }
                let group = CompositionalLayout.createGroup(width: .fractionalWidth(1), height: groupHeight, groupType: .vertical, items: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 10, trailing: 0)
                return section
            default:
                return nil
            }
        }
    }
    
    //Method used to set the header view
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
}

extension InstagramFeedsVC : PostsButtonClicks {
    func addTOCollectionButtonClick(indexPath: IndexPath, post: PostDetails) {
        postsList[indexPath.row].isInCollection = post.isInCollection
    }
    func likeButttonClick(indexPath: IndexPath, post: PostDetails) {
        postsList[indexPath.row].isLIkedPost = post.isLIkedPost
        postsList[indexPath.row].totalLikesCount = post.totalLikesCount
    }
    func captionLabeLSizeIncrease(indexPath: IndexPath, height: CGFloat) {
        self.indexPath = indexPath
        finalHeight = height
        postsList[indexPath.row].isCaptionExtended = true
        feedsCollectionView.performBatchUpdates {
            feedsCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    func doubleTapLike(indexPath: IndexPath, post: PostDetails) {
        postsList[indexPath.row].isLIkedPost = post.isLIkedPost
        postsList[indexPath.row].totalLikesCount = post.totalLikesCount
    }
}

extension InstagramFeedsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 80.0, height: 100)
        } else {
            return CGSize(width: collectionView.frame.self.width, height: 610.0)
        }
    }
}
extension InstagramFeedsVC {
    func addMyStory (storyImage : UIImage, isCloseFriedStory : Bool) {
        storiesList[0].storyImage.append(storyImage)
        storiesList[0].isNotMyStory = true
        storiesList[0].isClosedFriendStory = isCloseFriedStory
        feedsCollectionView.reloadSections([0])
    }
}
