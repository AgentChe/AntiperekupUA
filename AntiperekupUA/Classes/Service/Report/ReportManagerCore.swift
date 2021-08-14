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
}
