//
//  MainHistoryCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 22.09.2021.
//
import UIKit

final class MainHistoryCell: UITableViewCell {
    
    private lazy var dateLabel = makeDateLabel()
    private lazy var valueLabel = makeValueLabel()
    private lazy var icon = makeIcon()
    private lazy var separator = makeSeparator()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainHistoryCell {
    func setup(from item: MainHistoryItem) {
        dateLabel.attributedText = item.date.attributed(with: .date)
        
        let searchValueAttr = TextAttributes.searchValue.dictionary
        let carInfoAttr = TextAttributes.carInfo.dictionary
        let attributedText = NSMutableAttributedString()
        
        attributedText.append(NSAttributedString(string: item.searchValue, attributes: searchValueAttr))
        
        if let carInfo = item.carInfo, !carInfo.isEmpty {
            attributedText.append(NSAttributedString(string: " – ", attributes: searchValueAttr))
            attributedText.append(NSAttributedString(string: carInfo, attributes: carInfoAttr))
        }
        
        valueLabel.attributedText = attributedText
    }
}

private extension MainHistoryCell {
    func initialize() {
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187, alpha: 0.03)
        backgroundColor = UIColor(integralRed: 0, green: 91, blue: 187, alpha: 0.03)
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension MainHistoryCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11.scale),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            valueLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10.scale),
        ])
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 16.scale),
            icon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.heightAnchor.constraint(equalToConstant: 10.scale),
            icon.widthAnchor.constraint(equalToConstant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 16.scale),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            separator.heightAnchor.constraint(equalToConstant: 1.scale),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension MainHistoryCell {
    func makeDateLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeValueLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeIcon() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "Main.RightArrow")
        view.tintColor = UIColor(integralRed: 206, green: 206, blue: 208)
        contentView.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(integralRed: 206, green: 206, blue: 208, alpha: 0.5)
        contentView.addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let date = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 13.scale))
        .lineHeight(16.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
    
    static let searchValue = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 15.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 2, green: 2, blue: 2))
    
    static let carInfo = TextAttributes()
        .font(Fonts.SFProText.font(weight: .W400, size: 15.scale))
        .lineHeight(18.scale)
        .textColor(UIColor(integralRed: 0, green: 91, blue: 187))
}
