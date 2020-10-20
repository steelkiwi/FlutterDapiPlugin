//
//  ParamsConst.swift
//  dapi
//
//  Created by Dmitro Serdun on 18.09.2020.
//



struct Headers {
    static let transactionPaymentId = "header_payment_id";
}

struct Constants {
    static let ENVIRONMENT_PRODUCTION = "production"
    static let ENVIRONMENT_SANDBOX = "sandbox"
    
}

struct ConstantsMessage {
    static let  CLIENT_IS_NULL: String = "Dapi client hasn't inited";
    static let  CLIENT_IS_NULL_CODE: String = "client_null";
    static let  I_BAN_NULL: String = "iBan id is null";
    static let  RECEIVER_ACCOUNT_NUMBER_NULL: String = "Receiver account number id is null";
    static let  RECEIVER_NAME_NULL: String = "iBan id is null";
    static let  BENEFICIARY_ID_NULL: String = "Beneficiary id is null";
    static let  AMOUNT_IS_NULL: String = "Amount is null";
    static let  CURRENT_CONNECTION_ID_NULL: String = "Current connection id is null";
    static let  ACCOUNT_ID_NULL: String = "Bank account id is null";
    static let  VALIDATION_BY_NULL: String = "field_null"
    static let  SOMETHING_HAPPENED_DAPI_RESPONSE: String = "Something happened with DAPI"


    static let  APP_KEY_NULL = "App key can't be null";
    static let  HOST_NULL = "HOST can't be null";
    static let  PORT_NULL = "PORT can't be null";
    static let  ENV_NULL = "Env  can't be null"

    
}

struct ConstParameters{
      static let currentConnectId = "user_id";

      static let environmentType = "dapi_environment";
      static let environmentHost = "PARAM_HOST";
      static let environmentPort = "PARAM_PORT";
      static let environmentAppKey = "PARAM_APP_KEY";

      static let iBan = "iBan_iserdun";
      static let accountNumber = "accountNumber_iserdun";
      static let phoneNumber = "phone_number_iserdun";
      static let swiftCode = "swift_coder_iserdun";
      static let country = "country_iserdun";


      static let transactionAmount = "param_amount";
      static let transactionBeneficiaryId = "beneficiary_id";
      static let transactionBankAccountId = "account_id";
      static let transactionRemark = "transfer_remark";
      static let transactionReceiverName = "receiver_name";

      static let beneficiaryAddressLine1 = "create_beneficiary_line_addres1";
      static let beneficiaryAddressLine2 = "create_beneficiary_line_addres2";
      static let beneficiaryAddressLine3 = "create_beneficiary_line_addres3";
      static let beneficiaryName = "create_beneficiary_name";
      static let beneficiaryBankName = "create_beneficiary_bank_name";
      static let beneficiaryBranchAddress = "create_beneficiary_branch_address";
      static let beneficiaryBranchName = "create_beneficiary_branch_name";
    
    
    
    
}
