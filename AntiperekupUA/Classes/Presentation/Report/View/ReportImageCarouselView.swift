//
//  ReportImageCarouselView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//
import UIKit

final class ReportImageCarouselView: UIView {
    
    private lazy var collectionView = makeCollectionView()
    private lazy var pageControl = makePageControl()
    private var elements: [URL] = []
    
    var didSelectItem: ((_ elements: [URL], _ index: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scroll(to index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        pageControl.currentPage = index
    }
}

extension ReportImageCarouselView {
    func setup(elements: [URL], didSelectItem: @escaping (_ elements: [URL], _ index: Int) -> Void) {
        self.elements = elements
        self.didSelectItem = didSelectItem
        pageControl.numberOfPages = elements.count
        collectionView.reloadData()
    }
}

extension ReportImageCarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ReportImageCarouselCell.self), for: indexPath) as! ReportImageCarouselCell
        cell.setup(for: elements[indexPath.row])
        return cell
        
    }
}

extension ReportImageCarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(elements, indexPath.row)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page.rounded())
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(page.rounded())
    }
}

private extension ReportImageCarouselView {
    func initialize() {
        collectionView.register(ReportImageCarouselCell.self, forCellWithReuseIdentifier: String(describing: ReportImageCarouselCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = .clear
    }
}

// MARK: Make constraints
private extension ReportImageCarouselView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 9/16)
        ])
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10.scale),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportImageCarouselView {
    func makeCollectionView() -> UICollectionView {
        let collectionLayout = ReportCarouselFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.decelerationRate = .fast
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 0, left: 8.scale, bottom: 0, right: 8.scale)
        addSubview(view)
        return view
    }
    
    func makePageControl() -> UIPageControl {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.currentPageIndicatorTintColor = UIColor(integralRed: 69, green: 142, blue: 156)
        view.pageIndicatorTintColor = UIColor(integralRed: 69, green: 142, blue: 156, alpha: 0.5)
        view.currentPage = 0
        addSubview(view)
        return view
    }
}
