//
//  PaygateSaleView.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 26.08.2021.
//
import UIKit

final class PaygateSaleView: UIView {
    
    private lazy var saleTitle = makeSaleTitle()
    private lazy var saleValue = makeSaleValue()
    private lazy var percentLabel = makePercentLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.height * 0.01, y: rect.maxY - rect.width * 0.06))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.04, y: rect.maxY))
        path.addLine(to: .zero)
        path.close()
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}

extension PaygateSaleView {
    func setup(for sale: Int) {
        saleValue.attributedText = "\(sale)".attributed(with: .saleValue)
        setNeedsDisplay()
    }
}

private extension PaygateSaleView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 232, green: 1, blue: 28)
        saleTitle.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        clipsToBounds = true
    }
}

// MARK: Make constraints
private extension PaygateSaleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            saleTitle.topAnchor.constraint(equalTo: topAnchor, constant: 8.5.scale),
            saleTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.5),
            saleTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            saleValue.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            saleValue.topAnchor.constraint(equalTo: topAnchor, constant: 8.5.scale),
            saleValue.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.5)
        ])
        
        NSLayoutConstraint.activate([
            percentLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.5.scale),
            percentLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.5),
            percentLabel.leadingAnchor.constraint(equalTo: saleValue.trailingAnchor, constant: 2.scale),
            percentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -9.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateSaleView {
    func makeSaleTitle() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = "sale".localized.uppercased().attributed(with: .sale)
        addSubview(view)
        return view
    }
    
    func makeSaleValue() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePercentLabel() -> UILabel {
        let view = UILabel()
        let percentAttrs = TextAttributes()
            .font(Fonts.SFProDisplay.font(weight: .W700, size: 30.scale))
            .textColor(.white)
            .dictionary
        
        let offAttr = TextAttributes()
            .font(Fonts.SFProDisplay.font(weight: .W700, size: 10.scale))
            .textColor(.white)
            .lineHeight(8.scale)
            .dictionary
        
        let percentAttributes = NSAttributedString(string: "%", attributes: percentAttrs)
        let offAttributes = NSAttributedString(string: "\nOFF", attributes: offAttr)
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(percentAttributes)
        attributedText.append(offAttributes)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        view.attributedText = attributedText
        addSubview(view)
        return view
    }
}

private extension TextAttributes {
    static let sale = TextAttributes()
        .font(Fonts.SFProDisplay.font(weight: .W600, size: 10.scale))
        .textColor(.white)
    
    static let saleValue = TextAttributes()
        .font(Fonts.Oswald.font(weight: .W400, size: 50.scale))
        .textColor(.white)
}
