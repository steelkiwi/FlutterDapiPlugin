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
        let configs = DapiConfigurations(appKey: appKey, baseUrl: urlComponents, countries: ["AE"], clientUserID: "MohammedEnnabah")
        configs.environment = .sandbox
        configs.isExperimental = false

        let client = DapiClient(configurations: configs)
        client.connect.delegate = self
        client.autoFlow.connectDelegate = self
        return client
    }()
    
    
    func execute(_ method: ActionChanel, result: @escaping FlutterResult) {
        switch method {
        case .connect: connect(result)
        case .activeConnection: activeConenction(result)
            // TODO: implement other methods
        default: return
        }
    }
    
    private func connect(_ result: @escaping FlutterResult) {
        pendingResult = result
        client.connect.present()
    }
    
    private func activeConenction(_ result: @escaping FlutterResult) {
        pendingResult = result
       var result = client.connect.getConnections()
        if(!result.isEmpty){
            let jsonString = convertIntoJSONString(arrayObject: result)

            print();
            
        }
        
        
        print("autoFlow:didSuccessfullyTransferAmount")

        
    }
}
func convertIntoJSONString(arrayObject: [Any]) -> String? {

    do {
        let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
        if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
            return jsonString as String
        }
        
    } catch let error as NSError {
        print("Array convertIntoJSON - \(error.description)")
    }
    return nil
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

