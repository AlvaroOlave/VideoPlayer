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

public class CompletePlayerView: SimplePlayerView {
    
    private var videoPlayerHeight: NSLayoutConstraint?
    private weak var containerView: UIView?
    private weak var containerViewController: UIViewController?
    private weak var containerStackView: UIStackView?
    private weak var fullScreenContainerViewController: UIViewController?
    internal var videoAspectRatio: Double?
    internal lazy var videoPlayer = CompleteVideoPlayerManager()
    private var loadingView: LoadingView?
    
    internal lazy var interfaceView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = config.interfaceBackgroundColor
        return view
    }()
    
    private lazy var mainActionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = config.playButton.tintColor
        return button
    }()
    
    private lazy var back10SecButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.backButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.backButton.tintColor
        button.addTarget(self,
                         action: #selector(backVideo10Sec),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var forth10SecButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.forthButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.forthButton.tintColor
        button.addTarget(self, action: #selector(forthVideo10Sec), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullScreenButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(config.fullScreenButton.icon?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = config.fullScreenButton.tintColor
        return button
    }()
    
    private lazy var progressView: VideoProgressView = {
        let view = VideoProgressView(config: config.progressBarConfig)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    public let config: VideoPlayerConfig
    
    private var inactivityTimer: Timer?
    private var inFullScreen: Bool = false
    
    public init(config: VideoPlayerConfig) {
        self.config = config
        super.init()
        videoPlayer.completeDelegate = self
        videoPlayer.delegate = self
        videoPlayer.setup(BaseVideoPlayerConfig(config.url,
                                                view: self,
                                                startAutoPlay: config.startAutoPlay,
                                                repeatAfterEnd: config.repeatAfterEnd))
    }
    
    public func configureIn(_ view: UIView, viewController: UIViewController) {
        self.containerView = view
        self.containerViewController = viewController
        configureView()
        configureInterface()
        configureTapGestures()
    }
    
    public func pause() {
        if !inFullScreen {
            videoPlayer.pause()
        }
    }
}

private extension CompletePlayerView {
    func configureView() {
        guard let containerView = self.containerView else { return }
        self.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        videoPlayerHeight = self.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.75)
        videoPlayerHeight?.isActive = true
        addSubview(interfaceView)
        interfaceView.fill(self)
    }
    
    func configureInterface() {
        interfaceView.addSubview(mainActionButton)
        interfaceView.addSubview(back10SecButton)
        interfaceView.addSubview(forth10SecButton)
        interfaceView.addSubview(fullScreenButton)
        interfaceView.addSubview(progressView)

        mainActionButton.setImage(config.playButton.icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        mainActionButton.addTarget(self,
                                   action: #selector(playVideo),
                                   for: .touchUpInside)
        mainActionButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.centerX == interfaceView.centerXAnchor
            $0.centerY == interfaceView.centerYAnchor
        }
        back10SecButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.trailing == mainActionButton.leadingAnchor - 32.0
            $0.centerY == mainActionButton.centerYAnchor
        }
        forth10SecButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.leading == mainActionButton.trailingAnchor + 32.0
            $0.centerY == mainActionButton.centerYAnchor
        }
        fullScreenButton.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.trailing == interfaceView.safeAreaLayoutGuide.trailingAnchor - 16.0
            $0.bottom == interfaceView.safeAreaLayoutGuide.bottomAnchor - 8.0
        }
        progressView.layout {
            $0.leading == interfaceView.safeAreaLayoutGuide.leadingAnchor + 16.0
            $0.trailing == fullScreenButton.leadingAnchor - 16.0
            $0.bottom == interfaceView.safeAreaLayoutGuide.bottomAnchor - 12.0
            $0.height == 40.0
        }
    }
    
    func configureTapGestures() {
        let showTap = TapGestureRecognizerWithAssociatedBool(target: self, action: #selector(showInterface(sender:)), value: true)
        let hideTap = TapGestureRecognizerWithAssociatedBool(target: self, action: #selector(hideInterface(sender:)), value: true)
        self.addGestureRecognizer(showTap)
        interfaceView.addGestureRecognizer(hideTap)
        fullScreenButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToFullScreen)))
    }
    
    func setFullScreenButtonIcon() {
        let icon = inFullScreen ? config.embeddedButton.icon : config.fullScreenButton.icon
        fullScreenButton.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @objc func playVideo() {
        videoPlayer.play()
        startHideInterfaceForInactivity(3.0)
    }
    
    @objc func pauseVideo() {
        videoPlayer.pause()
    }
    
    @objc func backVideo10Sec() {
        videoPlayer.back10Sec()
        startHideInterfaceForInactivity(6.0)
    }
    
    @objc func forthVideo10Sec() {
        videoPlayer.forth10Sec()
        startHideInterfaceForInactivity(6.0)
    }
    
    @objc func showInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        showInterface(animated: sender.value)
    }
    
    @objc func hideInterface(sender: TapGestureRecognizerWithAssociatedBool) {
        hideInterface(animated: sender.value)
    }
    
    @objc func goToFullScreen() {
        startHideInterfaceForInactivity(6.0)
        inFullScreen = !inFullScreen
        setFullScreenButtonIcon()
        if inFullScreen {
            if let viewController = containerViewController {
                createFake()
                let fullScreenVC = CompletePlayerFullScreenViewController(videoPlayer: self)
                self.fullScreenContainerViewController = fullScreenVC
                fullScreenVC.modalPresentationStyle = .fullScreen
                fullScreenVC.modalTransitionStyle = .crossDissolve
                viewController.present(fullScreenVC, animated: true)
            }
        } else {
            returnToPartialScreen()
        }
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
    
    func createFake() {
        if let container = self.superview as? UIStackView {
            let fakeView = UIView(frame: self.bounds)
            fakeView.translatesAutoresizingMaskIntoConstraints = false
            fakeView.backgroundColor = UIColor(named: "interfaceBackground")
            fakeView.accessibilityIdentifier = "fakeView"
            fakeView.layout {
                ($0.height & $0.width) == (self.frame.height * self.frame.width)
            }
            if let originIndex = container.arrangedSubviews.firstIndex(of: self) {
                self.containerStackView = container
                container.insertArrangedSubview(fakeView, at: originIndex)
                container.removeArrangedSubview(self)
                self.removeFromSuperview()
                container.layoutIfNeeded()
            }
        }
    }
    
    func returnToPartialScreen() {
        if let containerStackView = self.containerStackView,
           let containerView = self.containerView,
           let fullScreenContainerViewController = self.fullScreenContainerViewController,
           let aspectRatio = self.videoAspectRatio,
           let fakeViewIndex = containerStackView.arrangedSubviews.firstIndex(where: { $0.accessibilityIdentifier == "fakeView" }) {
                fullScreenContainerViewController.dismiss(animated: false) { [unowned self] in
                    let fakeView = containerStackView.arrangedSubviews[fakeViewIndex]
                    containerStackView.insertArrangedSubview(self, at: fakeViewIndex)
                    containerStackView.removeArrangedSubview(fakeView)
                    fakeView.removeFromSuperview()
                    self.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
                    setHeightAspectRatio(aspectRatio)
                    self.containerStackView = nil
                    containerStackView.layoutIfNeeded()
                }
        }
    }
}

