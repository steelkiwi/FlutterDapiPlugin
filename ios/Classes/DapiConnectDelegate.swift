import Foundation
import Flutter
import DapiConnect

class DapiConnectDelegate: NSObject {
    private var pendingResult: FlutterResult?
    private var loginEvent: FlutterEventSink?
    
    private var client: DapiClient?
    
   
    func executeAction(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        pendingResult = result
        if call.method == Action.initEnvironment.rawValue {
            initEnvironment(call)
        } else {
            if client != nil{
                    switch Action(rawValue: call.method) {
                        case .activeConnection: activeConenction(call,client: client!)//implemented
                        case .connectionAccounts: connectionAccounts(call,client: client!)//implemented
                        case .bankMetaData: bankMetaData(call,client: client!)//implemented
                        case .beneficiaries: beneficiaries(call,client: client!)//implemented
                        case .createBeneficiary: createBeneficiary(call,client: client!)
                        case .createTransfer: createTransfer(call,client: client!)//implemented
                        case .delink: delink(call,client: client!)
                    default: finishWithError(errorMessage: "Wrong method: \(call.method)")
            }}else{
            finishWithError(errorMessage: "Dapi client hasn't inited")
        }}
    }

    func initEnvironment(_ call: FlutterMethodCall) {
        let client = DapiClient(configurations: getDapiConfig())
               client.connect.delegate = self
               client.autoFlow.connectDelegate = self
    }
    
    func clear(){
        self.loginEvent=nil;
    }


    func getDapiConfig(paymentId: String? = nil,env: DPCAppEnvironment=DPCAppEnvironment.production) ->  DapiConfigurations {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"

        urlComponents.host = (env==DPCAppEnvironment.production) ? "api-lune.stg.steel.kiwi":"api-lune.dev.steel.kiwi";
        urlComponents.port = 4041


        let configs = DapiConfigurations(appKey: (env==DPCAppEnvironment.sandbox) ? appKeyDev:appKeyProd,
                                         baseUrl: urlComponents,
                                         countries: ["AE"],
                                         clientUserID: "testUser")
        configs.environment = env
        configs.isExperimental = false
        if let paymentId = paymentId {
            configs.endPointExtraHeaderFields=[DPCEndPoint.createTransfer:["Dapi-Payment":paymentId]];
            configs.endPointExtraHeaderFields=[DPCEndPoint.resumeJob:["Dapi-Payment":paymentId]];

          }


        return configs;
    }
    
    
    
    
    
    
    

    func connect(eventSink : FlutterEventSink?) {
        guard let eventSink = eventSink else {
             return
           }
        if client != nil {
                loginEvent=eventSink;
                client!.connect.present()
            }else {
                eventSink(FlutterError(code:  "-1",
                                    message: "Dapi client hasn't inited",
                                    details: nil))
            }
        
    }
    
    func activeConenction(_ call: FlutterMethodCall,client:DapiClient) {
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

    func connectionAccounts(_ call: FlutterMethodCall,client:DapiClient) {
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

    func bankMetaData(_ call: FlutterMethodCall,client:DapiClient) {
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
            let result:DapiBankMetadata=bankMetadata;
            
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

    func beneficiaries(_ call: FlutterMethodCall,client:DapiClient) {
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

    


    func createBeneficiary(_ call: FlutterMethodCall,client:DapiClient) {
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

    func createTransfer(_ call: FlutterMethodCall,client:DapiClient) {
        guard let beneficiaryId: String = call.argument(key: Param.beneficiaryId.rawValue),
            let accountId: String = call.argument(key: Param.accountId.rawValue),
            let userId: String = call.argument(key: Param.userId.rawValue),
            let amount: NSNumber = call.argument(key: Param.amount.rawValue)
             else {
                finishWithError(errorMessage: "Invalid arguments")
                return
        }
        
        let paymentId: String? = call.argument(key: Param.headerPaymentId.rawValue)
        //todo chna
        //client.configurations=getDapiConfig(paymentId: paymentId,env: client.configurations.environment);
        client.userID = userId
        client.payment.createTransfer(withSenderID: accountId,
                                      amount: amount,
                                      toReceiverID: beneficiaryId,
                                      
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
//                                            client.configurations=self!.getDapiConfig(paymentId: nil,env: self!.client.configurations.environment);
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                                            return
                                        }
                                        
                                        let response:DapiResultModel=DapiResultModel(jobID:result.jobID,status:result.status,success:result.success)
//                                      client.configurations=self!.getDapiConfig(paymentId: nil,env: self!.client.configurations.environment);                                        self?.pendingResult?.self(getJsonFromModel(from:response))

                                        
                                       
                                        
                                        
                                        
                                        
                                        
            })
    }


    func delink(_ call: FlutterMethodCall,client:DapiClient) {
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
        guard loginEvent != nil else { return }
        let result =  getJsonFromModel(from:AuthStateModel(accessId: userID, status: "SUCCESS"))
        self.loginEvent?.self(result)
    }
    
    func connectDidFailConnecting(toBankID bankID: String, withError error: String) {
        let result =  getJsonFromModel(from:AuthStateModel(status: "FAILURE"))
        self.loginEvent?.self(result)
    }
    
    func connectBeneficiaryInfoForBank(withID bankID: String, beneficiaryInfo info: @escaping (DapiBeneficiaryInfo?) -> Void) {
        info(nil)
    }
    
    func connectDidProceed(withBankID bankID: String, userID: String) {
        let result =  getJsonFromModel(from:AuthStateModel(accessId: userID, status: "PROCEED"))
        self.loginEvent?.self(result)
    }
    




    private func finishWithError(errorCode: String? = nil, errorMessage: String, details: Any? = nil) {
        guard let result = pendingResult else { return }
        result(FlutterError(code: errorCode ?? "-1",
                            message: errorMessage,
                            details: nil))
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
