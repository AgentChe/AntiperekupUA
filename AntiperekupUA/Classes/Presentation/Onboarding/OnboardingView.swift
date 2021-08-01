//
//  OnboardingView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 20.07.2021.
//
import UIKit

final class OnboardingView: UIView {
    
    lazy var scrollView = makeScrollView()
    lazy var pageControl = makePageControl()
    lazy var languageView = OnboardingLanguageView()
    
    private lazy var contentViews: [UIView] = [
        OnboardingBaseView(viewType: .info, nextAction: nextAction),
        OnboardingBaseView(viewType: .fee, nextAction: nextAction),
        OnboardingBaseView(viewType: .base, nextAction: nextAction),
        OnboardingBaseView(viewType: .taxi, nextAction: nextAction),
        languageView
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nextAction: () -> Void = { [weak self] in
        self?.scroll()
    }
    
    func scroll() {
        let index = pageControl.currentPage + 1
        
        guard contentViews.indices.contains(index) else { return }
        
        scrollView.scrollRectToVisible(contentViews[index].frame, animated: true)
        pageControl.currentPage = index
    }
}

extension OnboardingView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
           pageControl.currentPage = Int(page)
    }
}

private extension OnboardingView {
    func initialize() {
        contentViews
            .enumerated()
            .forEach { index, view in
                scrollView.addSubview(view)
                
                view.frame.origin = CGPoint(x: UIScreen.main.bounds.width * CGFloat(index), y: 0)
                view.frame.size = CGSize(width: UIScreen.main.bounds.width,
                                         height: UIScreen.main.bounds.height)
            }
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(contentViews.count),
                                        height: UIScreen.main.bounds.height)
        pageControl.numberOfPages = contentViews.count
        pageControl.currentPage = 0
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187)
    }
}

// MARK: Make constraints
private extension OnboardingView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 8.scale),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OnboardingView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePageControl() -> UIPageControl {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
