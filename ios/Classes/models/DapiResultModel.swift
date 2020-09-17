//
//  DapiResultModel.swift
//  dapi
//
//  Created by Dmitro Serdun on 17.09.2020.
//

import Foundation
struct DapiResultModel : Codable{
    var jobID:String?
    var status:String?
    var success:Bool?
}
extension DapiResultModel : Equatable{
    static func == (lhs: DapiResultModel, rhs: DapiResultModel) -> Bool {
        return lhs.jobID == rhs.jobID
    }
}
