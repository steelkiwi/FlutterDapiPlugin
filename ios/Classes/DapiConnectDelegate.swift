import Foundation
import Flutter
import DapiConnect

class DapiConnectDelegate: NSObject {
    private var pendingResult: FlutterResult?
    
    let appKey = "7805f8fd9f0c67c886ecfe2f48a04b548f70e1146e4f3a58200bec4f201b2dc4"

    lazy var client: DapiClient = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api-lune.dev.steel.kiwi"
        urlComponents.port = 4041
        let configs = DapiConfigurations(appKey: appKey,
                                         baseUrl: urlComponents,
                                         countries: ["AE"],
                                         clientUserID: "testUser")
        configs.environment = .sandbox
        configs.isExperimental = false

        let client = DapiClient(configurations: configs)
        client.connect.delegate = self
        client.autoFlow.connectDelegate = self
        return client
    }()
    
    func executeAction(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        pendingResult = result
        switch Action(rawValue: call.method) {
        case .connect: connect(call)
        case .activeConnection: activeConenction(call)
        case .userAccounts: userAccounts(call)
        case .userAccountsMetaData: userAccountsMetaData(call)
        case .beneficiaries: beneficiaries(call)
        case .createBeneficiary: createBeneficiary(call)
        case .createTransfer: createTransfer(call)
        case .release: release(call)
        case .delink: delink(call)
        default: finishWithError(errorMessage: "Wrong method: \(call.method)")
        }
    }

    func connect(_ call: FlutterMethodCall) {
        client.connect.present()
    }
    
    func activeConenction(_ call: FlutterMethodCall) {
//        guard let result = client.connect.getConnections(), !result.isEmpty else { // Where the fucking docs?
//            finishWithError(errorMessage: "Get connection error")
//            return
//        }
//        finishActiveConnectionWithSuccess(connections: result)
    }

    func userAccounts(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.data

//        dapiClient.data.	({ finishCurrentAccountWithSuccess(it); }
//        ) { error ->
//            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
//            finishWithError(error.type.toString(), errorMessage)
//        }
    }

    func userAccountsMetaData(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.metadata.getAccountMetadata { [weak self] bankMetadata, error, string in
            guard let metaData = bankMetadata, error == nil else {
                self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                return
            }
            self?.finishCurrentAccountMetaDataWithSuccess(metaData: metaData)
        }
    }

    func beneficiaries(_ call: FlutterMethodCall) {
//        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
//        pendingResult = result
//        sourcePath?.let { dapiClient.setUserID(it) };
//        dapiClient.payment.getBeneficiaries(
//                { benefs ->
//                    finishBeneficiariesWithSuccess(benefs);
//                }
//        ) { error ->
//            val errorMessage: String = if (error.msg == null) "Get accounts error" else error.msg!!;
//            finishWithError(error.type.toString(), errorMessage)
//        }
    }

    func createBeneficiary(_ call: FlutterMethodCall) {
//        val sourcePath = call.argument<String>(Consts.PARAMET_USER_ID);
//        val addressLine1 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES1);
//        val addressLine2 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES2);
//        val addressLine3 = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_LINE_ADDRES3);
//        val accountNumber = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_ACCOUNT_NUMBER);
//        val accountName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_NAME);
//        val bankName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BANK_NAME);
//        val swiftCode = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_SWIFT_CODE);
//        val iban = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_IBAN);
//        val country = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_COUNTRY);
//        val branchAddress = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BRANCH_ADDRESS);
//        val branchName = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_BRANCH_NAME);
//        val phone = call.argument<String>(Consts.PARAMET_CREATE_BENEFICIARY_PHONE_NUMBER);
//
//        sourcePath?.let { dapiClient.setUserID(it) };
//
//        pendingResult = result
//        dapiClient.payment
//
//
//        val lineAddress = LinesAddress()
//        lineAddress.line1 = addressLine1
//        lineAddress.line2 = addressLine2
//        lineAddress.line3 = addressLine3
//        val info = DapiBeneficiaryInfo(
//                linesAddress = lineAddress,
//                accountNumber = accountNumber,
//                name = accountName,
//                bankName = bankName,
//                swiftCode = swiftCode,
//                iban = iban,
//                country = country,
//                branchAddress = branchAddress,
//                branchName = branchName,
//                phoneNumber = phone
//        )
//
//        dapiClient.payment.createBeneficiary(info, onSuccess = {
//            finishCreateBeneficiariesWithSuccess(it)
//            print("")
//        }, onFailure = {
//            val errorMessage: String = if (it.msg == null) "Get accounts error" else it.msg!!;
//            finishWithError(it.type.toString(), errorMessage)
//        })
    }

    func createTransfer(_ call: FlutterMethodCall) {
        guard let beneficiaryId: String = call.argument(key: Param.beneficiaryId.rawValue),
            let accountId: String = call.argument(key: Param.accountId.rawValue),
            let userId: String = call.argument(key: Param.userId.rawValue),
            let amount: NSNumber = call.argument(key: Param.amount.rawValue)
             else {
                finishWithError(errorMessage: "Invalid arguments")
                return
        }
//        let remark: String? = call.argument(key: Param.transferRemark.rawValue)
        client.userID = userId
        client.payment.createTransfer(withSenderID: accountId,
                                      amount: amount,
                                      toReceiverID: beneficiaryId,
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                                            return
                                        }
                                        self?.finishCreateTransferWithSuccess(beneficiaries: result)
            })
    }

    func release(_ call: FlutterMethodCall) {
//        client.connect.release() // ???
    }

    func delink(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.auth.delinkUser { [weak self] result, error in
            guard let result = result, error == nil else {
                self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                return
            }
            self?.finishDelinkWithSuccess(beneficiaries: result)
            self?.finishWithSuccess(userID: userId)
        }
    }

    private enum Action: String {
      case connect = "dapi_connect"
      case activeConnection = "dapi_active_connection"
      case userAccounts = "dapi_user_accounts"
      case userAccountsMetaData = "dapi_user_accounts_meta_data"
      case beneficiaries = "dapi_beneficiaries"
      case createBeneficiary = "dapi_create_beneficiary"
      case createTransfer = "dapi_create_transfer"
      case release = "dapi_release"
      case delink = "dapi_delink"
    }

    private enum Param: String {
      case amount = "param_amount"
      case userId = "user_id"
      case beneficiaryId = "beneficiary_id"
      case accountId = "account_id"
      case transferRemark = "transfer_remark"
    }
}

