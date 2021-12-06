//
//  ReportAlertScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 24.08.2021.
//

import RxSwift
import RxCocoa

final class ReportAlertScreenViewModel {
    let model: ReportValueWithActionModel
    
    init(model: ReportValueWithActionModel) {
        self.model = model
    }
}

extension ReportAlertScreenViewModel {
    typealias FieldType = ReportAlertScreenView.FieldType
    struct Input {
        let value: Observable<String?>
        let didTapConfirm: Signal<Void>
    }
    
    struct Output {
        let title: String
        let fieldType: FieldType
        let defaultValue: String
        let confirmed: Signal<ReportSearchValue>
        let showError: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let confirmedResult = input.didTapConfirm
            .asObservable()
            .withLatestFrom(input.value)
            .map { [model] value -> Event<ReportSearchValue> in
                guard let value = value else {
                    return .error(NSError(domain: "\(type(of: self))", code: -1, userInfo: [:]))
                }
                
                let clearString = value.trimmingCharacters(in: .whitespacesAndNewlines)
                switch model.fieldType {
                case .vin:
                    let vinError = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.vinError])
                    guard clearString.count >= 10 else {
                        return .error(vinError)
                    }
                    let regex = "^[a-zA-Z0-9]*$"
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                    
                    guard predicate.evaluate(with: clearString) else {
                        return .error(vinError)
                    }
                    
                    return .next(.vin(clearString))
                case .regNumber:
                    guard clearString.count >= 6 else {
                        return .error(NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.regError]))
                    }
                    return .next(.regNumber(clearString))
                case .technicalPassport:
                    guard clearString.count >= 9 else {
                        return .error(NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.passportError]))
                    }
                    let series = String(clearString.prefix(3))
                    let number = String(clearString.suffix(clearString.count - series.count))
                    return .next(.technicalPassport(series: series, number: number))
                }
            }
            .share(replay: 1)
        
        let confirmed = confirmedResult
            .compactMap { $0.element }
            .asSignal(onErrorSignalWith: .empty())
        
        let showError = confirmedResult
            .compactMap { $0.error?.localizedDescription }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            title: title,
            fieldType: fieldType,
            defaultValue: model.value,
            confirmed: confirmed,
            showError: showError
        )
    }
}

// MARK: Private
private extension ReportAlertScreenViewModel {
    var title: String {
        switch model.fieldType {
        case .vin:
            switch model.action {
            case .add:
                return "enter_vin".localized
            case .change:
                return "input_missing_vin".localized
            case .none:
                return ""
            }
        case .regNumber:
            switch model.action {
            case .add:
                return "enter_gos_number".localized
            case .change:
                return "input_missing_gos".localized
            case .none:
                return ""
            }
        case .technicalPassport:
            return "enter_tech_passport".localized
        }
    }
    
    var fieldType: FieldType {
        switch model.fieldType {
        case .vin:
            return .vin
        case .regNumber:
            return .regNumber
        case .technicalPassport:
            return .tecnicalPassport
        }
    }
}

private extension ReportAlertScreenViewModel {
    enum Constants {
        static let regError = "reg_number_validation_error".localized
        static let vinError = "vin_validation_error".localized
        static let passportError = "technical_passport_validation_error".localized
    }
}
