//
//  ReportCommentComplainCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//
import UIKit

final class ReportCommentComplainCell: UITableViewCell {
    
    private lazy var button = makeButton()
    lazy var containerView = makeContainer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tapAction: ((Int?) -> Void)?
    private var id: Int?
}

extension ReportCommentComplainCell {
    func setup(id: Int, for action: @escaping ((Int?) -> Void)) {
        tapAction = action
        self.id = id
    }
}

extension ReportCommentComplainCell: CornerCellContainer {}

private extension ReportCommentComplainCell {
    func initialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    @objc func didTapButton(sender: UIButton) {
        tapAction?(id)
    }
}

// MARK: Make constraints
private extension ReportCommentComplainCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 24.scale),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32.scale),
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ReportCommentComplainCell {
    func makeButton() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "Report.Complain"), for: .normal)
        view.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        view.tintColor = .black
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
