//
//  AccountMetaDataModel.swift
//  dapi
//
//  Created by Dmitro Serdun on 17.09.2020.
//

import Foundation


struct DapiBankMetadataModel:Codable{
    var bankName:String?
    var coolDownPeriod:CoolDownPeriodModel?
    var country:PairModel?
    var branchAddress:String?
    var branchName:String?
    var isCreateBeneficiaryRequired:Bool?
    var swiftCode:String?
    var address:AddressModel?

}

extension DapiBankMetadataModel : Equatable{
    static func == (lhs: DapiBankMetadataModel, rhs: DapiBankMetadataModel) -> Bool {
        return lhs.bankName == rhs.bankName
    }
}
