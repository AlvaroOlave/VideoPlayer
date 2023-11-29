//
//  CompletePlayerView.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import Foundation
import UIKit
import AVFoundation
import AutolayoutDSL

public class CompletePlayerView: UIView {
    
    private var videoPlayerHeight: NSLayoutConstraint?
    private weak var containerView: UIView?
    private weak var containerViewController: UIViewController?
    private weak var fullScreenContainerViewController: UIViewController?
    internal var videoAspectRatio: Double?
    internal lazy var videoPlayerManager = CompleteVideoPlayerManager()
    private var loadingView: LoadingView?
    
    internal lazy var videoPlayer: SimplePlayerView = {
        let view = SimplePlayerView()
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

private extension CompletePlayerView {
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
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension CompletePlayerView: CompleteVideoPlayerManagerDelegate {
    public func didUpdateVideoDuration(_ duration: Double) {
        interfaceView.setTotalTime(duration)
    }
    
    public func showLoading(_ show: Bool) {
        self.isUserInteractionEnabled = !show
        if show {
            hideInterface(animated: false)
            let loadingView = LoadingView()
            addSubview(loadingView)
            loadingView.fill(self)
            self.loadingView = loadingView
        } else {
            loadingView?.removeFromSuperview()
            loadingView = nil
            showInterface(withInactivityTimer: false)
        }
    }
    
    public func didUpdateVideoSize(_ size: CGSize) {
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
    
    public func didUpdateVideoStatus(_ status: AVPlayer.TimeControlStatus) {
        interfaceView.updateInterfaceWith(status)
    }
}

extension CompletePlayerView: BaseVideoPlayerManagerDelegate {
    public func readyToPlay() {
        videoPlayerManager.pause()
    }
    
    public func downloadedProgress(progress: Double) {
        interfaceView.updateLoadedProgress(progress)
    }
    
    public func didUpdateProgress(progress: Double) {
        interfaceView.updateCurrentProgress(progress)
    }
    
    public func didFinishPlayItem() { }
    
    public func didFailPlayToEnd() { }
    
    public func didFail(error: Error?) { }
}

extension CompletePlayerView: VideoProgressViewDelegate {
    func updateCurrentProgress(_ progress: Double) {
        cancelInactivityTimer()
        videoPlayerManager.updateCurrentProgress(progress)
    }
    
    func endSliding() {
        startHideInterfaceForInactivity(4.0)
    }
}

extension CompletePlayerView: VideoInterfaceViewDelegate {
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
                let fullScreenVC = CompletePlayerFullScreenViewController(videoPlayer: self)
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

public final class CompletePlayerFullScreenViewController: UIViewController {
    
    private let videoPlayer: CompletePlayerView
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.videoPlayer.videoAspectRatio ?? 0.0) > 1.0 ? .portrait : .landscapeRight
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (self.videoPlayer.videoAspectRatio ?? 0.0) > 1.0 ? .portrait : .landscapeRight
    }
    
    private lazy var backArrow: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(videoPlayer.config.fullScreenNavBackButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = videoPlayer.config.fullScreenNavBackButton.tintColor
        button.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = videoPlayer.config.titleColor
        return label
    }()
    
    init(videoPlayer: CompletePlayerView) {
        self.videoPlayer = videoPlayer
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        titleLabel.text = self.videoPlayer.config.videoTitle
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backArrow.removeFromSuperview()
        titleLabel.removeFromSuperview()
    }
    
    @objc private func backPressed() {
        videoPlayer.goToFullScreen()
    }
    
    private func setupView() {
        view.addSubview(videoPlayer.videoPlayer)
        view.backgroundColor = Colors.InterfaceBackground
        videoPlayer.videoPlayer.fill(view)
        videoPlayer.interfaceView.addSubview(backArrow)
        videoPlayer.interfaceView.addSubview(titleLabel)
        backArrow.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.top == videoPlayer.interfaceView.safeAreaLayoutGuide.topAnchor + 16.0
            $0.leading == videoPlayer.interfaceView.safeAreaLayoutGuide.leadingAnchor + 16.0
        }
        titleLabel.layout {
            $0.height == 20.0
            $0.centerY == backArrow.centerYAnchor
            $0.leading == backArrow.trailingAnchor + 16.0
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
