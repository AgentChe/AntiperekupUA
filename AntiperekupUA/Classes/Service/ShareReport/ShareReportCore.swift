//
//  ShareReportCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 25.10.2021.
//

import Foundation
import UIKit
import RxSwift

final class ShareReportCore {
    
    static let share = ShareReportCore()
    
    func getReport(for model: ReportModel) -> Observable<URL?> {
        configureReport(model: model)
            .map { htmlString -> URL? in
                do {
                    let reportType: String
                    switch model.searchValue {
                    case let .vin(value):
                        reportType = value
                    case let .regNumber(value):
                        reportType = value
                    case let .technicalPassport(series, number):
                        reportType = series + number
                    }
                    let filename = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(reportType)_\(Int(Date().timeIntervalSince1970)).html")
                    try htmlString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    return filename
                } catch {
                    return nil
                }
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
    }
    
    private func configureReport(model: ReportModel) -> Observable<String> {
        
        let govBlock = configureGovBlock(model: model.govDataModel)
        let photoBlock = configurePhotoBlock(model: model.photoModel)
        let auctionBlock = configureAuctionBlock(model: model.auctionModel)
        let riaBlock = configureRiaBlock(model: model.riaModel)
        let decodeVinBlock = configureDecodeVinBlock(model: model.decodeVinModel)
        
        return Observable
            .zip(govBlock, photoBlock, auctionBlock, riaBlock, decodeVinBlock) { [weak self] govBlock, photoBlock, auctionBlock, riaBlock, decodeVinBlock -> String in
                guard let self = self else { return "" }
                
                let blocks = [
                    self.configureTitle(searchValue: model.searchValue),
                    govBlock,
                    self.configureWantedBlock(model: model.wantedModel),
                    self.configureInterpolBlock(model: model.interpolModel),
                    photoBlock,
                    self.configureMTSBUBlock(model: model.mtsbuModel),
                    self.configureCommentsBlock(model: model.commentsModel),
                    auctionBlock,
                    riaBlock,
                    self.configureRecallBlock(model: model.recallVinSubsModel),
                    self.configureDSBTBlock(model: model.dsbtModel),
                    decodeVinBlock,
                    self.configureComplectationBlock(model: model.complectationModel)
                ]
                
                return self.configure(blocks: blocks)
            }
    }
}

private extension ShareReportCore {
    func configureGovBlock(model: GovDataModel?) -> Observable<String> {
        guard let model = model else {
            return .just("")
        }
        let mainTitle = "main_information".localized
        let historyTitle = "registration_history".localized
        
        let historyItems = model.records
            .map { record -> String in
                let person: String
                switch record.person.uppercased() {
                case "P":
                    person = "natural_type".localized
                case "J":
                    person = "legal_type".localized
                default:
                    person = record.person
                }
                let items = [
                value(title: "gov_data_date".localized, value: record.date),
                value(title: "gov_data_person".localized, value: person),
                value(title: "gov_data_regnumber".localized, value: record.regNumber),
                value(title: "gov_data_vin".localized, value: record.vin),
                value(title: "gov_data_brand".localized, value: record.brand),
                value(title: "gov_data_model".localized, value: record.model),
                value(title: "gov_data_year".localized, value: record.year),
                value(title: "gov_data_color".localized, value: record.color),
                value(title: "gov_data_department".localized, value: record.departament),
                value(title: "gov_data_department_code".localized, value: record.departamentCode),
                value(title: "gov_data_operation_code".localized, value: record.operationCode),
                value(title: "gov_data_operation_name".localized, value: record.operationName),
                value(title: "gov_data_reg_addr_koatuu".localized, value: record.regAddrKoatuu)
                ]
                
                return group(value: properties(items: items))
            }
        
        let isError = model.records.isEmpty
        let historySubtitle = isError
        ? "no_gov_data_information_found".localized
        : String(format: "records".localized, model.records.count)
        
        let iconWIthText = iconWithText(title: historySubtitle, isError: model.records.isEmpty)
        
        let history = header(
            title: historyTitle,
            content: iconWIthText + historyItems.joined(separator: "\n") + description(value: "subs_descr_gov_data".localized),
            isError: isError
        )
        
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let carLogoBlock: String
            
            if let url = model.vehicle?.logo, let content = try? Data(contentsOf: url) {
                carLogoBlock = self.logo(logo: content)
            } else {
                carLogoBlock = ""
            }
            
            let main = model.vehicle
                .map { vehicle -> String in
                    let items = [
                        self.value(title: "gov_data_regnumber".localized, value: vehicle.regNumber),
                        self.value(title: "gov_data_vin".localized, value: vehicle.vin),
                        self.value(title: "gov_data_brand".localized, value: vehicle.brand),
                        self.value(title: "gov_data_model".localized, value: vehicle.model),
                        self.value(title: "gov_data_color".localized, value: vehicle.color),
                        self.value(title: "gov_data_body".localized, value: vehicle.body),
                        self.value(title: "gov_data_purpose".localized, value: vehicle.purpose),
                        self.value(title: "gov_data_kind".localized, value: vehicle.kind),
                        self.value(title: "gov_data_capacity".localized, value: vehicle.capacity),
                        self.value(title: "gov_data_year".localized, value: vehicle.year),
                        self.value(title: "gov_data_fuel".localized, value: vehicle.fuel),
                        self.value(title: "gov_data_own_weight".localized, value: vehicle.ownWeight),
                        self.value(title: "gov_data_total_weight".localized, value: vehicle.totalWeight)
                    ]
                    
                    let properties = self.properties(items: items)
                    
                    return self.header(
                        title: mainTitle,
                        content: carLogoBlock + properties + self.description(value: "subs_descr_gov_data".localized),
                        isError: false
                    )
                } ?? ""
            
            observer.onNext(main + history)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func configureWantedBlock(model: WantedModel?) -> String {
        guard let model = model else {
            return ""
        }
        let headerTitle = "wanted_title".localized
        let isError = !model.wanted.isEmpty
        let subtitle = isError
        ? String(format: "records_wanted".localized, model.wanted.count)
        : "no_wanted_information_found".localized
        
        let items = model.wanted
            .map { element -> String in
                let items = [
                    value(title: "wanted_ovd".localized, value: element.ovd),
                    value(title: "wanted_brand".localized, value: element.brand),
                    value(title: "wanted_color".localized, value: element.color),
                    value(title: "wanted_vehicle_number".localized, value: element.vehicleNumber),
                    value(title: "wanted_body_number".localized, value: element.bodyNumber),
                    value(title: "wanted_chassis_number".localized, value: element.chassisNumber),
                    value(title: "wanted_engine_number".localized, value: element.engineNumber),
                    value(title: "wanted_theft_date".localized, value: element.theftDate),
                    value(title: "wanted_insert_date".localized, value: element.insertDate),
                ]
                
                return group(value: properties(items: items))
            }.joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "subs_descr_wanted".localized),
            isError: isError
        )
    }
    
