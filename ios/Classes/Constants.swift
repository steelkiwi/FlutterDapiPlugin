enum ActionChanel: String {
  case connect = "dapi_connect"
  case activeConnection = "dapi_active_connection"
  case userAccounts = "dapi_user_accounts"
  case userAccountsMetaData = "dapi_user_accounts_meta_data"
  case beneficiaries = "dapi_beneficiaries"
  case createBeneficiary = "dapi_create_beneficiary"
  case createTransfer = "dapi_create_transfer"
  case release = "dapi_release"
  case delink = "dapi_delink"

  var channel: String { "plugins.steelkiwi.com/dapi" }
}


enum Param: String {
  case amount = "param_amount"
  case userId = "user_id"
  case beneficiaryId = "beneficiary_id"
  case accountId = "account_id"
  case transferRemark = "transfer_remark"
}

enum CreateBeneficiary: String {
  case line_addres1 = "create_beneficiary_line_addres1"
  case line_addres2 = "create_beneficiary_line_addres2"
  case line_addres3 = "create_beneficiary_line_addres3"
  case account_number = "create_beneficiary_account_number"
  case beneficiary_name = "create_beneficiary_name"
  case bank_name = "create_beneficiary_bank_name"
  case swift_code = "create_beneficiary_swift_code"
  case iban = "create_beneficiary_iban"
  case country = "create_beneficiary_country"
  case branch_address = "create_beneficiary_branch_address"
  case branch_name = "create_beneficiary_branch_name"
  case phone_number = "create_beneficiary_phone_number"
}
