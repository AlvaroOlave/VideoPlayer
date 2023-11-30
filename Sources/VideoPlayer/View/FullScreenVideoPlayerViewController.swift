//
//  FullScreenVideoPlayerViewController.swift
//  
//
//  Created by Álvaro Olave Bañeres on 30/11/23.
//

import UIKit
import AutolayoutDSL

public final class FullScreenVideoPlayerViewController: UIViewController {

    private let videoPlayer: CompletePlayerView
    
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.videoPlayer.videoAspectRatio ?? 0.0) > 1.0 ? .portrait : [.landscapeRight, .landscapeLeft]
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
}

private extension FullScreenVideoPlayerViewController {
    func setupView() {
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
    
    @objc func backPressed() {
        videoPlayer.goToFullScreen()
    }
}

public final class CompleteNavBar: UINavigationController {
    override public var shouldAutorotate: Bool {
        return true
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscape]
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}
