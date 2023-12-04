//
//  VideoPlayerView.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import Foundation
import UIKit
import AVFoundation
import AutolayoutDSL

public class VideoPlayerView: UIView {
    
    private var videoPlayerHeight: NSLayoutConstraint?
    private weak var containerView: UIView?
    private weak var containerViewController: UIViewController?
    private weak var fullScreenContainerViewController: UIViewController?
    internal var videoAspectRatio: Double?
    internal lazy var videoPlayerManager = CompleteVideoPlayerManager()
    private var loadingView: UIView?
    
    internal lazy var videoPlayer: SimpleVideoPlayerView = {
        let view = SimpleVideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal lazy var interfaceView: VideoInterfaceView = {
        let view = VideoInterfaceView(config: config, videoProgressDelegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    public let config: VideoPlayerConfig
    
    private var inactivityTimer: Timer?
    private var inFullScreen: Bool = false
    
    public init(config: VideoPlayerConfig) {
        self.config = config
        super.init(frame: .zero)
        videoPlayerManager.completeDelegate = self
        videoPlayerManager.delegate = self
        videoPlayerManager.setup(BaseVideoPlayerConfig(config.url,
                                                       view: videoPlayer,
                                                       startAutoPlay: config.startAutoPlay,
                                                       repeatAfterEnd: config.repeatAfterEnd))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureIn(_ view: UIView, viewController: UIViewController) {
        self.containerView = view
        self.containerViewController = viewController
        configureView()
        configureTapGestures()
    }
    
    public func pause() {
        if !inFullScreen {
            videoPlayerManager.pause()
        }
    }
}

private extension VideoPlayerView {
    func configureView() {
        guard let containerView = self.containerView else { return }
        self.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        videoPlayerHeight = self.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.75)
        videoPlayerHeight?.isActive = true
        addSubview(videoPlayer)
        videoPlayer.fill(self)
        videoPlayer.addSubview(interfaceView)
        interfaceView.fill(videoPlayer)
    }
    
    func configureTapGestures() {
        let showTap = TapGestureRecognizerWithAssociatedBool(target: self, action: #selector(showInterface(sender:)), value: true)
        let hideTap = TapGestureRecognizerWithAssociatedBool(target: self, action: #selector(hideInterface(sender:)), value: true)
        videoPlayer.addGestureRecognizer(showTap)
        interfaceView.addGestureRecognizer(hideTap)
    }
    
    func setFullScreenButtonIcon() {
        interfaceView.setFullScreen(inFullScreen)
    }
    
    func showInterface(animated: Bool = true, withInactivityTimer: Bool = true) {
        if withInactivityTimer {
            startHideInterfaceForInactivity(4.0)
        }
        guard animated else { return interfaceView.isHidden = false }
        interfaceView.alpha = 0
        interfaceView.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.interfaceView.alpha = 1
        }
    }
    
    func hideInterface(animated: Bool = true) {
        inactivityTimer?.invalidate()
        guard animated else { return interfaceView.isHidden = true }
        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in
            self?.interfaceView.alpha = 0
        },
                       completion: { [weak self] _ in
            self?.interfaceView.isHidden = true
        })
    }
    
    func startHideInterfaceForInactivity(_ time: Double = 0.5) {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: time,
                                               repeats: false,
                                               block: { [weak self] timer in
            self?.hideInterface(animated: true)
            timer.invalidate()
            self?.inactivityTimer?.invalidate()
            self?.inactivityTimer = nil
        })
    }
    
    func cancelInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    func returnToEmbedded() {
        self.fullScreenContainerViewController?.dismiss(animated: false) { [unowned self] in
            self.insertSubview(videoPlayer, at: 0)
            videoPlayer.fill(self)
            
        }
    }
}

extension VideoPlayerView: CompleteVideoPlayerManagerDelegate {
    func didUpdateVideoDuration(_ duration: Double) {
        interfaceView.setTotalTime(duration)
    }
    
