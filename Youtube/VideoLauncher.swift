//
//  VideoLauncher.swift
//  youtube
//
//  Created by Brian Voong on 8/11/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .System)
        let image = UIImage(named: "pause")
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .whiteColor()
        button.hidden = true
        
        button.addTarget(self, action: #selector(handlePause), forControlEvents: .TouchUpInside)
        
        return button
    }()
    
    var isPlaying = false
    
    func handlePause() {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), forState: .Normal)
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
        
        isPlaying = !isPlaying
    }
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        return view
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .whiteColor()
        label.font = UIFont.boldSystemFontOfSize(13)
        label.textAlignment = .Right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .whiteColor()
        label.font = UIFont.boldSystemFontOfSize(13)
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .redColor()
        slider.maximumTrackTintColor = .whiteColor()
        slider.setThumbImage(UIImage(named: "thumb"), forState: .Normal)
        
        slider.addTarget(self, action: #selector(handleSliderChange), forControlEvents: .ValueChanged)
        
        return slider
    }()
    
    func handleSliderChange() {
        print(videoSlider.value)
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player?.seekToTime(seekTime, completionHandler: { (completedSeek) in
                //perhaps do something later here
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlayerView()
        
        setupGradientLayer()
        
        controlsContainerView.frame = frame
        addSubview(controlsContainerView)
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        pausePlayButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        pausePlayButton.widthAnchor.constraintEqualToConstant(50).active = true
        pausePlayButton.heightAnchor.constraintEqualToConstant(50).active = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: -8).active = true
        videoLengthLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -2).active = true
        videoLengthLabel.widthAnchor.constraintEqualToConstant(50).active = true
        videoLengthLabel.heightAnchor.constraintEqualToConstant(24).active = true
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 8).active = true
        currentTimeLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -2).active = true
        currentTimeLabel.widthAnchor.constraintEqualToConstant(50).active = true
        currentTimeLabel.heightAnchor.constraintEqualToConstant(24).active = true
        
        controlsContainerView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraintEqualToAnchor(videoLengthLabel.leftAnchor).active = true
        videoSlider.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        videoSlider.leftAnchor.constraintEqualToAnchor(currentTimeLabel.rightAnchor).active = true
        videoSlider.heightAnchor.constraintEqualToConstant(30).active = true
        
        backgroundColor = .blackColor()
    }
    
    var player: AVPlayer?
    
    private func setupPlayerView() {
        //warning: use your own video url here, the bandwidth for google firebase storage will run out as more and more people use this file
        let urlString = "https://firebasestorage.googleapis.com/v0/b/gameofchats-762ca.appspot.com/o/message_movies%2F12323439-9729-4941-BA07-2BAE970967C7.mov?alt=media&token=3e37a093-3bc8-410f-84d3-38332af9c726"
        if let url = NSURL(string: urlString) {
            player = AVPlayer(URL: url)
            
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .New, context: nil)
            
            //track player progress
            
            let interval = CMTime(value: 1, timescale: 2)
            player?.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue(), usingBlock: { (progressTime) in
                
                let seconds = CMTimeGetSeconds(progressTime)
                let secondsString = String(format: "%02d", Int(seconds % 60))
                let minutesString = String(format: "%02d", Int(seconds / 60))
                
                self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
                
                //lets move the slider thumb
                if let duration = self.player?.currentItem?.duration {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    
                    self.videoSlider.value = Float(seconds / durationSeconds)
                    
                }
                
            })
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clearColor()
            pausePlayButton.hidden = false
            isPlaying = true
            
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradientLayer.locations = [0.7, 1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoLauncher: NSObject {
    
    func showVideoPlayer() {
        print("Showing video player animation....")
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = UIColor.whiteColor()
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            //16 x 9 is the aspect ratio of all HD videos
            let height = keyWindow.frame.width * 9 / 16
            let videoPlayerFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            let videoPlayerView = VideoPlayerView(frame: videoPlayerFrame)
            view.addSubview(videoPlayerView)
            
            keyWindow.addSubview(view)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { 
                
                view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    //maybe we'll do something here later...
                    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            })
        }
    }
}
