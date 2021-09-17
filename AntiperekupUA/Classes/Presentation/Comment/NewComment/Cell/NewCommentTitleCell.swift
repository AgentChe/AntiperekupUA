//
//  NewCommentTitleCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.09.2021.
//
import UIKit

final class NewCommentTitleCell: UITableViewCell {
    
    private lazy var textField = makeTextField()
    private var textDidChange: ((String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewCommentTitleCell {
    func setup(textDidChange: @escaping (String?) -> Void) {
        self.textDidChange = textDidChange
    }
}

private extension NewCommentTitleCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
    }
    
    @objc func textChange() {
        textDidChange?(textField.text)
    }
}

// MARK: Make constraints
private extension NewCommentTitleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.scale),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.scale),
            textField.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension NewCommentTitleCell {
    func makeTextField() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "new_comment_title_placeholder".localized
        view.addTarget(self, action: #selector(textChange), for: .editingChanged)
        contentView.addSubview(view)
        return view
    }
}