    func configureInterpolBlock(model: InterpolModel?) -> String {
        guard let model = model else {
            return ""
        }
        let headerTitle = "interpol_title".localized
        let isError = !model.interpol.isEmpty
        let subtitle = isError
        ? String(format: "records_wanted".localized, model.interpol.count)
        : "no_interpol_information_found".localized
        
        let items = model.interpol
            .map { element -> String in
                let items = [
                    value(title: "interpol_vin".localized, value: element.vin),
                    value(title: "interpol_number".localized, value: element.number),
                    value(title: "interpol_date_added".localized, value: element.addedDate),
                    value(title: "interpol_date_theft".localized, value: element.theftDate),
                    value(title: "interpol_engine".localized, value: element.engine),
                    value(title: "interpol_type".localized, value: element.type),
                    value(title: "interpol_make_model".localized, value: element.makeModel)
                ]
                
                return group(value: properties(items: items))
            }
            .joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "subs_descr_interpol".localized),
            isError: isError
        )
    }
    
    func configurePhotoBlock(model: PhotoModel?) -> Observable<String> {
        guard let model = model else {
            return .just("")
        }
        
        let headerTitle = "photos_title".localized
        let isError = model.photos.isEmpty
        let subtitle = isError
        ? "no_photos_information_found".localized
        : String(format: "photos".localized, model.photos.count)
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            let items = model.photos
                .map { element -> String in
                    let imageBlock: String
                    
                    if let url = element.url, let content = try? Data(contentsOf: url) {
                        imageBlock = self.customCarImage(data: content)
                    } else {
                        imageBlock = ""
                    }
                    
                    let items = [
                        self.value(title: "photos_make".localized, value: element.make),
                        self.value(title: "photos_model".localized, value: element.model),
                        self.value(title: "photos_date".localized, value: element.date),
                        imageBlock
                    ]
                    return self.group(value: self.properties(items: items))
                }.joined(separator: " ")
            
            let result = self.header(
                title: headerTitle,
                content: subtitleBlock + items + self.description(value: "subs_descr_photos".localized),
                isError: isError
            )
            
            observer.onNext(result)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func configureMTSBUBlock(model: MTSBUModel?) -> String {
        guard let model = model else {
            return ""
        }
        
        let headerTitle = "mtsbu_title".localized
        let isError = model.records.isEmpty
        let subtitle = isError
        ? "no_mtsbu_information_found".localized
        : String(format: "records".localized, model.records.count)
        
        let items = model.records
            .map { element -> String in
                let items = [
                    value(title: "mtsbu_policy_number".localized, value: element.policyNumber),
                    value(title: "mtsbu_vin".localized, value: element.vin),
                    value(title: "mtsbu_reg_number".localized, value: element.regNumber),
                    value(title: "mtsbu_make_model".localized, value: element.makeModel),
                    value(title: "mtsbu_type".localized, value: element.type),
                    value(title: "mtsbu_insurer_name".localized, value: element.insurerName),
                    value(title: "mtsbu_insurer_status".localized, value: element.insurerStatus),
                    value(title: "mtsbu_insurer_phone".localized, value: element.insurerPhone),
                    value(title: "mtsbu_insurer_email".localized, value: element.insurerEmail),
                    value(title: "mtsbu_insurer_address".localized, value:element.insurerAddress)
                ]
                
                return group(value: properties(items: items))
            }
            .joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "subs_descr_dsbt".localized),
            isError: isError
        )
    }
    
    func configureCommentsBlock(model: CommentsModel?) -> String {
        guard let model = model else {
            return ""
        }

        let headerTitle = "user_comments".localized
        let isError = !model.comments.isEmpty
        let subtitle = isError
        ? "user_comments_found".localized
        : "user_comments_not_found".localized
        
        let items = model.comments
            .map { element -> String in
                let items = [
                    value(title: "comment_vin".localized, value: element.vin),
                    value(title: "comment_reg_number".localized, value: element.gosNumber),
                    value(title: "comment_timestamp".localized, value: Date(timeIntervalSince1970: TimeInterval(element.timestamp)).relativeDate),
                    value(title: "comment_title".localized, value: element.title),
                    value(title: "comment_description".localized, value: element.text)
                ]
                
                return group(value: properties(items: items))
            }
            .joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "user_comments_desc".localized),
            isError: isError
        )
    }
    
    func configureAuctionBlock(model: AuctionModel?) -> Observable<String> {
        guard let model = model else {
            return .just("")
        }
        let headerTitle = "preview_title".localized
        let isError = !model.records.isEmpty
        let subtitle = isError
        ? String(format: "records".localized, model.records.count)
        : "no_preview_information_found".localized
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        let items = model.records
            .map { element -> Observable<String> in
                let items = [
                    value(title: "auction_header".localized, value: element.header),
                    value(title: "auction_actual_price".localized, value: element.actualPrice.price),
                    value(title: "auction_repair_cost".localized, value: element.repairCost.price),
                    value(title: "auction_title_state".localized, value: element.titleState),
                    value(title: "auction_location".localized, value: element.location),
                    value(title: "auction_odometer".localized, value: "\(element.odometer)"),
                    value(title: "auction_primary_damage".localized, value: element.primaryDamage),
                    value(title: "auction_secondary_damage".localized, value: element.secondaryDamage),
                    value(title: "auction_color".localized, value: element.color),
                    value(title: "auction_engine".localized, value: element.engine),
                    value(title: "auction_cylinders".localized, value: "\(element.cylinders)"),
                    value(title: "auction_fuel".localized, value: element.fuel),
                    value(title: "auction_keys".localized, value: element.keys),
                    value(title: "auction_highlights".localized, value: element.highlights)
                ]
                let images = element.images.map { url -> Observable<Data?> in
                    Observable.create { observer in
                        let data = try? Data(contentsOf: url)
                        observer.onNext(data)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
                
                return Observable.zip(images) { [weak self] images -> String in
                    guard let self = self else { return "" }
                    let imagesBlock = images.compactMap { image -> String? in
                        guard let image = image else { return nil }
                        return self.customCarImage(data: image)
                    }
                    
                    return self.group(value: self.properties(items: items + imagesBlock))
                }
                
            }
        
        return Observable.zip(items)
            .ifEmpty(default: [])
            .map { [weak self] items -> String in
            guard let self = self else { return "" }
            return self.header(
                title: headerTitle,
                content: subtitleBlock + items.joined(separator: " ") + self.description(value: "subs_descr_preview".localized),
                isError: isError
            )
        }
    }
    
    func configureRiaBlock(model: RIAModel?) -> Observable<String> {
        guard let model = model else {
            return .just("")
        }
        let headerTitle = "ria_title".localized
        let isError = model.data.isEmpty
        let subtitle = isError ? "no_ria_information_found".localized : String(format: "records".localized, model.data.count)
        
        
        let items = model.data
            .map { element -> Observable<String> in
                Observable.create { [weak self] observer in
                    guard let self = self else {
                        observer.onCompleted()
                        return Disposables.create()
                    }
                    
                    let logoSection: String
                    
                    if let url = element.photoURL, let logo = try? Data(contentsOf: url) {
                        logoSection = self.customCarImage(data: logo)
                    } else {
                        logoSection = ""
                    }
                    
                    let items = [
                        logoSection,
                        self.value(title: "ria_title_name".localized, value: element.title),
                        self.value(title: "ria_vin".localized, value: element.vin),
                        self.value(title: "ria_regnumber".localized, value: element.gosNumber),
                        self.value(title: "ria_make".localized, value: element.make),
                        self.value(title: "ria_model".localized, value: element.model),
                        self.value(title: "ria_location".localized, value: element.location),
                        self.value(title: "ria_city".localized, value: element.city),
                        self.value(title: "ria_date_add".localized, value: element.dateAdd),
                        self.value(title: "ria_user_phone".localized, value: element.userPhone),
                        self.value(title: "ria_description".localized, value: element.description),
                        self.value(title: "ria_year".localized, value: "\(element.year)"),
                        self.value(title: "ria_mileage".localized, value: element.mileage),
                        self.value(title: "ria_fuel".localized, value: element.fuel),
                        self.value(title: "ria_transmission".localized, value: element.transmission),
                        self.value(title: "ria_price_usd".localized, value: "\(element.priceUSD)"),
                        self.linkValue(title: "ria_url".localized, value: GlobalDefinitions.riaBaseUrl + element.url),
                        self.value(title: "ria_is_leasing".localized, value: (element.isLeasing ? "ria_is_leasing_yes" : "ria_is_leasing_no").localized)
                    ]
                    
                    observer.onNext(items.isEmpty ? "" : self.group(value: self.properties(items: items)))
                    observer.onCompleted()
                    
                    return Disposables.create()
                }
            }
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return Observable.zip(items)
            .ifEmpty(default: [])
            .map { [weak self] items -> String in
                guard let self = self else { return "" }
                
                return self.header(
                    title: headerTitle,
                    content: subtitleBlock + items.joined(separator: " ") + self.description(value: "subs_descr_ria".localized),
                    isError: isError
                )
        }
    }
    
    func configureRecallBlock(model: RecallVinSubsModel?) -> String {
        guard let model = model else {
            return ""
        }
        
        let headerTitle = "recall_title".localized
        let isError = !model.records.isEmpty
        let subtitle = isError
        ? String(format: "records".localized, model.records.count)
        : "no_recall_information_found".localized
        
        let items = model.records
            .map { element -> String in
                let items = [
                    value(title: "recall_vin".localized, value: element.vin),
                    value(title: "recall_make".localized, value: element.make),
                    value(title: "recall_model".localized, value: element.model),
                    value(title: "recall_reason".localized, value: element.reason)
                ]
                
                return group(value: properties(items: items))
            }
            .joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "subs_descr_recall".localized),
            isError: isError
        )
    }
    
    func configureDSBTBlock(model: DSBTModel?) -> String {
        guard let model = model else {
            return ""
        }
        let headerTitle = "dsbt_title".localized
        let isError = !model.records.isEmpty
        let subtitle = isError
        ? String(format: "records".localized, model.records.count)
        : "no_dsbt_information_found".localized
        
        let items = model.records
            .map { element -> String in
                let managmentType = element.managmentType.isEmpty
                    ? ""
                    : element.managmentType.uppercased() == "NATURAL"
                    ? "natural_type".localized
                    : "legal_type".localized
                
                let items = [
                    value(title: "dsbt_regnumber".localized, value: element.regNumber),
                    value(title: "dsbt_managment_type".localized, value: managmentType),
                    value(title: "dsbt_name".localized, value: element.name),
                    value(title: "dsbt_short_name".localized, value: element.shortName),
                    value(title: "dsbt_license_num".localized, value: element.licenseNum),
                    value(title: "dsbt_start_date".localized, value: element.startDate),
                    value(title: "dsbt_end_date".localized, value: element.endDate),
                    value(title: "dsbt_activity".localized, value: element.activity),
                    value(title: "dsbt_vehicle_status".localized, value: element.vehicleStatus),
                    value(title: "dsbt_status".localized, value: element.status)
                ]
                
                return group(value: properties(items: items))
            }
            .joined(separator: " ")
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + items + description(value: "subs_descr_dsbt".localized),
            isError: isError
        )
    }
    
    func configureDecodeVinBlock(model: DecodeVinModel?) -> Observable<String> {
        guard let model = model else {
            return .just("")
        }
        
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let headerTitle = "decoder_title".localized
            let isError = model.records.isEmpty
            let subtitle = isError
            ? "no_decoder_information_found".localized
            : "decoder_success".localized
            
            
            let items = model.records
                .map { element -> String in
                    switch element {
                    case let .title(title):
                        return self.title(title: title)
                    case let .value(title, value):
                        return self.value(title: title, value: value)
                    case .logo:
                        return ""
                    }
                }
            
            let logoURL = model.records
                .first(where: { $0.isLogo })
                .flatMap { $0.logoURL }
            
            let carLogoBlock: String
            
            if let url = logoURL, let logo = try? Data(contentsOf: url) {
                carLogoBlock = self.logo(logo: logo)
            } else {
                carLogoBlock = ""
            }
            
            let iconWithText = self.iconWithText(title: subtitle, isError: isError)
            let content = iconWithText
            + carLogoBlock
            + self.properties(items: items)
            + self.description(value: "subs_descr_decoder".localized)
            
            let header = self.header(
                title: headerTitle,
                content: content,
                isError: isError
            )
            
            observer.onNext(header)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func configureComplectationBlock(model: ComplectationModel?) -> String {
        guard let model = model else {
            return ""
        }
        let headerTitle = "complectation_title".localized
        let isError = model.records.isEmpty
        let subtitle = isError
        ? "no_complectation_information_found".localized
        : "decoder_success".localized
        
        let items = model.records
            .map { element -> String in
                value(title: element.title, value: element.value)
            }
        
        let subtitleBlock = iconWithText(title: subtitle, isError: isError)
        
        return header(
            title: headerTitle,
            content: subtitleBlock + properties(items: items) + description(value: "subs_descr_complectation".localized),
            isError: isError
        )
    }
}

