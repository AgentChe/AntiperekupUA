//
//  PassportCheckResultCell.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 18.09.2021.
//
import UIKit

final class PassportCheckResultCell: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension PassportCheckResultCell {
    func makeConstraints() { }
}

// MARK: Lazy initialization
private extension PassportCheckResultCell { }


#if DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct PassportCheckResultCellView_Previews: PreviewProvider {
    
    struct PassportCheckResultCellRepresentable: UIViewRepresentable {
        func makeUIView(context: Context) -> PassportCheckResultCell {
            let view = PassportCheckResultCell()
            return view
        }
        func updateUIView(_ uiView: PassportCheckResultCell, context: Context) {
            
        }
    }

    static var previews: some View {
        return PassportCheckResultCellRepresentable().frame(width: 343, height: 165, alignment: .center)
    }
}
#endif
