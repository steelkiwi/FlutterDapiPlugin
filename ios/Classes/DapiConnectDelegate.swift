import Foundation
import Flutter
import DapiConnect

class DapiConnectDelegate: NSObject {
    private var pendingResult: FlutterResult?
    private var loginEvent: FlutterEventSink?
    
    private var client: DapiClient?
    
    func getDapiConfig(env: DPCAppEnvironment,
                       host:String,
                       port:Int,
                       appKey:String,
                       header: [DPCEndPoint : [String : String]]?) ->  DapiConfigurations! {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"

        urlComponents.host = host;
        urlComponents.port = port

        let configs = DapiConfigurations(appKey:appKey,
                                         baseUrl: urlComponents,
                                         countries: ["AE"],
                                         clientUserID: "testUser"
        )
        configs.environment = env
        configs.isExperimental = false
        
        if header != nil {
            configs.endPointExtraHeaderFields=header!
            
        }
        
        return configs;
    }
    
     func updateHeaderForDapiClient(headers: [DPCEndPoint : [String : String]]?=nil) {
        let lastConfig=client!.configurations;
        let configs = getDapiConfig(env: lastConfig.environment,
                                    host: lastConfig.baseUrl.host!,
                                    port: lastConfig.baseUrl.port!,
                                    appKey: lastConfig.appKey,
                                    header: headers)
        client?.configurations=configs!
       }
    
    
    
    
    func addPaymentIdToHeader(paymentId:String?){
        if paymentId != nil {
        updateHeaderForDapiClient(headers: [DPCEndPoint.createTransfer:["Dapi-Payment":paymentId!],
                                            DPCEndPoint.resumeJob:["Dapi-Payment":paymentId!]]
        )}
    }
    
    
    func executeAction(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        pendingResult = result
        if call.method == Action.initEnvironment.rawValue {
            initEnvironment(call: call)
        } else {
            if client != nil{
                    switch Action(rawValue: call.method) {
                        case .activeConnection: activeConenction(call,client: client!)//implemented
                        case .connectionAccounts: connectionAccounts(call,client: client!)//implemented
                        case .bankMetaData: bankMetaData(call,client: client!)//implemented
                        case .beneficiaries: beneficiaries(call,client: client!)//implemented
                        case .createBeneficiary: createBeneficiary(call,client: client!)
                        case .createTransferIdToId: createTransferIdToId(call,client: client!)//implemented
                        case .createTransferIdToIBan: createTransferIdToIBan(call,client: client!)//implemented
                        case .createTransferIDToNumber: createTransferIdToNumber(call,client: client!)//implemented
                        case .deLink: delink(call,client: client!)
                    default: finishWithError(errorMessage: "Wrong method: \(call.method)")
            }}else{
            finishWithError(errorMessage: "Dapi client hasn't inited")
        }}
    }

    func initEnvironment(call: FlutterMethodCall) {
        let appKey: String? = call.argument(key: ConstParameters.environmentAppKey)
        let port: Int? = call.argument(key: ConstParameters.environmentPort)
        let host: String? = call.argument(key:ConstParameters.environmentHost)
        let env: String? = call.argument(key: ConstParameters.environmentType)
        
        
        if (appKey == nil) {
                finishWithError(errorMessage: "App key can't be null")
                return;
            }
        if (host == nil) {
                  finishWithError(errorMessage: "Host key can't be null")
                  return
              }
        if (port == nil) {
                  finishWithError(errorMessage: "Port key can't be null")
                  return;
              }
        if env == nil {
                 finishWithError(errorMessage: "Env key can't be null")
                  return
              }
        
        if (!(env!.contains(Constants.ENVIRONMENT_SANDBOX) || env!.contains(Constants.ENVIRONMENT_PRODUCTION))) {
                finishWithError(errorMessage: "\(String(describing: env)) environment is not correc")
                  return
              }
        
        let hostWithoutShema=host?.replacingOccurrences(of: "https://", with: "")
        
        let environment:DPCAppEnvironment = (env == Constants.ENVIRONMENT_SANDBOX) ? DPCAppEnvironment.sandbox:DPCAppEnvironment.production


        let conf:DapiConfigurations = getDapiConfig(env: environment, host: hostWithoutShema!, port: port ?? 4041, appKey: appKey!,header: nil)
        
        client = DapiClient(configurations:conf)
        client!.connect.delegate = self
        
        
    }
    
