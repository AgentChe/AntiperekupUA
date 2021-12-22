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
        
        let confirmResult = input.didTapConfirm.asObservable()
            .withLatestFrom(input.value)
            .compactMap { [weak self] text -> Result<ReportSearchValue, Error>? in
                guard let self = self, let text = text else { return nil }
                let validCount: Int
                
                let errorMessage: String
                let clearedString = text.filter { !$0.isWhitespace }
                switch self.model.fieldType {
                case .regNumber:
                    validCount = 6
                    errorMessage = Constants.regError
                case .vin:
                    validCount = 10
                    errorMessage =  Constants.vinError
                case .technicalPassport:
                    validCount = 9
                    errorMessage = Constants.passportError
                }
                
                let error = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                
                guard clearedString.count >= validCount else { return .failure(error) }
                return self.textValidation(text)
            }
            .share(replay: 1)
        
        let inputResult = input.value
            .compactMap { $0 }
            .map(textValidation)
        
        let result = Observable
            .merge(confirmResult, inputResult)
            .share(replay: 1)
        
        let confirmed = confirmResult
            .compactMap { value -> ReportSearchValue? in
                guard case let .success(searchValue) = value else { return nil }
                return searchValue
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let showError = result
            .map { value -> String in
                guard case let .failure(error) = value else { return "" }
                return error.localizedDescription
            }
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
    
    var textValidation: (String) -> Result<ReportSearchValue, Error> {
        return { [model] text in
            
            let regex = "^[a-zA-Z0-9]*$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            
            let clearString = text.filter { !$0.isWhitespace }
            switch model.fieldType {
            case .regNumber:
                let error = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.regError])
                return !predicate.evaluate(with: clearString)
                    ? .failure(error)
                    : .success(.regNumber(clearString))
            case .vin:
                let error = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.vinError])
                return !predicate.evaluate(with: clearString)
                    ? .failure(error)
                    : .success(.vin(clearString))
            case .technicalPassport:
                let error = NSError(domain: "\(type(of: self))", code: -1, userInfo: [NSLocalizedDescriptionKey: Constants.passportError])
                let series = String(clearString.prefix(3))
                let number = String(clearString.suffix(clearString.count - series.count))
                
                return !predicate.evaluate(with: clearString)
                ? .failure(error)
                : .success(.technicalPassport(series: series, number: number))
            }
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
