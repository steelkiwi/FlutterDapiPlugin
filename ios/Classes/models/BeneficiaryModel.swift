//
//  BeneficiaryModel.swift
//  dapi
//
//  Created by Dmitro Serdun on 17.09.2020.
//

import Foundation

struct BeneficiaryModel:Codable{
    var accountNumber:String?
    var iban:String?
    var id:String?
    var name:String?
    var status:String?
    var type:String?

}


extension BeneficiaryModel : Equatable{
    static func == (lhs: BeneficiaryModel, rhs: BeneficiaryModel) -> Bool {
        return lhs.id == rhs.id
    }
}
