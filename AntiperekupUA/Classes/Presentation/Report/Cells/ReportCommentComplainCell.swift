//
//  ReportCommentComplainCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 15.08.2021.
//
import UIKit

final class ReportCommentComplainCell: UITableViewCell {
    
    private lazy var button = makeButton()
    
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

private extension ReportCommentComplainCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
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
            button.heightAnchor.constraint(equalToConstant: 24.scale),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32.scale),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
        contentView.addSubview(view)
        return view
    }
}