private extension ShareReportCore {
    func header(title: String, content: String, isError: Bool) -> String {
        
        let blockType = isError ? "warning_block" : "success_block"
        return """
        <div class="single_block \(blockType)">
        <div class="block_header">\(title)</div>
        \(content)
        </div>
        
        """
    }
    
    func iconWithText(title: String, isError: Bool) -> String {
        let image = UIImage(named: isError ? "Report.Warning" : "Report.Check")
        let icon = image?.pngData()?.base64EncodedString(options: .init(rawValue: 0)) ?? ""
        let alt = isError ? "Error" : "Success"
        return """
        <div class="result"><img src="data:image/png;base64, \(icon)" class="custom_icons" alt="\(alt)">\(title)</div>
        """
    }
    
    func value(title: String, value: String) -> String {
        let value = value.isEmpty ? "no_data".localized : value
        return """
        <div class="property_item">
        <div class="property">
        <div class="key">\(title)</div>
        <div class="value">\(value)</div>
        </div>
        </div>
        """
    }
    
    func linkValue(title: String, value: String) -> String {
        let value = value.isEmpty ? "no_data".localized : value
        return """
        <div class="property_item">
        <div class="property">
        <div class="key">\(title)</div>
        <div class="value"><a href="\(value)">\(value)</a></div>
        </div>
        </div>
        """
    }
    
