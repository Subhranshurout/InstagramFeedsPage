//
//  multilePostsCell.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 04/10/23.
//

import UIKit
import AVFoundation

protocol MultiPostLike {
    func doubleTapLike ()
}

class multiplePostsCell: UICollectionViewCell {

    @IBOutlet var postImageView: UIImageView!
    
    
    @IBOutlet var videoPlayerView: UIView! {
        didSet {
            videoPlayerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSubViewsEvent)))
        }
    }
    
    @objc func hideSubViewsEvent () {
        isViewsHidden.toggle()
        UIView.animate(withDuration: 0.5) {
            self.playPauseImageView.layer.opacity = self.isViewsHidden ? 0 : 1
            self.muteImageView.layer.opacity = self.isViewsHidden ? 0 : 1
        }
    }
    
    @IBOutlet var playPauseImageView: UIImageView! {
        didSet {
            playPauseImageView.isUserInteractionEnabled = true
            playPauseImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playPauseEvent)))
        }
    }
    @objc func playPauseEvent () {
        if player?.timeControlStatus == .playing {
            playPauseImageView.image = UIImage(systemName: "play.fill")
            player?.pause()
        } else {
            playPauseImageView.image = UIImage(systemName: "pause.fill")
            player?.play()
        }
    }
    
    @IBOutlet var muteImageView: UIImageView! {
        didSet {
            muteImageView.isUserInteractionEnabled = true
            muteImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(muteUnmuteImageViewEvent)))
        }
    }
    
    @objc func muteUnmuteImageViewEvent () {
        if player!.volume > 0 {
            player?.volume = 0
            muteImageView.image = UIImage(systemName: "speaker.slash.fill")
        } else {
            player?.volume = 1
            muteImageView.image = UIImage(systemName: "speaker.wave.2.fill")
        }
    }
    
    @IBOutlet var likeHeartImage: UIImageView!
    
    var delegates : MultiPostLike?
    
    var isViewsHidden = true
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handlePostDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTap)
        let doubleTap2 = UITapGestureRecognizer(target: self, action: #selector(handlePostDoubleTap))
        doubleTap2.numberOfTapsRequired = 2
        videoPlayerView.addGestureRecognizer(doubleTap2)
        
        setUpMuteSwitch()
    }
    
    func setUpMuteSwitch () {
        muteImageView.makeCircularView()
        muteImageView.layer.opacity = 0
        playPauseImageView.layer.opacity = 0
    }
    
    @objc func handlePostDoubleTap () {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: { [self]() -> Void in
            likeHeartImage.isHidden = false
            likeHeartImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            likeHeartImage.alpha = 1.0
            delegates?.doubleTapLike()
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { [self]() -> Void in
                likeHeartImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: { [self]() -> Void in
                    likeHeartImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    likeHeartImage.alpha = 0.0
                }, completion: { [self](_ finished: Bool) -> Void in
                    likeHeartImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    
                })
            })
        })
    }

    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        print(#function)
        /// reseting the cell's state
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        muteImageView.image = UIImage(systemName: "speaker.wave.2.fill")
        playPauseImageView.image = UIImage(systemName: "play.fill")
    }
    
    func configure(with videoURL: String) {
        if let videoURL = Bundle.main.url(forResource: videoURL, withExtension: ".mp4") {
            let playerItem = AVPlayerItem(url: videoURL)
            player = AVPlayer(playerItem: playerItem)
            
            /// Create a separate AVPlayerLayer in your view controller
            DispatchQueue.main.async {
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.frame = self.videoPlayerView.bounds
                self.playerLayer?.videoGravity = .resizeAspectFill
                self.videoPlayerView.layer.addSublayer(self.playerLayer!)
                self.layoutSubviews()
                self.videoPlayerView.addSubview(self.playPauseImageView)
                self.videoPlayerView.addSubview(self.muteImageView)
            }
        } else {
            print("Video URL is nil")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
    }
    @objc func videoDidReachEnd() {
        // Seek the video back to the beginning when it ends
        player?.seek(to: CMTime.zero)
        player?.play()
    }
}
