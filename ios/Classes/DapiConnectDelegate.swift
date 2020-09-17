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
        let result = client.connect.getConnections();
        
        
        if(!result.isEmpty){
            finishActiveConnectionWithSuccess(connections: result)
        }
            
//            !result.isEmpty else { // Where the fucking docs?
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
        client.data.getAccounts { [weak self] result, error, string in
            print("");
        }

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
        print(finishActiveConnectionWithSuccess);
        var connectionsModel=[ConnectionModel]();
        var connectionsJson: [String] = []
        for i in 0...connections.count-1 {
            var it=connections[i];
            var accounts=[SubAccountModel]();
            
            if(!it.accounts.isEmpty){
            for j in 0...it.accounts.count-1 {
                var accountItem=it.accounts[j];
                var subAccountModel=SubAccountModel(currency:PairModel(unit: accountItem.currency.name, value: accountItem.currency.code) , iban: accountItem.iban, id: accountItem.accountID, isFavourite: accountItem.isFavourite, name: accountItem.name, number: accountItem.number, type: accountItem.type);
                accounts.append(subAccountModel)
                }}

            var connectionModel=ConnectionModel(
                bankID:it.bankID,
                clientUserID: it.clientUserID,
                coolDownPeriod:CoolDownPeriodModel(unit: "", value:it.beneficiaryCoolDownPeriod),
                country: it.countryName,
                fullBankName: it.bankName,
                isCreateBeneficiaryRequired: it.isCreateBeneficiaryEndpointRequired,
                userID: it.userID,
                subAccounts:accounts)
            
            connectionsModel.append(connectionModel)
                        
        }
        
        var jsonConnections =  getJsonFromModel(from:connectionsModel)
        pendingResult?.self(jsonConnections)
 
        
        
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
        
        var address=AddressModel(line1: metaData.linesAddress.line1, line2:metaData.linesAddress.line1, line3: metaData.linesAddress.line1);
        
        var coolDownPeriod=CoolDownPeriodModel(unit: "", value: 24)
        
        var dapiBankMetaData = DapiBankMetadataModel(
            bankName: metaData.bankName,
            coolDownPeriod: coolDownPeriod,
            country: PairModel(unit: metaData.country.name, value: metaData.country.code),
            isCreateBeneficiaryRequired: metaData.isCreateBeneficairyEndpointRequired,
            swiftCode:metaData.swiftCode,
            address: address
            );
        
     var jsonConnections =  getJsonFromModel(from:dapiBankMetaData)
     pendingResult?.self(jsonConnections)
//        resultFr(json)
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
//    guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return nil }
//    return String(data: jsonData, encoding: String.Encoding.utf8)
//    let jsonEncoder = JSONEncoder()
//    let jsonData = try jsonEncoder.encode(dictionary)
//    let json = String(data: jsonData, encoding: String.Encoding.utf16)
//    // Decode
//    let jsonDecoder = JSONDecoder()
//    let json = try jsonDecoder.decode([dictionary: value].self, from: jsonData)
    return ""
}

//let jsonEncoder = JSONEncoder()
//let jsonData = try jsonEncoder.encode(dog)
//let json = String(data: jsonData, encoding: String.Encoding.utf16)
//// Decode
//let jsonDecoder = JSONDecoder()
//let secondDog = try jsonDecoder.decode(Dog.self, from: jsonData)
fileprivate func getJsonFromModel<T: Encodable>(from model: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(model)
    return String(data: data, encoding: .utf8)!

    }


