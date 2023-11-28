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
        self.init(icon: UIImage(named: icon.rawValue),
                  tintColor: tintColor,
                  time: time)
    }
    
    init(icon: DefaultIcon) {
        self.init(icon: UIImage(named: icon.rawValue),
                  tintColor: UIColor(named: "iconTint"))
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
        self.init(icon: UIImage(named: icon.rawValue),
                  tintColor: tintColor)
    }
    
    init(icon: DefaultIcon) {
        self.init(icon: UIImage(named: icon.rawValue),
                  tintColor: UIColor(named: "iconTint"))
    }
}

public struct ProgressBarConfigInfo {
    public let totalBarColor: UIColor? = UIColor(named: "interfaceBackground")?.withAlphaComponent(0.25)
    public let loadedBarColor: UIColor? = UIColor(named: "interfaceBackground")?.withAlphaComponent(0.25)
    public let currentBarColor: UIColor? = UIColor(named: "currentProgress")
    public let timeLabelFont: UIFont = .systemFont(ofSize: 14, weight: .bold)
    public let timeLabelColor: UIColor? = UIColor(named: "iconTint")
    
//    public init(totalBarColor: UIColor?,
//                loadedBarColor: UIColor?,
//                currentBarColor: UIColor?,
//                timeLabelFont: UIFont,
//                timeLabelColor: UIColor?) {
//        self.totalBarColor = totalBarColor
//        self.loadedBarColor = loadedBarColor
//        self.currentBarColor = currentBarColor
//        self.timeLabelFont = timeLabelFont
//        self.timeLabelFont = timeLabelFont
//    }
}

public struct VideoPlayerConfig {
    public let videoTitle: String
    public var titleColor: UIColor? = UIColor(named: "titleColor")
    public var interfaceBackgroundColor: UIColor? = UIColor(named: "interfaceBackground")?.withAlphaComponent(0.5)
    public var playButton: PlayerButtonInfo = PlayerButtonInfo(icon: .play)
    public var pauseButton: PlayerButtonInfo = PlayerButtonInfo(icon: .pause)
    public var backButton: TimePlayerButtonInfo = TimePlayerButtonInfo(icon: .back)
    public var forthButton: TimePlayerButtonInfo = TimePlayerButtonInfo(icon: .forth)
    public var fullScreenButton: PlayerButtonInfo = PlayerButtonInfo(icon: .fullScreen)
    public var embeddedButton: PlayerButtonInfo = PlayerButtonInfo(icon: .embedded)
    public var fullScreenNavBackButton: PlayerButtonInfo = PlayerButtonInfo(icon: .fullScreenNavBack)
    
    public var progressBarConfig: ProgressBarConfigInfo = ProgressBarConfigInfo(totalBarColor: <#UIColor?#>, loadedBarColor: <#UIColor?#>, currentBarColor: <#UIColor?#>, timeLabelFont: <#UIFont#>, timeLabelColor: <#UIColor?#>)
    
    public var url: URL
    public let startAutoPlay: Bool
    public let repeatAfterEnd: Bool
    
    public init(url: URL,
                videoTitle: String,
                startAutoPlay: Bool = false,
                repeatAfterEnd: Bool = true,
                interfaceBackgroundColor: UIColor,
                playButton: PlayerButtonInfo,
                pauseButton: PlayerButtonInfo,
                backButton: TimePlayerButtonInfo,
                forthButton: TimePlayerButtonInfo,
                fullScreenButton: PlayerButtonInfo,
                embeddedButton: PlayerButtonInfo,
                fullScreenNavBackButton: PlayerButtonInfo) {
        self.url = url
        self.videoTitle = videoTitle
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
    }
}
