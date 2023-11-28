//
//  LoadingView.swift
//  
//
//  Created by Álvaro Olave on 22/11/23.
//

import Foundation
import UIKit
import LoadingDots
import AutolayoutDSL

public class LoadingView: UIView {
    
    private lazy var loadingView = LoadingDotsView()
    
    public init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingView {
    func setupViews() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(loadingView)
        
        loadingView.layout {
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor
        }
    }
}
