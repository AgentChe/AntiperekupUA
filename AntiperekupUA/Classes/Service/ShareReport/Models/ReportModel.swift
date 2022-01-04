//
//  ReportModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 02.11.2021.
//

import Foundation

struct ReportModel {
    let searchValue: ReportSearchValue
    var govDataModel: GovDataModel?
    var wantedModel: WantedModel?
    var interpolModel: InterpolModel?
    var photoModel: PhotoModel?
    var commentsModel: CommentsModel?
    var riaModel: RIAModel?
    var recallVinSubsModel: RecallVinSubsModel?
    var auctionModel: AuctionModel?
    var dsbtModel: DSBTModel?
    var decodeVinModel: DecodeVinModel?
    var complectationModel: ComplectationModel?
    var mtsbuModel: MTSBUModel?
    // Пока строка, чтобы сервису отчета понять,
    // что активна подписка и нужно отобразить секцию
    // с утилизацией. Когда бек будет отдавать данные,
    // поправить на нормальную модель
    var disposalModel: String?
}
