//
//  ParamsConst.swift
//  dapi
//
//  Created by Dmitro Serdun on 18.09.2020.
//

import Foundation
 enum Param: String {
  case amount = "param_amount"
  case userId = "user_id"
  case beneficiaryId = "beneficiary_id"
  case accountId = "account_id"
  case transferRemark = "transfer_remark"
  case headerPaymentId = "header_payment_id"
  case environmentType = "dapi_environment"

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
