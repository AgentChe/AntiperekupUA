//
//  ReportPhotoGalleryViewController.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 06.11.2021.
//

import UIKit
import RxSwift

final class ReportPhotoGalleryViewController: UIPageViewController {
    
    private var elements: [URL] = []
    private var currentIndex: Int!
    
    var completion: ((Int) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        let pageControll = UIPageControl.appearance()
        pageControll.currentPageIndicatorTintColor = UIColor(integralRed: 69, green: 142, blue: 156)
        pageControll.pageIndicatorTintColor = UIColor(integralRed: 69, green: 142, blue: 156, alpha: 0.5)
        
        if let controller = photoController(at: currentIndex ?? 0) {
            setViewControllers([controller], direction: .forward, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completion?(currentIndex ?? 0)
    }
    
    private func photoController(at index: Int) -> UIViewController? {
        let controller = elements[safe: index].map { ReportPhotoViewController.make(imageURL: $0) }
        controller?.currentIndex = index
        return controller
    }
}

extension ReportPhotoGalleryViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? ReportPhotoViewController, let index = controller.currentIndex, index > 0 {
            return photoController(at: index - 1)
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? ReportPhotoViewController, let index = controller.currentIndex, index + 1 < elements.count {
            return photoController(at: index + 1)
        } else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        elements.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        currentIndex ?? 0
    }
}

extension ReportPhotoGalleryViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let index = (viewControllers?.first as? ReportPhotoViewController)?.currentIndex {
            currentIndex = index
        }
    }
}

// MARK: Make
extension ReportPhotoGalleryViewController {
    static func make(elements: [URL], currentIndex: Int, completion: ((Int) -> Void)?) -> ReportPhotoGalleryViewController {
        let controller = ReportPhotoGalleryViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        controller.currentIndex = currentIndex
        controller.elements = elements
        controller.completion = completion
        return controller
    }
}