extension CompletePlayerView: CompleteVideoPlayerManagerDelegate {
    public func didUpdateVideoDuration(_ duration: Double) {
        progressView.setTotalTime(duration)
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
        mainActionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        mainActionButton.setImage(mainActionIconWithPlayerStatus(status)?.withRenderingMode(.alwaysTemplate),
                                  for: .normal)
        mainActionButton.addTarget(self,
                                   action: mainActionSelectorWithPlayerStatus(status),
                                   for: .touchUpInside)
    }
}

extension CompletePlayerView: BaseVideoPlayerManagerDelegate {
    public func downloadedProgress(progress: Double) {
        progressView.updateLoadedProgress(progress)
    }
    
    public func readyToPlay() {
        videoPlayer.pause()
    }
    
    public func didUpdateProgress(progress: Double) {
        progressView.updateCurrentProgress(progress)
    }
    
    public func didFinishPlayItem() { }
    
    public func didFailPlayToEnd() { }
    
    public func didFail(error: Error?) { }
}

extension CompletePlayerView: VideoProgressViewDelegate {
    func updateCurrentProgress(_ progress: Double) {
        cancelInactivityTimer()
        videoPlayer.updateCurrentProgress(progress)
    }
    
    func endSliding() {
        startHideInterfaceForInactivity(4.0)
    }
}

private extension CompletePlayerView {
    class TapGestureRecognizerWithAssociatedBool: UITapGestureRecognizer {
        let value: Bool
        
        init(target: Any?, action: Selector?, value: Bool) {
            self.value = value
            super.init(target: target, action: action)
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
        view.addSubview(videoPlayer)
        view.backgroundColor = UIColor(named: "interfaceBackground")
        videoPlayer.fill(view)
        videoPlayer.interfaceView.addSubview(backArrow)
        videoPlayer.interfaceView.addSubview(titleLabel)
        backArrow.layout {
            ($0.height & $0.width) == (24.0 * 24.0)
            $0.top == videoPlayer.interfaceView.topAnchor + 16.0
            $0.leading == videoPlayer.interfaceView.safeAreaLayoutGuide.leadingAnchor + 16.0
        }
        titleLabel.layout {
            $0.height == 20.0
            $0.centerY == backArrow.centerYAnchor
            $0.leading == backArrow.trailingAnchor + 16.0
        }
    }
}
