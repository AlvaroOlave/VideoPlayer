//
//  VideoPlayerConfig.swift
//  
//
//  Created by Álvaro Olave on 23/11/23.
//

import Foundation
import UIKit

public enum DefaultIcon: String {
    case play = "play"
    case pause = "pause"
    case back = "back10Sec"
    case forth = "forth10Sec"
    case fullScreen = "expand"
    case embedded = "minimize"
    case fullScreenNavBack = "arrow-left"
}

public struct TimePlayerButtonInfo {
    public let icon: UIImage?
    public let tintColor: UIColor?
    public let time: Float64
    
    public init(icon: UIImage?,
         tintColor:  UIColor?,
         time: Float64 = 10.0) {
        self.icon = icon
        self.tintColor = tintColor
        self.time = time
    }
    
    public init(icon: DefaultIcon,
         tintColor:  UIColor? = nil,
         time: Float64 = 10.0) {
        self.init(icon: UIImage.secureImage(name: icon.rawValue),
                  tintColor: tintColor,
                  time: time)
    }
    
    init(icon: DefaultIcon) {
        self.init(icon: UIImage.secureImage(name: icon.rawValue),
                  tintColor: Colors.IconTint)
    }
}

public struct PlayerButtonInfo {
    public let icon: UIImage?
    public let tintColor: UIColor?
    
    public init(icon: UIImage?,
         tintColor:  UIColor?) {
        self.icon = icon
        self.tintColor = tintColor
    }
    
    public init(icon: DefaultIcon,
         tintColor:  UIColor? = nil) {
        self.init(icon: UIImage.secureImage(name: icon.rawValue),
                  tintColor: tintColor)
    }
}

public struct ProgressBarConfigInfo {
    public var totalBarColor: UIColor?
    public var loadedBarColor: UIColor?
    public var currentBarColor: UIColor?
    public var timeLabelFont: UIFont
    public var timeLabelColor: UIColor?
    
    public init(totalBarColor: UIColor? = Colors.InterfaceBackground.withAlphaComponent(0.25),
                loadedBarColor: UIColor? = Colors.InterfaceBackground.withAlphaComponent(0.25),
                currentBarColor: UIColor? = Colors.CurrentProgress,
                timeLabelFont: UIFont = .systemFont(ofSize: 14, weight: .bold),
                timeLabelColor: UIColor? = Colors.IconTint) {
        self.totalBarColor = totalBarColor
        self.loadedBarColor = loadedBarColor
        self.currentBarColor = currentBarColor
        self.timeLabelFont = timeLabelFont
        self.timeLabelFont = timeLabelFont
    }
}

public struct VideoPlayerConfig {
    public let videoTitle: String
    public var titleColor: UIColor?
    public var interfaceBackgroundColor: UIColor?
    public var playButton: PlayerButtonInfo
    public var pauseButton: PlayerButtonInfo
    public var backButton: TimePlayerButtonInfo
    public var forthButton: TimePlayerButtonInfo
    public var fullScreenButton: PlayerButtonInfo
    public var embeddedButton: PlayerButtonInfo
    public var fullScreenNavBackButton: PlayerButtonInfo
    
    public var progressBarConfig: ProgressBarConfigInfo
    
    public var url: URL
    public let startAutoPlay: Bool
    public let repeatAfterEnd: Bool
    
    public init(url: URL,
                videoTitle: String,
                titleColor: UIColor? = Colors.TitleColor,
                interfaceBackgroundColor: UIColor? = Colors.InterfaceBackground.withAlphaComponent(0.5),
                playButton: PlayerButtonInfo = PlayerButtonInfo(icon: .play,
                                                                tintColor: Colors.IconTint),
                pauseButton: PlayerButtonInfo = PlayerButtonInfo(icon: .pause,
                                                                 tintColor: Colors.IconTint),
                backButton: TimePlayerButtonInfo = TimePlayerButtonInfo(icon: .back,
                                                                        tintColor: Colors.IconTint),
                forthButton: TimePlayerButtonInfo = TimePlayerButtonInfo(icon: .forth,
                                                                         tintColor: Colors.IconTint),
                fullScreenButton: PlayerButtonInfo = PlayerButtonInfo(icon: .fullScreen,
                                                                      tintColor: Colors.IconTint),
                embeddedButton: PlayerButtonInfo = PlayerButtonInfo(icon: .embedded,
                                                                    tintColor: Colors.IconTint),
                fullScreenNavBackButton: PlayerButtonInfo = PlayerButtonInfo(icon: .fullScreenNavBack,
                                                                             tintColor: Colors.IconTint),
                progressBarConfig: ProgressBarConfigInfo = ProgressBarConfigInfo(),
                startAutoPlay: Bool = false,
                repeatAfterEnd: Bool = true) {
        self.url = url
        self.videoTitle = videoTitle
        self.titleColor = titleColor
        self.startAutoPlay = startAutoPlay
        self.repeatAfterEnd = repeatAfterEnd
        self.interfaceBackgroundColor = interfaceBackgroundColor
        self.playButton = playButton
        self.pauseButton = pauseButton
        self.backButton = backButton
        self.forthButton = forthButton
        self.fullScreenButton = fullScreenButton
        self.embeddedButton = embeddedButton
        self.fullScreenNavBackButton = fullScreenNavBackButton
        self.progressBarConfig = progressBarConfig
    }
}
