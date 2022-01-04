//
//  ReportDataSourceConfigureHelper.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 11.09.2021.
//

import Foundation
import RxSwift

enum ReportDataSourceConfigureHelper {
    typealias Elements = [ReportTableItem]
    
    static func baseSection(headerTitle: String, event: Event<ReportScreenViewModel.BaseData>) -> Elements? {
        switch event {
        case let .next(model):
            let regNumber = ReportValueWithActionModel(
                value: model.regNumber,
                action: model.regNumber.isEmpty ? .add : model.isEditableNumber ? .change : .none,
                fieldType: .regNumber
            )
            
            let vin = ReportValueWithActionModel(
                value: model.vin,
                action: model.vin.isEmpty ? .add : model.isEditableVin ? .change : .none,
                fieldType: .vin
            )
            
            let technicalPassport = ReportValueWithActionModel(
                value: model.technicalPassport,
                action: model.technicalPassport.isEmpty ? .add : model.isEditablePassport ? .change : .none,
                fieldType: .technicalPassport
            )
            
            return [
                .header(title: headerTitle, state: .empty),
                .valueWithAction(regNumber),
                .valueWithAction(vin),
                .valueWithAction(technicalPassport)
            ]
        case let .error(error):
            return Self.errorWithRetry(headerText: headerTitle, error: error)
        case .completed:
            return nil
        }
    }
    
