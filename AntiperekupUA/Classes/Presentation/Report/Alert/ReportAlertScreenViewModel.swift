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
    struct Input {
        let value: Observable<String?>
        let didTapConfirm: Signal<Void>
    }
    
    struct Output {
        let title: String
        let defaultValue: String
        let placeholder: String
        let confirmed: Signal<ReportSearchValue>
        let showError: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let confirmedResult = input.didTapConfirm
            .asObservable()
            .withLatestFrom(input.value)
            .map { [model] value -> ReportSearchValue in
                guard let value = value else {
                    throw NSError(domain: "\(type(of: self))", code: -1, userInfo: [:])
                }
                
                let clearString = value.trimmingCharacters(in: .whitespacesAndNewlines)
                switch model.fieldType {
                case .vin:
                    let vinError = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.vinError])
                    guard clearString.count >= 10 else {
                        throw vinError
                    }
                    let regex = "^[a-zA-Z0-9]*$"
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                    
                    guard predicate.evaluate(with: clearString) else {
                        throw vinError
                    }
                    
                    return .vin(clearString)
                case .regNumber:
                    guard clearString.count >= 6 else {
                        throw NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.regError])
                    }
                    return .regNumber(clearString)
                case .technicalPassport:
                    guard clearString.count >= 9 else {
                        throw NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.passportError])
                    }
                    let series = String(clearString.prefix(3))
                    let number = String(clearString.suffix(clearString.count - series.count))
                    return .technicalPassport(series: series, number: number)
                }
            }
            .materialize()
            .share(replay: 1)
        
        let confirmed = confirmedResult
            .compactMap { $0.element }
            .asSignal(onErrorSignalWith: .empty())
        
        let showError = confirmedResult
            .compactMap { $0.error?.localizedDescription }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            title: makeTitle(),
            defaultValue: model.value,
            placeholder: makePlaceholder(),
            confirmed: confirmed,
            showError: showError
        )
    }
}

// MARK: Private
private extension ReportAlertScreenViewModel {
    func makeTitle() -> String {
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
    
    func makePlaceholder() -> String {
        switch model.fieldType {
        case .vin:
            return Constants.vinExample
        case .regNumber:
            return Constants.regExample
        case .technicalPassport:
            return Constants.passportExample
        }
    }
}

private extension ReportAlertScreenViewModel {
    enum Constants {
        static let regExample = "X77XX77"
        static let vinExample = "XTA210990w2395414"
        static let passportExample = "CXI 399999"
        
        static let regError = "Минимальная длина госномера 6 символов."
        static let vinError = "VIN код может содержать только латинские буквы и цифры."
        static let passportError = "Техпаспорт может содержать только латинские буквы и цифры."
    }
}
