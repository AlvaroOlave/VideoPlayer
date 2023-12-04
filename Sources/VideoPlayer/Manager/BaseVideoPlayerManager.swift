//
//  BaseVideoPlayerManager.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import AVFoundation
import Foundation

protocol BaseVideoPlayerManagerDelegate: AnyObject {
    func downloadedProgress(progress:Double)
    func readyToPlay()
    func didUpdateProgress(progress:Double)
    func didFinishPlayItem()
    func didFailPlayToEnd()
    func didFail(error: Error?)
}

public let videoContext: UnsafeMutableRawPointer? = nil

public class BaseVideoPlayerManager : NSObject {
    
    // MARK: - Properties
    internal var assetPlayer: AVPlayer?
    internal var playerItem: AVPlayerItem?
    internal var urlAsset: AVURLAsset?
    private var videoOutput: AVPlayerItemVideoOutput?
    
    private var assetDuration: Double = 0.0
    internal weak var playerView: SimpleVideoPlayerView?
    
    private var autoRepeatPlay: Bool = true
    private var autoPlay: Bool = true
    
    weak var delegate: BaseVideoPlayerManagerDelegate?
    
    public var playerRate: Float = 1.0 {
        didSet {
            if let player = assetPlayer {
                player.rate = playerRate > 0 ? playerRate : 0.0
            }
        }
    }
    
    public var volume: Float = 1.0 {
        didSet {
            if let player = assetPlayer {
                player.volume = volume > 0 ? volume : 0.0
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    deinit {
        cleanUp()
    }
    
    // MARK: - Public
    
    public func isPlaying() -> Bool {
        if let player = assetPlayer {
            return player.rate > 0
        } else {
            return false
        }
    }
    
    public func seekToPosition(seconds:Float64) {
        if let player = assetPlayer {
            pause()
            if let timeScale = player.currentItem?.asset.duration.timescale {
                player.seek(to: CMTimeMakeWithSeconds(seconds,
                                                      preferredTimescale: timeScale),
                            completionHandler: { [weak self] _ in
                    self?.play()
                })
            }
        }
    }
    
    public func pause() {
        assetPlayer?.pause()
    }
    
    public func play() {
        if let player = assetPlayer, player.currentItem?.status == .readyToPlay {
            player.play()
            player.rate = playerRate
        }
    }
    
    public func cleanUp() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        NotificationCenter.default.removeObserver(self)
        assetPlayer = nil
        playerItem = nil
        urlAsset = nil
    }
    
    public func setup(_ model: BaseVideoPlayerConfig) {
        playerView = model.view
        autoPlay = model.startAutoPlay
        autoRepeatPlay = model.repeatAfterEnd
        
        if let playView = playerView, let playerLayer = playView.layer as? AVPlayerLayer {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        initialSetupWithURL(url: model.url)
        prepareToPlay()
    }
    
    // MARK: - Private
    
    internal func prepareToPlay() {
        let keys = ["tracks"]
        if let asset = urlAsset {
            asset.loadValuesAsynchronously(forKeys: keys, completionHandler: {
                DispatchQueue.main.async { [weak self] in
                    self?.startLoading()
                }
            })
        }
    }
    
    internal func startLoading() {
        var error: NSError?
        guard let asset = urlAsset else { return }
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        
        if status == AVKeyValueStatus.loaded {
            assetDuration = CMTimeGetSeconds(asset.duration)
            
            let videoOutputOptions = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
            videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputOptions)
            playerItem = AVPlayerItem(asset: asset)
            
            if let item = playerItem {
                item.addObserver(self, forKeyPath: "status", options: .initial, context: videoContext)
                item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: videoContext)
                NotificationCenter.default.removeObserver(self,
                                                          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: nil)
                NotificationCenter.default.removeObserver(self,
                                                          name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                                          object: nil)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerItemDidReachEnd(_:)),
                                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: item)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(didFailedToPlayToEnd(_:)),
                                                       name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                                       object: item)
                
                if let output = videoOutput {
                    item.add(output)
                    
                    item.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithm.varispeed
                    assetPlayer = AVPlayer(playerItem: item)
                    
                    if let player = assetPlayer {
                        player.rate = playerRate
                    }
                    
                    addPeriodicalObserver()
                    if let playView = playerView, let layer = playView.layer as? AVPlayerLayer {
                        layer.player = assetPlayer
                    }
                }
            }
        }
        else if status == AVKeyValueStatus.cancelled || status == AVKeyValueStatus.failed {
            delegate?.didFail(error: error)
        }
    }
    
    private func addPeriodicalObserver() {
        let timeInterval = CMTimeMake(value: 1, timescale: 1)
        
        if let player = assetPlayer {
            player.addPeriodicTimeObserver(forInterval: timeInterval,
                                           queue: DispatchQueue.main,
                                           using: { [weak self] (time) in
                self?.playerDidChangeTime(time: time)
            })
        }
    }
    
    private func playerDidChangeTime(time:CMTime) {
        if let player = assetPlayer {
            let timeNow = CMTimeGetSeconds(player.currentTime())
            let progress = timeNow / assetDuration
            
            delegate?.didUpdateProgress(progress: progress)
        }
    }
    
    @objc private func playerItemDidReachEnd(_ notification: NSNotification) {
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == self.playerItem else { return }
        delegate?.didFinishPlayItem()
        if let player = assetPlayer {
            player.seek(to: CMTime.zero)
            if autoRepeatPlay == true {
                play()
            }
        }
    }
    
    @objc private func didFailedToPlayToEnd(_ notification: NSNotification) {
        guard let playerItem = notification.object as? AVPlayerItem,
              playerItem == self.playerItem else { return }
        delegate?.didFailPlayToEnd()
    }
    
    private func playerDidChangeStatus(status:AVPlayer.Status) {
        if status == .failed {
            delegate?.didFail(error: nil)
        } else if status == .readyToPlay, let player = assetPlayer {
            volume = player.volume
            delegate?.readyToPlay()
            
            if autoPlay == true && player.rate == 0.0 {
                play()
            }
        }
    }
    
    private func moviewPlayerLoadedTimeRangeDidUpdated(ranges:Array<NSValue>) {
        var maximum:TimeInterval = 0
        for value in ranges {
            let range:CMTimeRange = value.timeRangeValue
            let currentLoadedTimeRange = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration)
            if currentLoadedTimeRange > maximum {
                maximum = currentLoadedTimeRange
            }
        }
        let progress:Double = assetDuration == 0 ? 0.0 : Double(maximum) / assetDuration
        
        delegate?.downloadedProgress(progress: progress)
    }
    
    private func initialSetupWithURL(url: URL) {
        urlAsset = AVURLAsset(url: url,
                              options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
    }
    
    // MARK: - Observations
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if context == videoContext {
            if let key = keyPath {
                if key == "status", let player = assetPlayer {
                    playerDidChangeStatus(status: player.status)
                } else if key == "loadedTimeRanges", let item = playerItem {
                    moviewPlayerLoadedTimeRangeDidUpdated(ranges: item.loadedTimeRanges)
                }
            }
        }
    }
}

extension BaseVideoPlayerManager: AVAssetResourceLoaderDelegate {}
