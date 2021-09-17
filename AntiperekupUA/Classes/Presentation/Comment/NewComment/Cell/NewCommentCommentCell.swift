//
//  NewCommentCommentCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 14.09.2021.
//
import UIKit

final class NewCommentCommentCell: UITableViewCell {
    
    private lazy var textField = makeTextField()
    private var placeholder: String {
        "new_comment_placeholder".localized
    }
    
    private var textDidChange: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewCommentCommentCell {
    func setup(textDidChange: @escaping (String) -> Void) {
        self.textDidChange = textDidChange
    }
}

extension NewCommentCommentCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder  {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor(integralRed: 138, green: 138, blue: 142)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView.text)
    }
}

private extension NewCommentCommentCell {
    func initialize() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        selectionStyle = .none
        textField.delegate = self
        textField.text = placeholder
        textField.textColor = UIColor(integralRed: 138, green: 138, blue: 142)
    }
}

// MARK: Make constraints
private extension NewCommentCommentCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.scale),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12.scale),
            textField.heightAnchor.constraint(greaterThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7)
        ])
    }
}

// MARK: Lazy initialization
private extension NewCommentCommentCell {
    func makeTextField() -> UITextView {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 17.scale)
        contentView.addSubview(view)
        return view
    }
}
