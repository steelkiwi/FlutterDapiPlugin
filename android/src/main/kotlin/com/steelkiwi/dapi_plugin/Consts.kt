package com.steelkiwi.dapi_plugin

class Consts {
    companion object {
        final val HEADER_KEY_PAYMENT_ID = "Dapi-Payment";
        final val HEADER_KEY_PAYMENT_LUN = "Dapi-Account";
        final val HEADER_VALUE_PAYMENT_ID = "header_payment_id"


        final val PARAMET_AMOUNT = "param_amount"
        final val PARAMET_DAPI_ACCESS_ID = "user_id"
        final val PARAMET_LUN_PAYMENT_ID = "lun_payment_id"
        final val PARAMET_BENEFICIARY_ID = "beneficiary_id"
        final val PARAMET_ACCOUNT_ID = "account_id"
        final val PARAMET_REMARK = "transfer_remark"
        final val PARAMET_IBAN = "iban"
        final val PARAMET_NAME = "name"
        final val PARAMET_ACCOUNT_NUMBER = "account_number"


        final val PARAMET_ENVIRONMENT = "dapi_environment"
        final val ENVIRONMENT_PRODUCTION = "production"
        final val ENVIRONMENT_SANDBOX = "sandbox"
        final val PARAM_HOST = "PARAM_HOST";
        final val PARAM_PORT = "PARAM_PORT";
        final val PARAM_APP_KEY = "PARAM_APP_KEY";


        final val PARAMET_CREATE_BENEFICIARY_LINE_ADDRES1 = "create_beneficiary_line_addres1"
        final val PARAMET_CREATE_BENEFICIARY_LINE_ADDRES2 = "create_beneficiary_line_addres2"
        final val PARAMET_CREATE_BENEFICIARY_LINE_ADDRES3 = "create_beneficiary_line_addres3"
        final val PARAMET_CREATE_BENEFICIARY_ACCOUNT_NUMBER = "create_beneficiary_account_number"
        final val PARAMET_CREATE_BENEFICIARY_NAME = "create_beneficiary_name"
        final val PARAMET_CREATE_BENEFICIARY_BANK_NAME = "create_beneficiary_bank_name"
        final val PARAMET_CREATE_BENEFICIARY_SWIFT_CODE = "create_beneficiary_swift_code"
        final val PARAMET_CREATE_BENEFICIARY_IBAN = "create_beneficiary_iban"
        final val PARAMET_CREATE_BENEFICIARY_COUNTRY = "create_beneficiary_country"
        final val PARAMET_CREATE_BENEFICIARY_BRANCH_ADDRESS = "create_beneficiary_branch_address"
        final val PARAMET_CREATE_BENEFICIARY_BRANCH_NAME = "create_beneficiary_branch_name"
        final val PARAMET_CREATE_BENEFICIARY_PHONE_NUMBER = "create_beneficiary_phone_number"

    }
}