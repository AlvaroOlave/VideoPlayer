//
//  BaseVideoPlayerConfig.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import Foundation

public struct BaseVideoPlayerConfig {
    let url: URL
    let view: SimplePlayerView
    let startAutoPlay: Bool
    let repeatAfterEnd: Bool
    
    public init(_ url: URL,
                view: SimplePlayerView,
                startAutoPlay: Bool = true,
                repeatAfterEnd: Bool = true) {
        self.url = url
        self.view = view
        self.startAutoPlay = startAutoPlay
        self.repeatAfterEnd = repeatAfterEnd
    }
}
