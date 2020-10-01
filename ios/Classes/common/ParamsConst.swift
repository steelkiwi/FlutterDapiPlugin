//
//  ParamsConst.swift
//  dapi
//
//  Created by Dmitro Serdun on 18.09.2020.
//

//final val PARAMET_ENVIRONMENT = "dapi_environment"
//       final val ENVIRONMENT_PRODUCTION = "production"
//       final val ENVIRONMENT_SANDBOX = "sandbox"
//       final val PARAM_HOST = "PARAM_HOST";
//       final val PARAM_PORT = "PARAM_PORT";
//       final val PARAM_APP_KEY = "PARAM_APP_KEY";
struct Constants {
    static let ENVIRONMENT_PRODUCTION = "production"
    static let ENVIRONMENT_SANDBOX = "sandbox"
    
}

import Foundation
 enum Param: String {
  case amount = "param_amount"
  case userId = "user_id"
  case beneficiaryId = "beneficiary_id"
  case accountId = "account_id"
  case transferRemark = "transfer_remark"
  case headerPaymentId = "header_payment_id"
  case environmentType = "dapi_environment"
  case host = "PARAM_HOST"
  case port = "PARAM_PORT"
  case app_key = "PARAM_APP_KEY"

    
    

}



 enum ParamBeneficiary: String {
  case addressLine1 = "create_beneficiary_line_addres1"
  case addressLine2 = "create_beneficiary_line_addres2"
  case addressLine3 = "create_beneficiary_line_addres3"
  case accountNumber = "create_beneficiary_account_number"
  case accountName = "create_beneficiary_name"
  case bankName = "create_beneficiary_bank_name"

  case swiftCode = "create_beneficiary_swift_code"
  case iban = "create_beneficiary_iban"
  case country = "create_beneficiary_country"
  case branchAddress = "create_beneficiary_branch_address"
  case branchName = "create_beneficiary_branch_name"
  case phone = "create_beneficiary_phone_number"


}
