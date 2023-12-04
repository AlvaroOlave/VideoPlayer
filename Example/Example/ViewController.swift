//
//  ViewController.swift
//  Example
//
//  Created by Álvaro Olave Bañeres on 29/11/23.
//

import UIKit
import VideoPlayer
import AutolayoutDSL
import LoadingDots

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        var config = VideoPlayerConfig(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                                       videoTitle: "Test")
        config.customLoadingViewProvider = self
        
        let player = VideoPlayerView(config: config)
        
        player.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(player)
        player.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
        player.configureIn(view, viewController: self)
    }
}

extension ViewController: CustomLoadingViewProvider {
    func loadingView() -> UIView {
        return LoadingDotsView(configuration: DotsConfiguration(animation: .scale()))
    }
}
