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

private extension ReportPhotoCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ReportPhotoCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.scale),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.scale),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            photoImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16.scale),
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
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        contentView.addSubview(view)
        return view
    }
}
