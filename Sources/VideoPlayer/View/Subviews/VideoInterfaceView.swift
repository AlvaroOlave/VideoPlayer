//
//  VideoInterfaceView.swift
//  
//
//  Created by Álvaro Olave Bañeres on 28/11/23.
//

import UIKit
import AutolayoutDSL
import AVFoundation

protocol VideoInterfaceViewDelegate: AnyObject {
    func playVideo()
    func pauseVideo()
    func backVideo()
    func forthVideo()
    func showInterface(sender: TapGestureRecognizerWithAssociatedBool)
    func hideInterface(sender: TapGestureRecognizerWithAssociatedBool)
    func goToFullScreen()
}

final class VideoInterfaceView: UIView {
    
    private lazy var mainActionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = config.playButton.tintColor
        button.setImage(config.playButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.addTarget(self,
                         action: #selector(playVideo),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.backButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.backButton.tintColor
        button.addTarget(self,
                         action: #selector(backVideo),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var forthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.forthButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.forthButton.tintColor
        button.addTarget(self,
                         action: #selector(forthVideo),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.fullScreenButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.fullScreenButton.tintColor
        button.addTarget(self,
                         action: #selector(goToFullScreen),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: VideoProgressView = {
        let view = VideoProgressView(config: config.progressBarConfig)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let config: VideoPlayerConfig
    
    weak var delegate: VideoInterfaceViewDelegate?
    
    public init(config: VideoPlayerConfig, videoProgressDelegate: VideoProgressViewDelegate?) {
        self.config = config
        super.init(frame: .zero)
        progressView.delegate = videoProgressDelegate
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFullScreen(_ fullScreen: Bool) {
        let icon = fullScreen ? config.embeddedButton.icon : config.fullScreenButton.icon
        fullScreenButton.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func setTotalTime(_ secs: Double) {
        progressView.setTotalTime(secs)
    }
    
    func updateCurrentProgress(_ progress: Double) {
        progressView.updateCurrentProgress(progress)
    }
    
    func updateLoadedProgress(_ progress: Double) {
        progressView.updateLoadedProgress(progress)
    }
    
    func updateInterfaceWith(_ videoStatus: AVPlayer.TimeControlStatus) {
        mainActionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        mainActionButton.setImage(mainActionIconWithPlayerStatus(videoStatus)?.withRenderingMode(.alwaysTemplate),
                                  for: .normal)
        mainActionButton.addTarget(self,
                                   action: mainActionSelectorWithPlayerStatus(videoStatus),
                                   for: .touchUpInside)
    }
}

private extension VideoInterfaceView {
    func setupView() {
        backgroundColor = config.interfaceBackgroundColor
        
        addSubview(mainActionButton)
        addSubview(backButton)
        addSubview(forthButton)
        addSubview(fullScreenButton)
        addSubview(progressView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        mainActionButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor
        }
        backButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.trailing == mainActionButton.leadingAnchor - 32.0
            $0.centerY == mainActionButton.centerYAnchor
        }
        forthButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.leading == mainActionButton.trailingAnchor + 32.0
            $0.centerY == mainActionButton.centerYAnchor
        }
        fullScreenButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.trailing == safeAreaLayoutGuide.trailingAnchor - 16.0
            $0.bottom == safeAreaLayoutGuide.bottomAnchor - 8.0
        }
        progressView.layout {
            $0.leading == safeAreaLayoutGuide.leadingAnchor + 16.0
            $0.trailing == fullScreenButton.leadingAnchor - 16.0
            $0.bottom == safeAreaLayoutGuide.bottomAnchor - 12.0
            $0.height == 40.0
        }
    }
    
    func mainActionIconWithPlayerStatus(_ status: AVPlayer.TimeControlStatus) -> UIImage? {
        switch status {
        case .paused:
            return config.playButton.icon
        case .waitingToPlayAtSpecifiedRate:
            return config.playButton.icon
        case .playing:
            return config.pauseButton.icon
        @unknown default:
            return config.playButton.icon
        }
    }
    
    func mainActionSelectorWithPlayerStatus(_ status: AVPlayer.TimeControlStatus) -> Selector {
        switch status {
        case .paused:
            return #selector(playVideo)
        case .waitingToPlayAtSpecifiedRate:
            return #selector(playVideo)
        case .playing:
            return #selector(pauseVideo)
        @unknown default:
            return #selector(playVideo)
        }
    }
    
    @objc func playVideo() {
        delegate?.playVideo()
    }
    
    @objc func pauseVideo() {
        delegate?.pauseVideo()
    }
    
    @objc func backVideo() {
        delegate?.backVideo()
    }
    
    @objc func forthVideo() {
        delegate?.forthVideo()
    }
    
    @objc func showInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        delegate?.showInterface(sender: sender)
    }
    
    @objc func hideInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        delegate?.hideInterface(sender: sender)
    }
    
    @objc func goToFullScreen() {
        delegate?.goToFullScreen()
    }
}