    func title(title: String) -> String {
        return """
        <div class="property_item">
        <div class="property">
        <div class="key">\(title)</div>
        </div>
        </div>
        """
    }
    
    func properties(items: [String]) -> String {
        return """
        <div class="properties">
        \(items.joined(separator: " "))
        </div>
        """
    }
    
    func group(value: String) -> String {
        return """
        <div class="property_group">
        \(value)
        </div>
        """
    }
    
    func description(value: String) -> String {
        return """
        <div class="block_info">\(value)</div>
        """
    }
    
    func logo(logo: Data) -> String {
        let icon = logo.base64EncodedString(options: .init(rawValue: 0))
        return """
        <div class="car_logo">
        <img src = "data:image/png;base64, \(icon)" class="custom_car_logo_icons " alt="">
        </div>
        """
    }
    
    func customCarImage(data: Data) -> String {
        let image = data.base64EncodedString(options: .init(rawValue: 0))
        return """
        <div class="properties">
        <img src = "data:image/png;base64, \(image)" class="custom_car_image " alt="">
        </div>
        """
    }
    
    func configureTitle(searchValue: ReportSearchValue) -> String {
        let subtitle: String
        
        switch searchValue {
        case let .vin(value):
            subtitle = String(format: "report_by_vin".localized, value)
        case let .regNumber(value):
            subtitle = String(format: "report_by_reg_number".localized, value)
        case .technicalPassport(series: let series, number: let number):
            subtitle = String(format: "report_by_technical_passport".localized, series, number)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let date = formatter.string(from: Date())
        let appLogo = UIImage(named: "Logo")?.pngData().map { self.logo(logo: $0) } ?? ""
        
        return """
        \(appLogo)
        <div class="block_header">\("app_name".localized)</div>
        <div class="block_header">\(subtitle)</div>
        <div class="block_header">\(String(format: "report_at".localized, date))</div>
        <div class="download_link">
        <a href="\(GlobalDefinitions.appStoreLink)" class="block_header text-white" >
        Скачать приложение
        </a>
        </div>
        """
    }
    
    private func configure(blocks: [String]) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <style>
        @import url(https://fonts.googleapis.com/css2?family=Roboto&display=swap);
        *{font-family:Roboto,sans-serif}body{margin:0;padding:0}
        .container{width:91.6%;display:flex;flex-direction:column;margin:0 auto;padding-bottom:15px}
        .single_block{margin-top:15px;box-shadow:0 0 10px rgba(0,0,0,.5);border-radius:9px;overflow:hidden}
        .block_header{text-align:center;padding:20px;font-size:4.1vw;font-weight:700}
        .run_stat{text-align:center;margin:20px 0}
        .success_block>.block_header{background:#94d7ac}
        .success_block>.result{color:#4a9b6e}
        .success_block>.result>i{color:#4a9b6e;border:2px solid #4a9b6e}
        .alert_block>.block_header{background:#f9cc88}
        .alert_block>.result{color:#e2a032;font-size:3.55vw}
        .alert_block>.result>i{color:#f9cc88}
        .warning_block>.block_header{background:#f4a49d}
        .warning_block>.result{color:#CB5350}
        .warning_block>.result>i{color:#f4a49d}
        .car_logo{text-align:center;margin:30px 0 50px 0}
        .car_logo img{width:180px}
        .run_stat img{width:45%}
        .car_number{width:200px}
        .text-blue{color:#3199de!important}
        .text-white{color:#ffffff!important}
        .result{display:flex;align-items:center;justify-content:center;text-align:center;padding:15px 0;font-size:3.55vw;font-weight:600}
        .check_up{max-width:85%;margin:0 auto}
        .attention{text-align:center;line-height:1.5em;font-size:3vw;font-weight:600;margin:10px 0}
        .attention_title{margin:10px 0}
        .check_item,.driver{position:relative;margin:20px 0;border-bottom:2px solid #e7e7e7}
        .check_property,.driver_property{display:flex;padding:5px}
        .count{margin-right:10px;font-size:18px;font-weight:500}
        .reg{text-align-last:left}.reg>div{margin-bottom:5px}
        .description{max-width:90%}
        .reg_period,.user_type{font-size:1.3vw;font-weight:700}
        .description{font-size:1.3vw}
        .calculated{margin-left:10px}
        .user_type{display:flex;align-items:center}
        .user_type>i{margin:0 0 5px}
        .check_up,.drivers,.properties{position:relative;display:flex;flex-direction:column;max-width:95%;margin:0 auto;margin-bottom:5px}
        .property_item{padding:15px 0;border-bottom:3px solid #e7e7e7}
        .property{display:flex;justify-content:space-between;align-items:center;position:relative;font-size:15px}
        .property_group{border-bottom:3px solid #000}
        .property_group>.properties>div:last-child{border-bottom:none}
        .key{font-weight:550;text-align:left;font-size:4vw;color:#212121}
        .value{text-align:right;font-weight:600;font-size:3.55vw;color:#202020;max-width:250px}
        .custom{font-weight:300!important}
        .block_info{max-width:95%;text-align-last:left;font-weight:500;font-size:3.55vw;margin:16px auto}
        .blackLine{width:100%;background:#000;height:2px;margin:5px 0}
        .custom_car_logo_icons{width:180px}
        .custom_car_image{max-width:100%}
        .custom_icons,.custom_user{width:25px;height:25px;margin-right:5px;padding-left:15px}
        .custom_icons{margin-right:15px}
        .get_check_up{text-transform:uppercase;background:#1182c6;padding:10px 30px}
        .get_check_up>a>div:last-child>i{font-size:25px}
        .get_check_up a{text-decoration:none;color:#fff;display:flex;justify-content:space-between;align-items:center;font-size:4vw;font-weight:700;padding:0;margin:0}@media all and (max-width:600px){.reg_period,.user_type{font-size:3.5vw;font-weight:700}
        .description{font-size:4.1vw}.block_header{font-size:4.9vw}.key,.reg>div,.result{font-size:4.5vw}.block_info,.key{font-weight:400!important}
        .car_logo{margin:10px 0}
        .car_logo img{width:100px;margin:10px 0}
        .custom_arrow{width:15px}.value{font-size:4.5vw}
        .block_info{font-size:5vw}
        .run_stat img{width:80%}
        .car_number{width:150px}
        .download_link{align-self:center;}
        .download_link a{display:flex;text-decoration:none;background:#29ae62;align:center;align-self:center;align-items:center;text-align:center;border-radius:50px;margin:0 auto;margin-top:15px;margin-bottom:15px;align:center;}
        .download_link span{}
        .custom_icons,.custom_user{width:25px;height:25px;margin-right:5px}
        .alert_block>.result,.attention,.warning_block>.result{font-size:4vw}
        .alert_block>.block_info{max-width:85%;margin:0 auto}}@media all and (min-width:700px){.container{max-width:90%}
        .text-white{color:#ffffff!important}
        .properties{max-width:85%}
        .block_info,.key,.result,.result i,.value{font-size:20px}
        .key{font-weight:500}
        .car_logo img{width:130px}
        .block_header{font-size:25px}
        .block_info{max-width:85%}
        .check_info{max-width:95%}
        .download_link{align-self:center;}
        .download_link a{display:flex;text-decoration:none;background:#29ae62;align:center;align-self:center;align-items:center;text-align:center;border-radius:50px;margin:0 auto;margin-top:15px;margin-bottom:15px;align:center;}
        .download_link span{}
        .alert_block>.result{color:#e2a032;font-size:1.6vw}
        .get_check_up{padding-left:50px;padding-right:50px}
        .attention,.check_text{font-size:1.9vw}}
        </style>
        </head>
        <body>
        <div class="container">
        \(blocks.joined(separator: "\n"))
        </body>
        </html>
        """
    }
}