    static func mainAndHistory(mainTitle: String, historyTitle: String, model: GovDataModel?) -> (main: Elements, history: Elements)? {
        guard let model = model, model.result else {
            return (Self.errorSection(headerText: mainTitle, message: model?.errorMessage), Self.errorSection(headerText: historyTitle, message: model?.errorMessage))
        }
            
        let main: Elements = model.vehicle
            .map { vehicle in
                [
                    .header(title: mainTitle, state: .success),
                    vehicle.logo.map { .logo($0) },
                    .value(title: "gov_data_regnumber".localized, value: vehicle.regNumber),
                    .value(title: "gov_data_vin".localized, value: vehicle.vin),
                    .value(title: "gov_data_brand".localized, value: vehicle.brand),
                    .value(title: "gov_data_model".localized, value: vehicle.model),
                    .value(title: "gov_data_color".localized, value: vehicle.color),
                    .value(title: "gov_data_body".localized, value: vehicle.body),
                    .value(title: "gov_data_purpose".localized, value: vehicle.purpose),
                    .value(title: "gov_data_kind".localized, value: vehicle.kind),
                    .value(title: "gov_data_capacity".localized, value: vehicle.capacity),
                    .value(title: "gov_data_year".localized, value: vehicle.year),
                    .value(title: "gov_data_fuel".localized, value: vehicle.fuel),
                    .value(title: "gov_data_own_weight".localized, value: vehicle.ownWeight),
                    .value(title: "gov_data_total_weight".localized, value: vehicle.totalWeight),
                    .description("subs_descr_gov_data".localized)
                ].compactMap { $0 }
            } ?? [
                .header(title: mainTitle, state: .error),
                .iconWithText(.init(text: "no_gov_data_information_found".localized, iconType: .error)),
                .description("subs_descr_gov_data".localized)
            ]
            
        var initialHistory: Elements {
            let isEmpty = model.records.isEmpty
            let text = isEmpty ? "no_gov_data_information_found".localized : String(format: "records".localized, model.records.count)
            
            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
            let header: ReportTableItem = .header(title: historyTitle, state: isEmpty ? .error : .success)
            
            return [header, result]
        }
            
        let history: Elements = model.records
            .enumerated()
            .reduce(into: initialHistory) {
                let person: String
                switch $1.element.person.uppercased() {
                case "P":
                    person = "natural_type".localized
                case "J":
                    person = "legal_type".localized
                default:
                    person = $1.element.person
                }
                $0.append(.value(title: "gov_data_date".localized, value: $1.element.date))
                $0.append(.value(title: "gov_data_person".localized, value: person))
                $0.append(.value(title: "gov_data_regnumber".localized, value: $1.element.regNumber))
                $0.append(.value(title: "gov_data_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "gov_data_brand".localized, value: $1.element.brand))
                $0.append(.value(title: "gov_data_model".localized, value: $1.element.model))
                $0.append(.value(title: "gov_data_year".localized, value: $1.element.year))
                $0.append(.value(title: "gov_data_color".localized, value: $1.element.color))
                $0.append(.value(title: "gov_data_department".localized, value: $1.element.departament))
                $0.append(.value(title: "gov_data_department_code".localized, value: $1.element.departamentCode))
                $0.append(.value(title: "gov_data_operation_code".localized, value: $1.element.operationCode))
                $0.append(.value(title: "gov_data_operation_name".localized, value: $1.element.operationName))
                $0.append(.value(title: "gov_data_reg_addr_koatuu".localized, value: $1.element.regAddrKoatuu))
                if $1.offset < model.records.count - 1 {
                    $0.append(.separator)
                }
            } + [.description("subs_descr_gov_data".localized)]
            
        return (main: main, history: history)
    }
    
    static func wantedSection(headerTitle: String, model: WantedModel?, additional: Elements) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.wanted.isEmpty else {
            let text = "no_wanted_information_found".localized
            return [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: text, iconType : .success)),
                .description("subs_descr_wanted".localized)
            ]
        }
        
        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.wanted.count), iconType: .error))
        
        let items: Elements = model.wanted
            .enumerated()
            .reduce(into: [.header(title: headerTitle, state: .error), recordCount]) {
                $0.append(.value(title: "wanted_ovd".localized, value: $1.element.ovd))
                $0.append(.value(title: "wanted_brand".localized, value: $1.element.brand))
                $0.append(.value(title: "wanted_color".localized, value: $1.element.color))
                $0.append(.value(title: "wanted_vehicle_number".localized, value: $1.element.vehicleNumber))
                $0.append(.value(title: "wanted_body_number".localized, value: $1.element.bodyNumber))
                $0.append(.value(title: "wanted_chassis_number".localized, value: $1.element.chassisNumber))
                $0.append(.value(title: "wanted_engine_number".localized, value: $1.element.engineNumber))
                $0.append(.value(title: "wanted_theft_date".localized, value: $1.element.theftDate))
                $0.append(.value(title: "wanted_insert_date".localized, value: $1.element.insertDate))
                if $1.offset < model.wanted.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_wanted".localized))
                }
            }
        
        return items + additional
    }
    
    static func interpolSection(headerTitle: String, model: InterpolModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.interpol.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: "no_interpol_information_found".localized, iconType: .success)),
                .description("subs_descr_interpol".localized)
            ]
            return items
        }
        
        let recordCount = ReportTableItem.iconWithText(.init(text: String(format: "records_wanted".localized, model.interpol.count), iconType: .error))
        
        let items: Elements = model.interpol
            .enumerated()
            .reduce(into: [.header(title: headerTitle, state: .error), recordCount]) {
                $0.append(.value(title: "interpol_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "interpol_number".localized, value: $1.element.number))
                $0.append(.value(title: "interpol_date_added".localized, value: $1.element.addedDate))
                $0.append(.value(title: "interpol_date_theft".localized, value: $1.element.theftDate))
                $0.append(.value(title: "interpol_engine".localized, value: $1.element.engine))
                $0.append(.value(title: "interpol_type".localized, value: $1.element.type))
                $0.append(.value(title: "interpol_make_model".localized, value: $1.element.makeModel))
                if $1.offset < model.interpol.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_interpol".localized))
                }
            }
        
        return items
    }
    
    static func photoSection(headerTitle: String, model: PhotoModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        var initialItems: Elements {
            let isEmpty = model.photos.isEmpty
            let text = isEmpty ? "no_photos_information_found".localized : String(format: "photos".localized, model.photos.count)
            
            let result: ReportTableItem = .iconWithText(.init(text: text, iconType: isEmpty ? .error : .success))
            let header: ReportTableItem = .header(title: headerTitle, state: isEmpty ? .error : .success)
            
            return [header, result]
        }
        
        let items: Elements = model.photos
            .enumerated()
            .reduce(into: initialItems) {
                $0.append(.value(title: "photos_make".localized, value: $1.element.make))
                $0.append(.value(title: "photos_model".localized, value: $1.element.model))
                $0.append(.value(title: "photos_date".localized, value: $1.element.date))
                if let url = $1.element.url {
                    $0.append(.photo(url))
                }
                
                if $1.offset < model.photos.count - 1 {
                    $0.append(.separator)
                }
        } + [.description("subs_descr_photos".localized)]
        
        
        return items
    }
    
    static func commentsSection(headerTitle: String, model: CommentsModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        let additional: Elements = [
            .description("user_comments_desc".localized),
            .commentAction
        ]
        
        guard !model.comments.isEmpty else {
            let text = "user_comments_not_found".localized
            let items: Elements = [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: text, iconType : .success))
            ]
            
            return items + additional
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .error),
            .iconWithText(.init(text: "user_comments_found".localized, iconType: .error))
        ]
        let items: Elements = model.comments
            .enumerated()
            .reduce(into: initialItems) {
                $0.append(.complain(id: $1.element.id))
                $0.append(.value(title: "comment_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "comment_reg_number".localized, value: $1.element.gosNumber))
                $0.append(.value(title: "comment_timestamp".localized, value: Date(timeIntervalSince1970: TimeInterval($1.element.timestamp)).relativeDate))
                $0.append(.value(title: "comment_title".localized, value: $1.element.title))
                $0.append(.value(title: "comment_description".localized, value: $1.element.text))
                if $1.offset < model.comments.count - 1 {
                    $0.append(.separator)
                }
            }
        
        return items + additional
    }
    
    static func auctionSection(headerTitle: String, model: AuctionModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: "no_preview_information_found".localized, iconType: .success)),
                .description("subs_descr_preview".localized)
            ]
            return items
        }
        
        let initialItems: [ReportTableItem] = [
            .header(title: headerTitle, state: .error),
            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
        ]
        
        return model.records
            .enumerated()
            .reduce(into: initialItems) {
                $0.append(.value(title: "auction_header".localized, value: $1.element.header))
                $0.append(.value(title: "auction_actual_price".localized, value: $1.element.actualPrice.price))
                $0.append(.value(title: "auction_repair_cost".localized, value: $1.element.repairCost.price))
                $0.append(.value(title: "auction_title_state".localized, value: $1.element.titleState))
                $0.append(.value(title: "auction_location".localized, value: $1.element.location))
                $0.append(.value(title: "auction_odometer".localized, value: "\($1.element.odometer)"))
                $0.append(.value(title: "auction_primary_damage".localized, value: $1.element.primaryDamage))
                $0.append(.value(title: "auction_secondary_damage".localized, value: $1.element.secondaryDamage))
                $0.append(.value(title: "auction_color".localized, value: $1.element.color))
                $0.append(.value(title: "auction_engine".localized, value: $1.element.engine))
                $0.append(.value(title: "auction_cylinders".localized, value: "\($1.element.cylinders)"))
                $0.append(.value(title: "auction_fuel".localized, value: $1.element.fuel))
                $0.append(.value(title: "auction_keys".localized, value: $1.element.keys))
                $0.append(.value(title: "auction_highlights".localized, value: $1.element.highlights))
                if !$1.element.images.isEmpty {
                    $0.append(.images($1.element.images))
                }
                if $1.offset < model.records.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_preview".localized))
                }
            }
    }
    
    static func riaSection(headerTitle: String, model: RIAModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.data.isEmpty else {
            let text = "no_ria_information_found".localized
            let items: Elements = [
                .header(title: headerTitle, state: .error),
                .iconWithText(.init(text: text, iconType : .error)),
                .description("subs_descr_ria".localized)
            ]
            
            return items
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .success),
            .iconWithText(.init(text: String(format: "records".localized, model.data.count), iconType: .success))
        ]
        
        return model.data
            .enumerated()
            .reduce(into: initialItems) {
                if let url = $1.element.photoURL {
                    $0.append(.photo(url))
                }
                $0.append(.value(title: "ria_title_name".localized, value: $1.element.title))
                $0.append(.value(title: "ria_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "ria_regnumber".localized, value: $1.element.gosNumber))
                $0.append(.value(title: "ria_make".localized, value: $1.element.make))
                $0.append(.value(title: "ria_model".localized, value: $1.element.model))
                $0.append(.value(title: "ria_location".localized, value: $1.element.location))
                $0.append(.value(title: "ria_city".localized, value: $1.element.city))
                $0.append(.value(title: "ria_date_add".localized, value: $1.element.dateAdd))
                $0.append(.value(title: "ria_user_phone".localized, value: $1.element.userPhone))
                $0.append(.value(title: "ria_description".localized, value: $1.element.description))
                $0.append(.value(title: "ria_year".localized, value: "\($1.element.year)"))
                $0.append(.value(title: "ria_mileage".localized, value: $1.element.mileage))
                $0.append(.value(title: "ria_fuel".localized, value: $1.element.fuel))
                $0.append(.value(title: "ria_transmission".localized, value: $1.element.transmission))
                $0.append(.value(title: "ria_price_usd".localized, value: "\($1.element.priceUSD)"))
                $0.append(.url(title: "ria_url".localized, url: GlobalDefinitions.riaBaseUrl + $1.element.url))
                $0.append(.value(title: "ria_is_leasing".localized, value: ($1.element.isLeasing ? "ria_is_leasing_yes" : "ria_is_leasing_no").localized))
                if $1.offset < model.data.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_ria".localized))
                }
            }
    }
    
    static func recallSection(headerTitle: String, model: RecallVinSubsModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: "no_recall_information_found".localized, iconType: .success)),
                .description("subs_descr_recall".localized)
            ]
            return items
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .error),
            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
        ]
        
        return model.records
            .enumerated()
            .reduce(into: initialItems) {
                $0.append(.value(title: "recall_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "recall_make".localized, value: $1.element.make))
                $0.append(.value(title: "recall_model".localized, value: $1.element.model))
                $0.append(.value(title: "recall_reason".localized, value: $1.element.reason))
                if $1.offset < model.records.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_recall".localized))
                }
            }
    }
    
    static func dsbtSection(headerTitle: String, model: DSBTModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let text = "no_dsbt_information_found".localized
            let items: [ReportTableItem] = [
                .header(title: headerTitle, state: .success),
                .iconWithText(.init(text: text, iconType : .success)),
                .description("subs_descr_dsbt".localized)
            ]
            
            return items
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .error),
            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .error))
        ]
        
        return model.records
            .enumerated()
            .reduce(into: initialItems) {
                let managmentType = $1.element.managmentType.isEmpty
                    ? ""
                    : $1.element.managmentType.uppercased() == "NATURAL"
                    ? "natural_type".localized
                    : "legal_type".localized
                
                $0.append(.value(title: "dsbt_regnumber".localized, value: $1.element.regNumber))
                $0.append(.value(title: "dsbt_managment_type".localized, value: managmentType))
                $0.append(.value(title: "dsbt_name".localized, value: $1.element.name))
                $0.append(.value(title: "dsbt_short_name".localized, value: $1.element.shortName))
                $0.append(.value(title: "dsbt_license_num".localized, value: $1.element.licenseNum))
                $0.append(.value(title: "dsbt_start_date".localized, value: $1.element.startDate))
                $0.append(.value(title: "dsbt_end_date".localized, value: $1.element.endDate))
                $0.append(.value(title: "dsbt_activity".localized, value: $1.element.activity))
                $0.append(.value(title: "dsbt_vehicle_status".localized, value: $1.element.vehicleStatus))
                $0.append(.value(title: "dsbt_status".localized, value: $1.element.status))
                if $1.offset < model.records.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_dsbt".localized))
                }
            }
    }
    
    static func decodeVinSection(headerTitle: String, model: DecodeVinModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .error),
                .iconWithText(.init(text: "no_decoder_information_found".localized, iconType: .error)),
                .description("subs_descr_decoder".localized)
            ]
            return items
        }
        
        let logoItem: ReportTableItem? = model.records
            .first(where: { $0.isLogo })
            .flatMap { $0.logoURL }
            .map { .logo($0) }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .success),
            .iconWithText(.init(text: "decoder_success".localized, iconType: .success)),
            logoItem
        ].compactMap { $0 }
        
        return model.records
            .reduce(into: initialItems) {
                switch $1 {
                case let .title(title):
                    $0.append(.title(title))
                case let .value(title, value):
                    $0.append(.value(title: title, value: value))
                case .logo:
                    break
                }
            } + [.description("subs_descr_decoder".localized)]
    }
    
    static func complectationSection(headerTitle: String, model: ComplectationModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .error),
                .iconWithText(.init(text: "no_complectation_information_found".localized, iconType: .error)),
                .description("subs_descr_complectation".localized)
            ]
            return items
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .success),
            .iconWithText(.init(text: "decoder_success".localized, iconType: .success)),
        ]
        
        return model.records
            .reduce(into: initialItems) {
                $0.append(.value(title: $1.title, value: $1.value))
            } + [.description("subs_descr_complectation".localized)]
    }
    
    static func mtsbuSection(headerTitle: String, model: MTSBUModel?) -> Elements? {
        guard let model = model, model.result else {
            return Self.errorSection(headerText: headerTitle, message: model?.errorMessage)
        }
        
        guard !model.records.isEmpty else {
            let items: Elements = [
                .header(title: headerTitle, state: .error),
                .iconWithText(.init(text: "no_mtsbu_information_found".localized, iconType: .error)),
                .description("subs_descr_mtsbu".localized)
            ]
            return items
        }
        
        let initialItems: Elements = [
            .header(title: headerTitle, state: .success),
            .iconWithText(.init(text: String(format: "records".localized, model.records.count), iconType: .success))
        ]
        
        return model.records
            .enumerated()
            .reduce(into: initialItems) {
                $0.append(.value(title: "mtsbu_policy_number".localized, value: $1.element.policyNumber))
                $0.append(.value(title: "mtsbu_vin".localized, value: $1.element.vin))
                $0.append(.value(title: "mtsbu_reg_number".localized, value: $1.element.regNumber))
                $0.append(.value(title: "mtsbu_make_model".localized, value: $1.element.makeModel))
                $0.append(.value(title: "mtsbu_type".localized, value: $1.element.type))
                $0.append(.value(title: "mtsbu_insurer_name".localized, value: $1.element.insurerName))
                $0.append(.value(title: "mtsbu_insurer_status".localized, value: $1.element.insurerStatus))
                $0.append(.value(title: "mtsbu_insurer_phone".localized, value: $1.element.insurerPhone))
                $0.append(.value(title: "mtsbu_insurer_email".localized, value: $1.element.insurerEmail))
                $0.append(.value(title: "mtsbu_insurer_address".localized, value: $1.element.insurerAddress))
                if $1.offset < model.records.count - 1 {
                    $0.append(.separator)
                } else {
                    $0.append(.description("subs_descr_dsbt".localized))
                }
            }
    }
    
    static func errorSection(headerText: String, message: String?) -> Elements {
        return [
            .header(title: headerText, state: .error),
            .error(message: message ?? "")
        ]
    }
    
    static func errorWithRetry(headerText: String, error: Error) -> Elements {
        return [
            .header(title: headerText, state: .error),
            .error(message: "network_error".localized),
            .retry
        ]
    }
}