    func showLoading(_ show: Bool) {
        self.isUserInteractionEnabled = !show
        if show {
            hideInterface(animated: false)
            let loadingView = config.customLoadingViewProvider?.loadingView() ?? LoadingView()
            addSubview(loadingView)
            loadingView.fill(self)
            self.loadingView = loadingView
        } else {
            loadingView?.removeFromSuperview()
            loadingView = nil
            showInterface(withInactivityTimer: false)
        }
    }
    
    func didUpdateVideoSize(_ size: CGSize) {
        let roundedAspectRatio = ceil((size.height / size.width) * 100) / 100
        guard let constraint = videoPlayerHeight,
              ceil((constraint.multiplier) * 100) / 100 != roundedAspectRatio else { return }
        NSLayoutConstraint.deactivate([constraint])
        setHeightAspectRatio(roundedAspectRatio)
    }
    
    func setHeightAspectRatio(_ aspectRatio: Double) {
        guard let containerView = self.containerView else { return }
        self.videoAspectRatio = aspectRatio
        videoPlayerHeight = self.heightAnchor.constraint(equalTo: containerView.widthAnchor,
                                                         multiplier: aspectRatio)
        videoPlayerHeight?.isActive = true
        UIView.animate(withDuration: 0.2) {
            containerView.layoutIfNeeded()
        }
    }
    
    func didUpdateVideoStatus(_ status: AVPlayer.TimeControlStatus) {
        interfaceView.updateInterfaceWith(status)
    }
}

extension VideoPlayerView: BaseVideoPlayerManagerDelegate {
    func readyToPlay() {
        videoPlayerManager.pause()
    }
    
    func downloadedProgress(progress: Double) {
        interfaceView.updateLoadedProgress(progress)
    }
    
    func didUpdateProgress(progress: Double) {
        interfaceView.updateCurrentProgress(progress)
    }
    
    func didFinishPlayItem() { }
    
    func didFailPlayToEnd() { }
    
    func didFail(error: Error?) { }
}

extension VideoPlayerView: VideoProgressViewDelegate {
    func updateCurrentProgress(_ progress: Double) {
        cancelInactivityTimer()
        videoPlayerManager.updateCurrentProgress(progress)
    }
    
    func endSliding() {
        startHideInterfaceForInactivity(4.0)
    }
}

extension VideoPlayerView: VideoInterfaceViewDelegate {
    func playVideo() {
        videoPlayerManager.play()
        startHideInterfaceForInactivity(3.0)
    }
    
    func pauseVideo() {
        videoPlayerManager.pause()
    }
    
    func backVideo() {
        videoPlayerManager.back10Sec()
        startHideInterfaceForInactivity(6.0)
    }
    
    func forthVideo() {
        videoPlayerManager.forth10Sec()
        startHideInterfaceForInactivity(6.0)
    }
    
    @objc func showInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        showInterface(animated: sender.value)
    }
    
    @objc func hideInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        hideInterface(animated: sender.value)
    }
    
    func goToFullScreen() {
        startHideInterfaceForInactivity(6.0)
        inFullScreen = !inFullScreen
        setFullScreenButtonIcon()
        if inFullScreen {
            if let viewController = containerViewController {
                let fullScreenVC = FullScreenVideoPlayerViewController(videoPlayer: self)
                self.fullScreenContainerViewController = fullScreenVC
                fullScreenVC.modalPresentationStyle = .fullScreen
                fullScreenVC.modalTransitionStyle = .crossDissolve
                viewController.present(fullScreenVC, animated: true)
            }
        } else {
            returnToEmbedded()
        }
    }
}

class TapGestureRecognizerWithAssociatedBool: UITapGestureRecognizer {
    let value: Bool
    
    init(target: Any?, action: Selector?, value: Bool) {
        self.value = value
        super.init(target: target, action: action)
    }
}