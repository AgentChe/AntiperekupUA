//
//  ReportScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import RxSwift
import RxCocoa

final class ReportScreenViewModel {
    private lazy var paygateService = PaygateManagerCore()
    private lazy var reportService = ReportManagerCore()
    private let searchValue: ReportSearchValue
    typealias DataSource = (String, [ReportTableItem])
    
    init(searchValue: ReportSearchValue) {
        self.searchValue = searchValue
    }
}

extension ReportScreenViewModel {
    struct Input {
        
    }
    
    struct Output {
        let elements: Driver<[DataSource]>
    }
    
    func configure(input: Input) -> Output {
        
        let isActiveSubscription = paygateService.isActiveSubscription()
            .asObservable()
            .share(replay: 1)
        let searchValue = Observable.just(searchValue)
        
        let baseData = makeBaseData(searchValue: searchValue)
            .distinctUntilChanged()
            .share(replay: 1)
        
        let elements = Observable
            .combineLatest(
                makeBaseSection(baseData: baseData),
                makeMainAndHistorySection(baseData: baseData),
                makeWantedSection(baseData: baseData),
                makeInterpolSection(baseData: baseData)
            ) { $0 + $1 + $2 + $3 }
            .asDriver(onErrorJustReturn: [])
        
        
        return Output(elements: elements)
    }
    
    
}

// MARK: Private
private extension ReportScreenViewModel {
    
    func makeBaseData(searchValue: Observable<ReportSearchValue>) -> Observable<BaseData> {
        searchValue
            .flatMapLatest { [reportService] searchValue -> Observable<BaseData> in
                let baseData: Observable<BaseData>
                switch searchValue {
                case let .vin(value):
                    baseData = reportService
                        .getRegNumberByVin(vin: value)
                        .asObservable()
                        .map { BaseData(vin: value, regNumber: $0?.regNumber, technicalPassport: nil) }
                case .regNumber:
                    baseData = .empty()
                case let .technicalPassport(series, number):
                    baseData = reportService
                        .getVinAndRegNumberByRegDoc(series: series, number: number)
                        .asObservable()
                        .map { BaseData(vin: $0?.vin, regNumber: $0?.regNumber, technicalPassport: "\(series)\(number)") }
                }
                
                return baseData
            }
    }
    
    func makeBaseSection(baseData: Observable<BaseData>) -> Observable<[DataSource]> {
        baseData
            .map { model -> [DataSource] in
                let regNumber = ReportValueWithActionModel(
                    value: model.regNumber ?? "",
                    action: model.regNumber.map { $0.contains("_") ? .change : .none } ?? .add,
                    fieldType: .regNumber
                )
                
                let vin = ReportValueWithActionModel(
                    value: model.vin ?? "",
                    action: model.vin.map { $0.contains("_") ? .change : .none } ?? .add,
                    fieldType: .vin
                )
                
                let technicalPassport = ReportValueWithActionModel(
                    value: model.technicalPassport ?? "",
                    action: model.technicalPassport.map { $0.contains("_") ? .change : .none } ?? .add,
                    fieldType: .technicalPassport
                )
                
                let items: [ReportTableItem] = [
                    .header(.init(title: "basic_information".localized, state: .empty)),
                    .valueWithAction(regNumber),
                    .valueWithAction(vin),
                    .valueWithAction(technicalPassport)
                ]
                
                return [("", items)]
            }
    }
    