    func clear(){
        self.loginEvent=nil;
    }


 func connect(eventSink : FlutterEventSink?) {
        guard let eventSink = eventSink else {
             return
           }
        if client != nil {
                loginEvent=eventSink;
                client!.connect.delegate = self
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
//                var accounts=[SubAccountModel]();
                
//                if(!it.accounts.isEmpty){
//                for j in 0...it.accounts.count-1 {
//                    let accountItem=it.accounts[j];
//                    let subAccountModel=SubAccountModel(currency:CurrencyModel(unit: accountItem.currency.name, value: accountItem.currency.code) , iban: accountItem.iban, id: accountItem.accountID, isFavourite: accountItem.isFavourite, name: accountItem.name, number: accountItem.number, type: accountItem.type);
//                    accounts.append(subAccountModel)
//                    }}

                let connectionModel=ConnectionModel(
                    bankID:it.bankID,
                    clientUserID: it.clientUserID,
                    coolDownPeriod:BeneficiaryCoolDownPeriod(unit: "", value:it.beneficiaryCoolDownPeriod),
                    country: it.countryName,
                    fullBankName: it.bankName,
                    isCreateBeneficiaryRequired: it.isCreateBeneficiaryEndpointRequired,
                    userID: it.userID)
                
                connectionsModel.append(connectionModel)
                            
            }
            pendingResult?.self(getJsonFromModel(from:connectionsModel))
        }else{
            pendingResult?.self(getJsonFromModel(from:connectionsModel))
        }

    }

    func connectionAccounts(_ call: FlutterMethodCall,client:DapiClient) {
        guard let userId: String = call.argument(key: ConstParameters.currentConnectId) else {
            finishWithError(errorMessage: "Parameter currentConnectId doesn't exists.")
            return
        }
        client.userID = userId
        client.data.getAccounts { [weak self] result, error, string in
            let dapiAccounts:[DapiAccount]?=result;
            var accounts=[SubAccountModel]();
            
            if let dapiAccounts = dapiAccounts {
            for j in 0...dapiAccounts.count-1 {
                   let accountItem=dapiAccounts[j];
                   let subAccountModel=SubAccountModel(currency:CurrencyModel(name: accountItem.currency.name, code: accountItem.currency.code) , iban: accountItem.iban, id: accountItem.accountID, isFavourite: accountItem.isFavourite, name: accountItem.name, number: accountItem.number, type: accountItem.type);
                   accounts.append(subAccountModel)
                   }
                let jsonConnections =  getJsonFromModel(from:accounts)
                self?.pendingResult?.self(jsonConnections)
            }
           
        }
        
    }

    func bankMetaData(_ call: FlutterMethodCall,client:DapiClient) {
        guard let userId: String = call.argument(key:  ConstParameters.currentConnectId) else {
            finishWithError(errorMessage: "Parameter currentConnectId doesn't exists.")
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
               
            
               
            let dapiBankMetaData = DapiBankMetadataModel(
                   bankName: bankMetadata.bankName,
                   beneficiaryCoolDownPeriod: BeneficiaryCoolDownPeriod(unit: "", value:bankMetadata.beneficiaryCoolDownPeriod),
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
        guard let userId: String = call.argument(key:  ConstParameters.currentConnectId) else {
                  finishWithError(errorMessage: "Parameter currentConnectId doesn't exists.")
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

        guard let userId: String = call.argument(key:  ConstParameters.currentConnectId),
        let addressLine1: String = call.argument(key: ConstParameters.beneficiaryAddressLine1),
        let addressLine2: String = call.argument(key: ConstParameters.beneficiaryAddressLine2),
        let addressLine3: String = call.argument(key: ConstParameters.beneficiaryAddressLine3),
        let accountNumber: String = call.argument(key: ConstParameters.accountNumber),
        let accountName: String = call.argument(key: ConstParameters.beneficiaryName),
        let bankName: String = call.argument(key: ConstParameters.beneficiaryBankName),
        let swiftCode: String = call.argument(key: ConstParameters.swiftCode),
        let iban: String = call.argument(key: ConstParameters.iBan),
        let country: String = call.argument(key: ConstParameters.country),
        let branchAddress: String = call.argument(key: ConstParameters.beneficiaryBranchAddress),
        let branchName: String = call.argument(key: ConstParameters.beneficiaryBranchName),
        let phone: String = call.argument(key: ConstParameters.phoneNumber)
        else {
                      finishWithError(errorMessage: "Invalid arguments")
            return
            
        }
        client.userID = userId
        
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

    func createTransferIdToId(_ call: FlutterMethodCall,client:DapiClient) {
        let accountId: String? = call.argument(key: ConstParameters.transactionBankAccountId)
        let userId: String? = call.argument(key: ConstParameters.currentConnectId);
        let amount: NSNumber? = call.argument(key:ConstParameters.transactionAmount);
        let beneficiaryId: String? = call.argument(key: ConstParameters.transactionBeneficiaryId)
        let paymentId: String? = call.argument(key: Headers.transactionPaymentId)
        addPaymentIdToHeader(paymentId: paymentId)
        if(beneficiaryId==nil){
            finishWithError(errorMessage:ConstantsMessage.BENEFICIARY_ID_NULL);
            return
        }
        if(accountId==nil){
           finishWithError(errorMessage:ConstantsMessage.ACCOUNT_ID_NULL);
            return;
        }
        if(userId==nil){
            finishWithError(errorMessage:ConstantsMessage.CURRENT_CONNECTION_ID_NULL);
            return;
        }
        if(amount==nil){
           finishWithError(errorMessage:ConstantsMessage.AMOUNT_IS_NULL);
            return;
            }
        
        client.payment.createTransfer(withSenderID: accountId!,
                                      amount: amount!,
                                      toReceiverID: beneficiaryId!,
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
                                            self?.updateHeaderForDapiClient(headers: nil)
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Transaction error")
                                            return
                                        }
                                        let response:DapiResultModel=DapiResultModel(jobID:result.jobID,status:result.status,success:result.success)
                                        self?.updateHeaderForDapiClient(headers: nil)
                                        self?.pendingResult?.self(getJsonFromModel(from:response))
                                      })
            
    }
    
    func createTransferIdToIBan(_ call: FlutterMethodCall,client:DapiClient) {
        let accountId: String? = call.argument(key: ConstParameters.transactionBankAccountId)
        let userId: String? = call.argument(key: ConstParameters.currentConnectId);
        let amount: NSNumber? = call.argument(key:ConstParameters.transactionAmount);
        let iBan: String? = call.argument(key: ConstParameters.iBan)
        let receiverName: String? = call.argument(key: ConstParameters.transactionReceiverName)

        let paymentId: String? = call.argument(key: Headers.transactionPaymentId)
        addPaymentIdToHeader(paymentId: paymentId)
        if(iBan==nil){
            finishWithError(errorMessage:ConstantsMessage.I_BAN_NULL);
            return
        }
        if(receiverName==nil){
            finishWithError(errorMessage:ConstantsMessage.RECEIVER_NAME_NULL);
            return
        }
        if(accountId==nil){
           finishWithError(errorMessage:ConstantsMessage.ACCOUNT_ID_NULL);
            return;
        }
        if(userId==nil){
            finishWithError(errorMessage:ConstantsMessage.CURRENT_CONNECTION_ID_NULL);
            return;
        }
        if(amount==nil){
           finishWithError(errorMessage:ConstantsMessage.AMOUNT_IS_NULL);
            return;
            }
        
        client.payment.createTransfer(withSenderID: accountId!,
                                      amount: amount!,
                                      iban:iBan!,
                                      name: receiverName!,
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
                                            self?.updateHeaderForDapiClient(headers: nil)
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Transaction error")
                                            return
                                        }
                                        let response:DapiResultModel=DapiResultModel(jobID:result.jobID,status:result.status,success:result.success)
                                        self?.updateHeaderForDapiClient(headers: nil)
                                        self?.pendingResult?.self(getJsonFromModel(from:response))
                                      })
            
    }
        
    
    func createTransferIdToNumber(_ call: FlutterMethodCall,client:DapiClient) {
        let accountId: String? = call.argument(key: ConstParameters.transactionBankAccountId)
        let userId: String? = call.argument(key: ConstParameters.currentConnectId);
        let amount: NSNumber? = call.argument(key:ConstParameters.transactionAmount);
        let receiverNumber: String? = call.argument(key: ConstParameters.accountNumber)
        let receiverName: String? = call.argument(key: ConstParameters.transactionReceiverName)

        let paymentId: String? = call.argument(key: Headers.transactionPaymentId)
        addPaymentIdToHeader(paymentId: paymentId)
        if(receiverNumber==nil){
            finishWithError(errorMessage:ConstantsMessage.RECEIVER_ACCOUNT_NUMBER_NULL);
            return
        }
        if(receiverName==nil){
            finishWithError(errorMessage:ConstantsMessage.RECEIVER_NAME_NULL);
            return
        }
        if(accountId==nil){
           finishWithError(errorMessage:ConstantsMessage.ACCOUNT_ID_NULL);
            return;
        }
        if(userId==nil){
            finishWithError(errorMessage:ConstantsMessage.CURRENT_CONNECTION_ID_NULL);
            return;
        }
        if(amount==nil){
           finishWithError(errorMessage:ConstantsMessage.AMOUNT_IS_NULL);
            return;
            }
        
        client.payment.createTransfer(withSenderID: accountId!,
                                      amount: amount!,
                                      toAccountNumber: receiverNumber!,
                                      name: receiverName!,
                                      completion: { [weak self] result, error, string in
                                        guard let result = result, error == nil else {
                                            self?.updateHeaderForDapiClient(headers: nil)
                                            self?.finishWithError(errorMessage: error?.localizedDescription ?? "Transaction error")
                                            return
                                        }
                                        let response:DapiResultModel=DapiResultModel(jobID:result.jobID,status:result.status,success:result.success)
                                        self?.updateHeaderForDapiClient(headers: nil)
                                        self?.pendingResult?.self(getJsonFromModel(from:response))
                                      })
            
    }
        
        
    


    func delink(_ call: FlutterMethodCall,client:DapiClient) {

        guard let dapiAccessId: String = call.argument(key: ConstParameters.currentConnectId) else {
            finishWithError(errorMessage: "Parameter currentConnectId doesn't exists.")
            return
        }
        client.userID = dapiAccessId
        client.auth.delinkUser { [weak self] response, error in
            self?.updateHeaderForDapiClient(headers: nil)
            guard let response = response, error == nil else {
                self?.finishWithError(errorMessage: error?.localizedDescription ?? "Get accounts error")
                return
            }
            let successDelinkModel:DapiResultModel=DapiResultModel(jobID:response.jobID,status:response.status,success:response.success)
            self?.pendingResult?.self(getJsonFromModel(from:successDelinkModel))


        }
    }
    
    
    private func finishWithError(errorCode: String? = nil, errorMessage: String, details: Any? = nil) {
        guard let result = pendingResult else { return }
        result(FlutterError(code: errorCode ?? "-1",
                            message: errorMessage,
                            details: nil))
    }

}

extension DapiConnectDelegate: DPCConnectDelegate {
       func connectDidSuccessfullyConnect(toBankID bankID: String, userID: String) {
        guard loginEvent != nil else { return }
        let result =  getJsonFromModel(from:AuthStateModel(accessId: userID, status: "SUCCESS",bankId:bankID))
        self.loginEvent?.self(result)
    }
    
    func connectDidFailConnecting(toBankID bankID: String, withError error: String) {
        let result =  getJsonFromModel(from:AuthStateModel(status: "FAILURE",error: error))
        self.loginEvent?.self(result)
    }
    
    func connectBeneficiaryInfoForBank(withID bankID: String, beneficiaryInfo info: @escaping (DapiBeneficiaryInfo?) -> Void) {
        info(nil)
    }
    
    func connectDidProceed(withBankID bankID: String, userID: String) {
        let result =  getJsonFromModel(from:AuthStateModel(accessId: userID, status: "PROCEED"))
        self.loginEvent?.self(result)
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
