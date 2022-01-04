//
//  ReportPhotoCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//
import UIKit
import Kingfisher

final class ReportPhotoCell: UITableViewCell {
    
    private lazy var photoImageView = makeImageView()
    lazy var containerView = makeContainer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportPhotoCell {
    func setup(for url: URL) {
        photoImageView.kf.setImage(with: url)
    }
}

extension ReportPhotoCell: CornerCellContainer {}

private extension ReportPhotoCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportPhotoCell {
    func makeConstraints() {
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.scale),
            photoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.scale),
            photoImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.scale),
            photoImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16.scale),
            photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 9/16)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportPhotoCell {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.scale
        view.contentMode = .scaleAspectFit
        view.layer.masksToBounds = true
        containerView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        contentView.addSubview(view)
        return view
    }
}