    func makeMainAndHistorySection(baseData: Observable<BaseData>) -> Observable<[DataSource]> {
        return baseData
            .map { $0.regNumber }
            .flatMapLatest { [reportService] regNumber -> Observable<[DataSource]> in
                let headerTitle = "main_information".localized
                
                guard let regNumber = regNumber else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    let items: [ReportTableItem] = [
                        .header(.init(title: headerTitle, state: .empty)),
                        .text(text),
                        .valueWithAction(.init(value: "", action: .add, fieldType: .regNumber)),
                        .valueWithAction(.init(value: "", action: .add, fieldType: .technicalPassport))
                    ]
                    return .just([("", items)])
                }
                
                return reportService
                    .getGovData(regNumber: regNumber)
                    .asObservable()
                    .map { model -> [DataSource] in
                        guard let model = model, model.result else {
                            return [Self.errorSection(headerText: headerTitle, message: model?.errorMessage)]
                        }
                        
                        guard let vehicle = model.vehicle else {
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .error)),
                                .iconWithText(.init(text: "no_gov_data_information_found".localized, iconType: .error))
                            ]
                            return [("", items)]
                        }
                        
                        let main: [ReportTableItem] = [
                            .header(.init(title: headerTitle, state: .success)),
                            .value(.init(title: "gov_data_regnumber".localized, value: vehicle.regNumber)),
                            .value(.init(title: "gov_data_vin".localized, value: vehicle.vin)),
                            .value(.init(title: "gov_data_brand".localized, value: vehicle.brand)),
                            .value(.init(title: "gov_data_model".localized, value: vehicle.model)),
                            .value(.init(title: "gov_data_color".localized, value: vehicle.color)),
                            .value(.init(title: "gov_data_body".localized, value: vehicle.body)),
                            .value(.init(title: "gov_data_purpose".localized, value: vehicle.purpose)),
                            .value(.init(title: "gov_data_kind".localized, value: vehicle.kind)),
                            .value(.init(title: "gov_data_capacity".localized, value: vehicle.capacity)),
                            .value(.init(title: "gov_data_year".localized, value: vehicle.year)),
                            .value(.init(title: "gov_data_fuel".localized, value: vehicle.fuel)),
                            .value(.init(title: "gov_data_own_weight".localized, value: vehicle.ownWeight)),
                            .value(.init(title: "gov_data_total_weight".localized, value: vehicle.totalWeight))
                        ]
                        
                        var initialHistory: [ReportTableItem] {
                            let isEmpty = model.records.isEmpty
                            let text = isEmpty ? "no_gov_data_information_found".localized : String(format: "records".localized, model.records.count)
                            
                            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
                            let header: ReportTableItem = .header(.init(title: "registration_history".localized, state: isEmpty ? .error : .success))
                            
                            return [header, result]
                        }
                        
                        let history: [ReportTableItem] = model.records
                            .reduce(into: initialHistory) {
                                $0.append(.value(.init(title: "gov_data_date".localized, value: $1.date)))
                                $0.append(.value(.init(title: "gov_data_person".localized, value: $1.person)))
                                $0.append(.value(.init(title: "gov_data_regnumber".localized, value: $1.regNumber)))
                                $0.append(.value(.init(title: "gov_data_vin".localized, value: $1.vin)))
                                $0.append(.value(.init(title: "gov_data_brand".localized, value: $1.brand)))
                                $0.append(.value(.init(title: "gov_data_model".localized, value: $1.model)))
                                $0.append(.value(.init(title: "gov_data_year".localized, value: $1.year)))
                                $0.append(.value(.init(title: "gov_data_color".localized, value: $1.color)))
                                $0.append(.value(.init(title: "gov_data_department".localized, value: $1.departament)))
                                $0.append(.value(.init(title: "gov_data_department_code".localized, value: $1.departamentCode)))
                                $0.append(.value(.init(title: "gov_data_operation_code".localized, value: $1.operationCode)))
                                $0.append(.value(.init(title: "gov_data_operation_name".localized, value: $1.operationName)))
                                $0.append(.value(.init(title: "gov_data_reg_addr_koatuu".localized, value: $1.regAddrKoatuu)))
                                $0.append(.separator)
                            }
                        
                        return [("", main), ("", history)]
                    }
            }
    }
    
    func makeWantedSection(baseData: Observable<BaseData>) -> Observable<[DataSource]> {
        return baseData
            .flatMapLatest { [reportService] data -> Observable<[DataSource]> in
                let headerTitle = "wanted_title".localized
                
                let regNumber = data.regNumber ?? ""
                let vin = data.vin ?? ""
                let technicalPassport = data.technicalPassport ?? ""
                
                let actionItems: [ReportTableItem] = [
                    regNumber.isEmpty ? .valueWithAction(.init(value: "", action: .add, fieldType: .regNumber)) : nil,
                    vin.isEmpty ? .valueWithAction(.init(value: "", action: .add, fieldType: .vin)) : nil,
                    technicalPassport.isEmpty ? .valueWithAction(.init(value: "", action: .add, fieldType: .technicalPassport)) : nil
                ].compactMap { $0 }
                
                guard !regNumber.isEmpty && !vin.isEmpty else {
                    let text = String(format: "required_empty_data_warning".localized, "gos_number_type".localized)
                    let items: [ReportTableItem] = [.header(.init(title: headerTitle, state: .empty)), .text(text)] + actionItems
                    return .just([("", items)])
                }
                
                return reportService
                    .getWanted(regNumber: regNumber, vin: vin)
                    .asObservable()
                    .map { model -> [DataSource] in
                        guard let model = model, model.result else {
                            return [Self.errorSection(headerText: headerTitle, message: model?.errorMessage)]
                        }
                        
                        guard !model.wanted.isEmpty else {
                            let text = "no_wanted_information_found".localized
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .success)),
                                .iconWithText(.init(text: text, iconType : .success))
                            ]
                            
                            return [("", items)]
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.wanted.count), iconType: .error))
                        
                        let items: [ReportTableItem] = model.wanted
                            .reduce(into: [.header(.init(title: headerTitle, state: .error)), recordCount]) {
                                $0.append(.value(.init(title: "wanted_ovd".localized, value: $1.ovd)))
                                $0.append(.value(.init(title: "wanted_brand".localized, value: $1.brand)))
                                $0.append(.value(.init(title: "wanted_color".localized, value: $1.color)))
                                $0.append(.value(.init(title: "wanted_vehicle_number".localized, value: $1.vehicleNumber)))
                                $0.append(.value(.init(title: "wanted_body_number".localized, value: $1.bodyNumber)))
                                $0.append(.value(.init(title: "wanted_chassis_number".localized, value: $1.chassisNumber)))
                                $0.append(.value(.init(title: "wanted_engine_number".localized, value: $1.engineNumber)))
                                $0.append(.value(.init(title: "wanted_theft_date".localized, value: $1.theftDate)))
                                $0.append(.value(.init(title: "wanted_insert_date".localized, value: $1.insertDate)))
                                $0.append(.separator)
                            } + actionItems
                        
                        return [("", items)]
                    }
            }
    }
    
    func makeInterpolSection(baseData: Observable<BaseData>) -> Observable<[DataSource]> {
        return baseData
            .flatMapLatest { [reportService] data -> Observable<[DataSource]> in
                let headerTitle = "interpol_title".localized
                
                guard let vin = data.vin else {
                    let text = String(format: "required_empty_data_warning".localized, "vin_code_type".localized)
                    
                    let items: [ReportTableItem] = [
                        .header(.init(title: headerTitle, state: .empty)),
                        .text(text),
                        .valueWithAction(.init(value: "", action: .add, fieldType: .vin)),
                        .valueWithAction(.init(value: "", action: .add, fieldType: .technicalPassport))
                    ]
                    return .just([("", items)])
                }
                
                return reportService
                    .getInterpol(vin: vin)
                    .asObservable()
                    .map { model -> [DataSource] in
                        guard let model = model, model.result else {
                            return [Self.errorSection(headerText: headerTitle, message: model?.errorMessage)]
                        }
                        
                        guard !model.interpol.isEmpty else {
                            let items: [ReportTableItem] = [
                                .header(.init(title: headerTitle, state: .success)),
                                .iconWithText(.init(text: "no_interpol_information_found".localized, iconType: .success))
                            ]
                            return [("", items)]
                        }
                        
                        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.interpol.count), iconType: .error))
                        
                        let items: [ReportTableItem] = model.interpol
                            .reduce(into: [.header(.init(title: headerTitle, state: .error)), recordCount]) {
                                $0.append(.value(.init(title: "interpol_vin".localized, value: $1.vin)))
                                $0.append(.value(.init(title: "interpol_number".localized, value: $1.number)))
                                $0.append(.value(.init(title: "interpol_date_added".localized, value: $1.addedDate)))
                                $0.append(.value(.init(title: "interpol_date_theft".localized, value: $1.theftDate)))
                                $0.append(.value(.init(title: "interpol_engine".localized, value: $1.engine)))
                                $0.append(.value(.init(title: "interpol_type".localized, value: $1.type)))
                                $0.append(.value(.init(title: "interpol_make_model".localized, value: $1.makeModel)))
                                $0.append(.separator)
                            }
                        
                        return [("",  items)]
                    }
            }
    }
}

private extension ReportScreenViewModel {
    struct BaseData: Equatable {
        let vin: String?
        let regNumber: String?
        let technicalPassport: String?
    }
    
    static func errorSection(headerText: String, message: String?) -> DataSource {
        let items: [ReportTableItem] = [
            .header(.init(title: headerText, state: .error)),
            .error(message: message ?? "")
        ]
        
        return ("", items)
    }
}
