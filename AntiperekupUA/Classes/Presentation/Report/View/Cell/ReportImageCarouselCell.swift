//
//  ReportImageCarouselCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 31.08.2021.
//
import UIKit
import Kingfisher

final class ReportImageCarouselCell: UICollectionViewCell {
    
    private lazy var imageView = makeImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportImageCarouselCell {
    func setup(for url: URL) {
        imageView.kf.setImage(with: url)
    }
}

private extension ReportImageCarouselCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK: Make constraints
private extension ReportImageCarouselCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportImageCarouselCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.scale
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        contentView.addSubview(view)
        return view
    }
}
