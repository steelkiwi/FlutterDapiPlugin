//
//  AuthStateModel.swift
//  dapi
//
//  Created by Dmitro Serdun on 29.09.2020.
//

import Foundation
struct AuthStateModel:Codable{
    var accessId:String?
    var status:String?
    var bankId:String?
    var error:String?

 
}



extension AuthStateModel : Equatable{
    static func == (lhs: AuthStateModel, rhs: AuthStateModel) -> Bool {
        return lhs.accessId == rhs.accessId
    }
}