extension DapiConnectDelegate: DPCConnectDelegate {
       func connectDidSuccessfullyConnect(toBankID bankID: String, userID: String) {
        pendingResult?.self(userID)

    }
    
    func connectDidFailConnecting(toBankID bankID: String, withError error: String) {
        print("connectDidFailConnecting")
    }
    
    func connectBeneficiaryInfoForBank(withID bankID: String, beneficiaryInfo info: @escaping (DapiBeneficiaryInfo?) -> Void) {
        print("connectBeneficiaryInfoForBank")
        let linesAddress=DapiLinesAddress();
        linesAddress.line1="xxx";
        linesAddress.line2="xxx";
        linesAddress.line3="xxx";
        let beneficiaryInfo=DapiBeneficiaryInfo();
        beneficiaryInfo.linesAddress=linesAddress;
        beneficiaryInfo.accountNumber = "xxxxxxxxx";
        beneficiaryInfo.name = "xxxxx";
        beneficiaryInfo.bankName = "xxxx";
        beneficiaryInfo.swiftCode = "xxxxx";
        beneficiaryInfo.iban = "xxxxxxxxxxxxxxxxxxxxxxxxx";
        beneficiaryInfo.country = "UNITED ARAB EMIRATES";
        beneficiaryInfo.branchAddress = "branchAddress";
        beneficiaryInfo.branchName = "branchName";
        beneficiaryInfo.phoneNumber = "xxxxxxxxxxx";
        

        info(beneficiaryInfo)

    }
    
    func connectDidProceed(withBankID bankID: String, userID: String) {
        print("connectDidProceed")

    }
    

}

private extension DapiConnectDelegate {
    func defaulrBeneficiaryInfo() -> DapiBeneficiaryInfo {
        let lineAddress = DapiLinesAddress()
        lineAddress.line1 = "line1"
        lineAddress.line2 = "line2"
        lineAddress.line3 = "line3"

        let info = DapiBeneficiaryInfo()
        info.linesAddress = lineAddress
        info.accountNumber = "xxxxxxxxx"
        info.name = "xxxxx"
        info.bankName = "xxxx"
        info.swiftCode = "xxxxx"
        info.iban = "xxxxxxxxxxxxxxxxxxxxxxxxx"
        info.country = "UNITED ARAB EMIRATES"
        info.branchAddress = "branchAddress"
        info.branchName = "branchName"
        info.phoneNumber = "xxxxxxxxxxx"

        return info
    }
    
    private func finishActiveConnectionWithSuccess(connections: [DapiConnectionDetails]) {
//        val json = Gson().toJson(connections)
//        if (pendingResult != null) {
//            uiThreadHandler.post {
//                pendingResult!!.success(json)
//                clearMethodCallAndResult()
//            };
//        }
    }

    private func finishCurrentAccountMetaDataWithSuccess(metaData: DapiBankMetadata) {
        guard let result = pendingResult else { return }
        let json = getJson(from: [
            "bankName": metaData.bankName,
            "branchAddress": metaData.branchAddress,
            "branchName": metaData.branchName,
            "swiftCode": metaData.swiftCode,
            "isCreateBeneficairyEndpointRequired": metaData.isCreateBeneficairyEndpointRequired
            // ...

        ])
        result(json)
        clearMethodCallAndResult()
    }

    private func finishCreateTransferWithSuccess(beneficiaries: DapiResult) {
        guard let result = pendingResult, let json = beneficiaries.toJson() else { return }
        result(json)
        clearMethodCallAndResult()
    }
    
    private func finishDelinkWithSuccess(beneficiaries: DapiResult) {
        guard let result = pendingResult, let json = beneficiaries.toJson() else { return }
        result(json)
        clearMethodCallAndResult()
    }

    private func finishWithSuccess(userID: String) { // TODO: async
        guard let result = pendingResult else { return }
        result(userID)
        clearMethodCallAndResult()
    }

    private func finishWithError(errorCode: String? = nil, errorMessage: String, details: Any? = nil) {
        guard let result = pendingResult else { return }
        result(FlutterError(code: errorCode ?? "-1",
                            message: errorMessage,
                            details: nil))
        clearMethodCallAndResult()
    }

    private func clearMethodCallAndResult() {
        pendingResult = nil
    }
}

extension FlutterMethodCall {
    func argument<Type>(key: String) -> Type? {
        guard let args = arguments as? [String: Any] else { return nil }
        return args[key] as? Type
    }
}

extension DapiResult {
    func toJson() -> String? {
        return getJson(from: [
            "jobId": jobID,
            "status": status,
            "success": success,
            "message": message
        ])
    }
}

fileprivate func getJson(from dictionary: [String: Any]) -> String? {
    guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
    return String(data: jsonData, encoding: String.Encoding.utf8)
}
