//
//  CompleteVideoPlayerManager.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import UIKit
import AVFoundation

public protocol CompleteVideoPlayerManagerDelegate: AnyObject {
    func didUpdateVideoSize(_ size: CGSize)
    func didUpdateVideoDuration(_ duration: Double)
    func didUpdateVideoStatus(_ status: AVPlayer.TimeControlStatus)
    func showLoading(_ show: Bool)
}

public class CompleteVideoPlayerManager: BaseVideoPlayerManager {
    
    public weak var completeDelegate: CompleteVideoPlayerManagerDelegate?
    private var loadingView: LoadingView?
    
    override func prepareToPlay() {
        completeDelegate?.showLoading(true)
        super.prepareToPlay()
        pause()
    }
    
    public override func setup(_ model: BaseVideoPlayerConfig) {
        super.setup(model)
        if let playerLayer = playerView?.layer as? AVPlayerLayer {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        }
    }
    
    public override func cleanUp() {
        playerItem?.removeObserver(self, forKeyPath: "presentationSize")
        playerItem?.removeObserver(self, forKeyPath: "duration")
        assetPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
        super.cleanUp()
    }
    
    public func back10Sec() {
        if let currentTime = assetPlayer?.currentTime() {
            let resultTime  = CMTimeAdd(currentTime,
                                        CMTimeMakeWithSeconds(-10.0, preferredTimescale: 1))
            assetPlayer?.seek(to: resultTime)
        }
    }
    
    public func forth10Sec() {
        if let currentTime = assetPlayer?.currentTime(), let duration = playerItem?.duration {
            let resultTime  = CMTimeAdd(currentTime,
                                        CMTimeMakeWithSeconds(10.0, preferredTimescale: 1))
            guard resultTime < duration else { return }
            assetPlayer?.seek(to: resultTime)
        }
    }
    
    public func updateCurrentProgress(_ progress: Double) {
        if let duration = playerItem?.duration {
            let totalSecs = Double(CMTimeGetSeconds(duration))
            let currentTime = totalSecs * progress
            assetPlayer?.seek(to: CMTime(seconds: currentTime,
                                         preferredTimescale: 1))
        }
    }
    
    override func startLoading() {
        super.startLoading()
        guard let asset = urlAsset else { return }
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: nil)
        if status == AVKeyValueStatus.loaded {
            if let item = playerItem {
                item.addObserver(self, forKeyPath: "presentationSize", options: [.new], context: nil)
                item.addObserver(self, forKeyPath: "duration", options: [.new], context: nil)
                assetPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        if context == videoContext {
            if let key = keyPath {
                if key == "presentationSize", let videoSize = playerItem?.presentationSize {
                    completeDelegate?.didUpdateVideoSize(videoSize)
                } else if key == "status", assetPlayer?.status == .readyToPlay {
                    completeDelegate?.showLoading(false)
                } else if key == "timeControlStatus", let status = assetPlayer?.timeControlStatus {
                    completeDelegate?.didUpdateVideoStatus(status)
                } else if key == "duration", let duration = playerItem?.duration {
                    completeDelegate?.didUpdateVideoDuration(Double(CMTimeGetSeconds(duration)))
                }
            }
        }
    }
}
