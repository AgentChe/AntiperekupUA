//
//  MainSegmentControlView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.07.2021.
//
import UIKit
import RxSwift
import RxCocoa

final class MainSegmentControlView: UIView {
    
    private lazy var selectorView = makeSelectorView()
    private lazy var stackView = makeStackView()
    
    private var isFirst = true
    
    var segments: [MainSegmentItem] = [] {
        didSet {
            stackView.arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }
            
            segments.forEach {
                stackView.addArrangedSubview($0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFirst {
            selectedAnimation()
            isFirst = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let color = UIColor(integralRed: 0, green: 91, blue: 187)
}

extension MainSegmentControlView {
    var selectIndex: Signal<Int> {
        
        let startIndex = rx.methodInvoked(#selector(UIView.layoutSubviews))
            .map { _ in 0 }
            .take(1)
        let selectedIndex = Observable.from(segments)
            .enumerated()
            .flatMap { (arg) -> Observable<Int> in
                let (indexItem, item) = arg
                return item.rx.tap
                    .map { indexItem }
            }
        
        return
            Observable.merge(startIndex, selectedIndex)
            .distinctUntilChanged()
            .do(onNext: { [weak self] indexItem in
                self?.segments.enumerated()
                    .forEach { arg in
                        let (index, item) = arg
                        item.select = index == indexItem
                    }
                self?.selectedAnimation()
            })
            .asSignal(onErrorJustReturn: 0)
    }
}

private extension MainSegmentControlView {
    func initialize() {
        backgroundColor = color.withAlphaComponent(0.1)
        layer.borderWidth = 0.5
        layer.borderColor = color.withAlphaComponent(0.5).cgColor
        layer.cornerRadius = 15.scale
        addSubview(selectorView)
    }
    
    func selectedAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.selectorView.isHidden = false
            self.segments.forEach { segment in
                if segment.select {
                    UIView.performWithoutAnimation {
                        self.selectorView.frame.size = segment.frame.size
                    }
                    
                    self.selectorView.frame.origin = self.stackView.convert(segment.frame.origin, to: self)
                }
                
                segment.isSelected = segment.select
                segment.backgroundColor = segment.select ? self.color : .clear
            }
        }, completion: { _ in self.selectorView.isHidden = true })
    }
}

// MARK: Make constraints
private extension MainSegmentControlView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 3.scale),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.scale),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3.scale),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension MainSegmentControlView {
    func makeSelectorView() -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 15.scale
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillProportionally
        addSubview(view)
        return view
    }
}

final class MainSegmentItem: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var select = false
}
