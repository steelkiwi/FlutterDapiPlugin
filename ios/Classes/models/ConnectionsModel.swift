//
//  SubAccountModel.swift
//  dapi
//
//  Created by Dmitro Serdun on 17.09.2020.
//


import Foundation

struct ConnectionModel:Codable{
    var bankID:String?
    var clientUserID:String?
    var coolDownPeriod:CoolDownPeriodModel
    var country:String?
    var fullBankName:String?
    var isCreateBeneficiaryRequired:Bool?
    var userID:String?
    var subAccounts:[SubAccountModel]
}


extension ConnectionModel : Equatable{
    static func == (lhs: ConnectionModel, rhs: ConnectionModel) -> Bool {
        return lhs.userID == rhs.userID
    }
}


struct SubAccountModel:Codable{
    var currency:CurrencyModel?
    var iban:String
    var id:String
    var isFavourite:Bool
    var name:String
    var number:String
    var type:String
    
    init( currency:CurrencyModel?,
        iban:String,
        id:String,
        isFavourite:Bool,
        name:String,
        number:String,
        type:String) {
        self.currency=currency
        self.iban=iban
        self.id=id
        self.isFavourite=isFavourite
        self.name=name
        self.number=number
        self.type=type
    }
}


struct CurrencyModel:Codable{
    var unit:String
    var value:String
}

struct CountryModel:Codable{
    var name:String
    var code:String
   
}







