//
//  SimplePlayerView.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import AVFoundation
import UIKit

public class SimplePlayerView: UIView {
    
    public var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
