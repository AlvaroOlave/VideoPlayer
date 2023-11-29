//
//  ViewController.swift
//  Example
//
//  Created by Álvaro Olave Bañeres on 29/11/23.
//

import UIKit
import VideoPlayer
import AutolayoutDSL

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let player = CompletePlayerView(config: VideoPlayerConfig(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                                                                  videoTitle: "Test"))
        player.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(player)
        player.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
        player.configureIn(view, viewController: self)
    }
}

