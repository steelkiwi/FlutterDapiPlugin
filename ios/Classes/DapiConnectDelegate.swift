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
        case .connect: connect(call)//implemented
        case .activeConnection: activeConenction(call)//implemented
        case .connectionAccounts: connectionAccounts(call)//implemented
        case .userAccountsMetaData: userAccountsMetaData(call)//implemented
        case .beneficiaries: beneficiaries(call)//implemented
        case .createBeneficiary: createBeneficiary(call)
        case .createTransfer: createTransfer(call)//implemented
        case .delink: delink(call)
        default: finishWithError(errorMessage: "Wrong method: \(call.method)")
        }
    }

    func connect(_ call: FlutterMethodCall) {
        client.connect.present()
        
    }
    
    func activeConenction(_ call: FlutterMethodCall) {
        let result = client.connect.getConnections();
        var connectionsModel=[ConnectionModel]();
        if(!result.isEmpty){
            for i in 0...result.count-1 {
                let it=result[i];
                var accounts=[SubAccountModel]();
                
                if(!it.accounts.isEmpty){
                for j in 0...it.accounts.count-1 {
                    let accountItem=it.accounts[j];
                    let subAccountModel=SubAccountModel(currency:CurrencyModel(unit: accountItem.currency.name, value: accountItem.currency.code) , iban: accountItem.iban, id: accountItem.accountID, isFavourite: accountItem.isFavourite, name: accountItem.name, number: accountItem.number, type: accountItem.type);
                    accounts.append(subAccountModel)
                    }}

                let connectionModel=ConnectionModel(
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
            pendingResult?.self(getJsonFromModel(from:connectionsModel))
        }else{
            pendingResult?.self(getJsonFromModel(from:connectionsModel))
        }

    }

    func connectionAccounts(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.data.getAccounts { [weak self] result, error, string in
            let dapiAccounts:[DapiAccount]?=result;
            var accounts=[SubAccountModel]();
            
            if let dapiAccounts = dapiAccounts {
            for j in 0...dapiAccounts.count-1 {
                   let accountItem=dapiAccounts[j];
                   let subAccountModel=SubAccountModel(currency:CurrencyModel(unit: accountItem.currency.name, value: accountItem.currency.code) , iban: accountItem.iban, id: accountItem.accountID, isFavourite: accountItem.isFavourite, name: accountItem.name, number: accountItem.number, type: accountItem.type);
                   accounts.append(subAccountModel)
                   }
                let jsonConnections =  getJsonFromModel(from:accounts)
                self?.pendingResult?.self(jsonConnections)
            }
           
        }
        
       
       
    
    }

    func userAccountsMetaData(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.metadata.getAccountMetadata { [weak self] bankMetadata, error, string in
            guard let bankMetadata = bankMetadata, error == nil else {
                self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                return
            }
            let address=AddressModel(line1: bankMetadata.linesAddress.line1, line2:bankMetadata.linesAddress.line1, line3: bankMetadata.linesAddress.line1);
               
            let coolDownPeriod=CoolDownPeriodModel(unit: "", value: 24)
               
            let dapiBankMetaData = DapiBankMetadataModel(
                   bankName: bankMetadata.bankName,
                   coolDownPeriod: coolDownPeriod,
                   country: CountryModel(name: bankMetadata.country.name, code: bankMetadata.country.code),
                   branchAddress: bankMetadata.branchAddress,
                   branchName:bankMetadata.branchName,
                   isCreateBeneficiaryRequired: bankMetadata.isCreateBeneficairyEndpointRequired,
                   swiftCode:bankMetadata.swiftCode,
                   address: address
                   );
               
            let jsonConnections =  getJsonFromModel(from:dapiBankMetaData)
            self?.pendingResult?.self(jsonConnections)        }
    }

    func beneficiaries(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
                  finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
                  return}
        client.userID = userId
        client.payment.getBeneficiaries { (beneficiary:[DapiBeneficiary]?, Error, String) in
            if let beneficiary = beneficiary {
                var beneficiaries=[BeneficiaryModel]();
                    for j in 0...beneficiary.count-1 {
                           let beneficiaryItem=beneficiary[j];
                        var beneficiary=BeneficiaryModel(accountNumber: beneficiaryItem.accountNumber, iban: beneficiaryItem.iban, id: beneficiaryItem.accountID, name:beneficiaryItem.name, status: beneficiaryItem.status, type: beneficiaryItem.type)
                        
                           beneficiaries.append(beneficiary)
                           }
                        let jsonConnections =  getJsonFromModel(from:beneficiaries)
                self.pendingResult?.self(jsonConnections)
                    
                   }}
        
    }

    
//    val userId = call.argument<String>(Consts.PARAMET_USER_ID);


    func createBeneficiary(_ call: FlutterMethodCall) {
        guard let result = pendingResult else { return }

        guard let userId: String = call.argument(key: Param.userId.rawValue),
        let addressLine1: String = call.argument(key: ParamBeneficiary.addressLine1.rawValue),
        let addressLine2: String = call.argument(key: ParamBeneficiary.addressLine2.rawValue),
        let addressLine3: String = call.argument(key: ParamBeneficiary.addressLine3.rawValue),
        let accountNumber: String = call.argument(key: ParamBeneficiary.accountNumber.rawValue),
        let accountName: String = call.argument(key: ParamBeneficiary.accountName.rawValue),
        let bankName: String = call.argument(key: ParamBeneficiary.bankName.rawValue),
        let swiftCode: String = call.argument(key: ParamBeneficiary.swiftCode.rawValue),
        let iban: String = call.argument(key: ParamBeneficiary.iban.rawValue),
        let country: String = call.argument(key: ParamBeneficiary.country.rawValue),
        let branchAddress: String = call.argument(key: ParamBeneficiary.branchAddress.rawValue),
        let branchName: String = call.argument(key: ParamBeneficiary.branchName.rawValue),
        let phone: String = call.argument(key: ParamBeneficiary.phone.rawValue)
        else {
                      finishWithError(errorMessage: "Invalid arguments")
            return
            
        }
        
        let linesAddress=DapiLinesAddress();
              linesAddress.line1=addressLine1;
              linesAddress.line2=addressLine2;
              linesAddress.line3=addressLine3;
              let beneficiaryInfo=DapiBeneficiaryInfo();
              beneficiaryInfo.linesAddress=linesAddress;
              beneficiaryInfo.accountNumber = accountNumber;
              beneficiaryInfo.name = accountName;
              beneficiaryInfo.bankName = bankName;
              beneficiaryInfo.swiftCode = swiftCode;
              beneficiaryInfo.iban = iban;
              beneficiaryInfo.country = country;
              beneficiaryInfo.branchAddress = branchAddress;
              beneficiaryInfo.branchName = branchName;
              beneficiaryInfo.phoneNumber = phone;
        
        
        client.payment.createBeneficiary(with: beneficiaryInfo) { (response : DapiResult?, Error, String) in
        
            if let response = response {
            let response:DapiResultModel=DapiResultModel(jobID:response.jobID,status:response.status,success:response.success)
            result.self(getJsonFromModel(from:response))
            } }

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
        client.userID = userId
        client.payment.createTransfer(withSenderID: accountId,
                                      amount: amount,
                                      toReceiverID: beneficiaryId,
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                                            return
                                        }
                                        
                                        let response:DapiResultModel=DapiResultModel(jobID:result.jobID,status:result.status,success:result.success)
                                        self?.pendingResult?.self(getJsonFromModel(from:response))

                                        
                                       
                                        
                                        
                                        
                                        
                                        
            })
    }


    func delink(_ call: FlutterMethodCall) {
        guard let userId: String = call.argument(key: Param.userId.rawValue) else {
            finishWithError(errorMessage: "Parameter \(Param.userId) doesn't exists.")
            return
        }
        client.userID = userId
        client.auth.delinkUser { [weak self] response, error in
            guard let response = response, error == nil else {
                self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                return
            }
            let successDelinkModel:DapiResultModel=DapiResultModel(jobID:response.jobID,status:response.status,success:response.success)
            self?.pendingResult?.self(getJsonFromModel(from:successDelinkModel))


        }
    }

}

extension DapiConnectDelegate: DPCConnectDelegate {
       func connectDidSuccessfullyConnect(toBankID bankID: String, userID: String) {
        
        let jsonConnections =  getJsonFromModel(from:userID)
        self.pendingResult?.self(jsonConnections)
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



fileprivate func getJsonFromModel<T: Encodable>(from model: T) -> String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try! encoder.encode(model)
    return String(data: data, encoding: .utf8)!

    }



extension FlutterMethodCall {
    func argument<Type>(key: String) -> Type? {
        guard let args = arguments as? [String: Any] else { return nil }
        return args[key] as? Type
    }
}
