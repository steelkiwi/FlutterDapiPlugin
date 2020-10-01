//
//  Actions.swift
//  dapi
//
//  Created by Dmitro Serdun on 18.09.2020.
//



import Foundation
enum Action: String {
     case connect = "dapi_connect"
     case activeConnection = "dapi_active_connection"
     case connectionAccounts = "dapi_connection_accounts"
     case bankMetaData = "dapi_user_accounts_meta_data"
     case beneficiaries = "dapi_beneficiaries"
     case createBeneficiary = "dapi_create_beneficiary"
     case createTransfer = "dapi_create_transfer"
     case delink = "dapi_delink"
     case initEnvironment = "dapi_connect_set_environment"
    
    

    
   }
