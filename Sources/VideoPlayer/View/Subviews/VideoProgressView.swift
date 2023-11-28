//
//  VideoProgressView.swift
//  
//
//  Created by Álvaro Olave Bañeres on 22/11/23.
//

import UIKit
import AutolayoutDSL

protocol VideoProgressViewDelegate: AnyObject {
    func updateCurrentProgress(_ progress: Double)
    func endSliding()
}

final class VideoProgressView: UIView {
    private lazy var progressContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    private lazy var totalProgressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = config.totalBarColor
        view.layer.cornerRadius = 2.0
        return view
    }()
    
    private lazy var loadedProgressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.trackTintColor = .clear
        view.progressTintColor = config.loadedBarColor
        view.setProgress(0.0, animated: false)
        return view
    }()
    
    private lazy var currentProgressView: UISlider = {
        let view = UISlider()
        view.minimumValue = 0.0
        view.maximumValue = 1.0
        view.value = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumTrackTintColor = config.currentBarColor
        view.maximumTrackTintColor = .clear
        view.setThumbImage(thumbCircleWith(size: CGSize(width: 16.0,
                                                        height: 16.0),
                                           backgroundColor: config.currentBarColor ?? .clear),
                           for: .normal)
        view.addTarget(self,
                       action: #selector(sliderValueChanged),
                       for: .valueChanged)
        view.addTarget(self,
                    action: #selector(sliderDidEndSliding),
                    for: .touchUpInside)
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = config.timeLabelFont
        label.textColor = config.timeLabelColor
        label.text = "--:--/--:-- "
        return label
    }()
    
    private var totalTime: Double?
    public weak var delegate: VideoProgressViewDelegate?
    
    private let config: ProgressBarConfigInfo
    
    init(config: ProgressBarConfigInfo) {
        self.config = config
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCurrentProgress(_ progress: Double) {
        currentProgressView.value = Float(progress)
        updateTimeLabel(progress)
    }
    
    public func updateLoadedProgress(_ progress: Double) {
        guard loadedProgressView.progress < Float(progress) else { return }
        loadedProgressView.setProgress(Float(progress), animated: true)
    }
    
    public func setTotalTime(_ secs: Double) {
        totalTime = secs
        updateTimeLabel(0.0)
    }
}

private extension VideoProgressView {
    func setupView() {
        addSubview(progressContainerView)
        progressContainerView.addSubview(totalProgressView)
        progressContainerView.addSubview(loadedProgressView)
        progressContainerView.addSubview(currentProgressView)
        progressContainerView.addSubview(timeLabel)
        
        progressContainerView.layout {
            $0.height == 16.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        totalProgressView.layout {
            $0.leading == progressContainerView.leadingAnchor
            $0.trailing == progressContainerView.trailingAnchor
            $0.centerY == progressContainerView.centerYAnchor
            $0.height == 4.0
        }
        loadedProgressView.layout {
            $0.leading == progressContainerView.leadingAnchor
            $0.trailing == progressContainerView.trailingAnchor
            $0.centerY == progressContainerView.centerYAnchor
            $0.height == 4.0
        }
        currentProgressView.layout {
            $0.leading == progressContainerView.leadingAnchor - 1.0
            $0.trailing == progressContainerView.trailingAnchor
            $0.centerY == progressContainerView.centerYAnchor - 1.0
            $0.height == 6.0
        }
        timeLabel.layout {
            $0.height == 20.0
            $0.leading == leadingAnchor
            $0.bottom == progressContainerView.topAnchor - 4.0
        }
    }
    
    func thumbCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func updateTimeLabel(_ progress: Double) {
        guard let total = totalTime else { return timeLabel.isHidden = true }
        timeLabel.isHidden = false
        let currentTime = progress * total
        let color = (config.timeLabelColor ?? .clear)
        let currentAttributed = NSMutableAttributedString(string:stringFromTime(currentTime),
                                                          attributes:[.foregroundColor : color])
        let totalAttributed = NSMutableAttributedString(string:" / " + stringFromTime(total),
                                                          attributes:[.foregroundColor : color])
        currentAttributed.append(totalAttributed)
        timeLabel.attributedText = currentAttributed
    }
    
    func stringFromTime(_ time: Double) -> String {
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func sliderValueChanged() {
        delegate?.updateCurrentProgress(Double(currentProgressView.value))
    }
    
    @objc func sliderDidEndSliding() {
        delegate?.endSliding()
    }
}
