//
//  THVideoContentView.swift
//  THContentMarkerView
//
//  Created by Seong ho Hong on 2018. 2. 18..
//  Copyright © 2018년 Seong ho Hong. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum PlayStatus: Int {
    case play = 0
    case pause
}

enum VideoStatus: Int {
    case show = 0
    case hide
}

public class THVideoContentView: THContentView {
    private var videoTapGestureRecognizer = UITapGestureRecognizer()
    private var videoPanGestureRecognizer = UIPanGestureRecognizer()
    var player =  AVPlayer()
    var playerLayer = AVPlayerLayer()
    var playStatus = PlayStatus.pause
    var videoStatus = VideoStatus.show
    var fullscreenButton = UIButton()
    var videoButton = UIButton()
    var topVC = UIApplication.shared.keyWindow?.rootViewController
    var initialFrame = CGRect()
    var youtubeView = UIWebView()
    var isYoutube = false

    func playVideo() {
        playStatus = .play
        videoButton.setImage(UIImage(named: "pauseBtn.png"), for: .normal)
        player.automaticallyWaitsToMinimizeStalling = false
        player.playImmediately(atRate: 1.0)
        hideStatus()
    }

    func pauseVideo() {
        playStatus = .pause
        videoButton.setImage(UIImage(named: "playBtn.png"), for: .normal)
        player.pause()
    }

    func hideStatus() {
        fullscreenButton.isHidden = true
        videoButton.isHidden = true
        videoStatus = .show
    }

    func showStatus() {
        fullscreenButton.isHidden = false
        videoButton.isHidden = false
        videoStatus = .hide
    }

    @objc func pressVideoButton(_ sender: UIButton!) {
        if playStatus == .pause {
            playVideo()
        } else {
            pauseVideo()
        }
    }

    @objc func pressfullscreenButton(_ sender: UIButton!) {
        let playerViewController = AVPlayerViewController()
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.player = player
        self.parentViewController?.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }

    public func setContentView(frame: CGRect) {
        delegate = self
        initialFrame = frame
        self.frame = frame
        self.backgroundColor = UIColor.black
        videoTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoViewTap(_:)))
        videoPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(videoViewPan(_:)))
        videoPanGestureRecognizer.delegate = self

        self.addGestureRecognizer(videoTapGestureRecognizer)
        self.addGestureRecognizer(videoPanGestureRecognizer)

        // 전체화면 버튼 세팅
        fullscreenButton.frame = CGRect(x: self.frame.width - 30, y: self.frame.height - 30, width: 20, height: 20)
        fullscreenButton.layer.cornerRadius = 3
        fullscreenButton.layer.opacity = 0.5
        fullscreenButton.setImage(UIImage(named: "enlarge.png"), for: .normal)
        fullscreenButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        fullscreenButton.addTarget(self, action: #selector(pressfullscreenButton(_ :)), for: .touchUpInside)

        // 플레이 버튼 세팅
        videoButton.frame = CGRect(x: self.frame.width/2 - 25, y: self.frame.height/2 - 25, width: 50, height: 50)
        videoButton.layer.cornerRadius = 3
        videoButton.layer.opacity = 0.5
        videoButton.setImage(UIImage(named: "playBtn.png"), for: .normal)
        videoButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        videoButton.addTarget(self, action: #selector(pressVideoButton(_ :)), for: .touchUpInside)
    }
}

extension THVideoContentView: THContentViewDelegate {
    public func setContent(info: Any?) {
        if let url = info as? URL {
            var path = url.absoluteString
            if path.contains("https://www.youtube.com/watch?v=") {
                path = path.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "https://www.youtube.com/embed/")
                if path.contains("&") {
                    let index = path.index(of: "&")!
                    path = path[..<index].description
                }
                let youtubeURL = URL(string: path)
                youtubeView.frame = self.bounds
                youtubeView.isOpaque = false
                youtubeView.backgroundColor = UIColor.black
                self.youtubeView.loadRequest(URLRequest(url: youtubeURL!))
                self.addSubview(youtubeView)
                isYoutube = true
            } else if path.contains("https://www.youtube.com/embed/") {
                youtubeView.frame = self.bounds
                youtubeView.isOpaque = false
                youtubeView.backgroundColor = UIColor.black
                youtubeView.loadRequest(URLRequest(url: url))
                self.addSubview(youtubeView)
                isYoutube = true
            } else {
                player = AVPlayer(url: url)
                player.allowsExternalPlayback = false
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.bounds
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                self.layer.addSublayer(playerLayer)
                self.addSubview(fullscreenButton)
                self.addSubview(videoButton)
                isYoutube = false
            }
        }
    }

    public func dismiss() {
        self.frame = initialFrame
        if youtubeView.isLoading {
            youtubeView.stopLoading()
        }
        if isYoutube {
            youtubeView = UIWebView()
        } else {
            pauseVideo()
            showStatus()
            self.playerLayer.removeFromSuperlayer()
        }
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
    }
}

extension THVideoContentView: UIGestureRecognizerDelegate {
    @objc func videoViewTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if videoStatus == .show {
            showStatus()
        } else {
            hideStatus()
        }
    }

    @objc func videoViewPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)

        if abs(translation.x) > abs(translation.y) { // Horizontal pan
            let changedX = self.center.x + translation.x
            if changedX >= (self.superview?.frame.width)!/2 {
                self.center = CGPoint(x: changedX, y: self.center.y)
            }
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        }

        if gestureRecognizer.state == .ended {
            if self.center.x >= (self.superview?.frame.width)!/2 + (self.superview?.frame.width)!/4 {
                self.center = CGPoint(x: (self.superview?.frame.width)! + self.frame.width/3, y: self.center.y)
            } else {
                self.center = CGPoint(x: (self.superview?.frame.width)!/2, y: self.center.y)
            }
        }
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
