//
//  ReportManagerCore.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 05.08.2021.
//

import RxSwift

final class ReportManagerCore {
    func getRegNumberByVin(vin: String) -> Single<RegNumberModel?> {
        let request = GetRegNumberRequest(vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { .init(from: $0) }
    }
    
    func getVinAndRegNumberByRegDoc(series: String, number: String) -> Single<VinAndRegNumberModel?> {
        let request = GetVinAndRegNumberRequest(series: series, number: number)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(VinAndRegNumberModel.map(from:))
    }
    
    func getGovData(regNumber: String) -> Single<GovDataModel?> {
        let request = GetGovDataRequest(regNumber: regNumber)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { .init(from: $0) }
    }
    
    func getWanted(regNumber: String, vin: String) -> Single<WantedModel?> {
        let request = GetWantedRequest(regNumber: regNumber, vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(WantedModel.map(from:))
    }
    
    func getInterpol(vin: String) -> Single<InterpolModel?> {
        let request = GetInterpolRequest(vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(InterpolModel.map(from:))
    }
    
    func getPhotos(regNumber: String) -> Single<PhotoModel?> {
        let request = GetPhotoRequest(regNumber: regNumber)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { PhotoModel.map(from: $0) }
    }
    
    func getComments(regNumber: String, vin: String) -> Single<CommentsModel?> {
        let request = GetCommentsRequest(regNumber: regNumber, vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(CommentsModel.map(from:))
    }
    
    func getRIA(regNumber: String, vin: String) -> Single<RIAModel?> {
        let request = GetRIARequest(regNumber: regNumber, vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(RIAModel.map(from:))
    }
    
    func getRecall(vin: String) -> Single<RecallVinSubsModel?> {
        let request = GetRecallVinSubsRequest(vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(RecallVinSubsModel.map(from:))
    }
    
    func getAuction(vin: String, isFree: Bool) -> Single<AuctionModel?> {
        let request = GetAuctionRequest(vin: vin, isFree: isFree)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(AuctionModel.map(from:))
    }
    
    func getDSBT(regNumber: String) -> Single<DSBTModel?> {
        let request = GetDSBTRequest(regNumber: regNumber)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { DSBTModel.map(from: $0) }
    }
    
    func getDecodeVin(vin: String) -> Single<DecodeVinModel?> {
        let request = GetDecodeVinRequest(vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(DecodeVinModel.map(from:))
    }
    
    func getComplectation(vin: String) -> Single<ComplectationModel?> {
        let request = GetComplectationRequest(vin: vin)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(ComplectationModel.map(from:))
    }
    
    func complainComment(id: Int) -> Single<ComplainCommentModel?> {
        let request = ComplainCommentRequest(commentId: id)
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map { .init(from: $0) }
    }
    
    func getMTSBU(regNumber: String, captchaCode: String, verificationToken: String, cookiesString: String) -> Single<MTSBUModel?> {
        let request = GetMTSBURequest(
            regNumber: regNumber,
            captchaCode: captchaCode,
            verificationToken: verificationToken,
            cookiesString: cookiesString
        )
        
        return RestAPITransport()
            .callServerApi(requestBody: request)
            .map(MTSBUModel.map(from:))
    }
}
