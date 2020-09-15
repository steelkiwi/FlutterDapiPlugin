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
        client.autoFlow.autoflowDelegate = self
        return client
    }()
    
    
    func execute(_ method: ActionChanel, result: @escaping FlutterResult) {
        switch method {
        case .connect: connect(result)
        case .activeConnection: activeConenction()
            // TODO: implement other methods
        default: return
        }
    }
    
    private func connect(_ result: @escaping FlutterResult) {
        pendingResult = result
        client.connect.present()
    }
    
    private func activeConenction() {}
}

extension DapiConnectDelegate: DPCConnectDelegate {
    func connectDidSuccessfullyConnect(toBankID bankID: String, userID: String) {
        print("connectDidSuccessfullyConnect")
    }
    
    func connectDidFailConnecting(toBankID bankID: String, withError error: String) {
        print("connectDidFailConnecting")
    }
    
    func connectBeneficiaryInfoForBank(withID bankID: String) -> DapiBeneficiaryInfo? {
        print("connectBeneficiaryInfoForBank")
        return nil
    }
    
    func connectDidProceed(withBankID bankID: String, userID: String) {
        print("connectDidProceed")
    }
    
    
}

extension DapiConnectDelegate: DPCAutoFlowDelegate {
    func autoFlow(_ autoFlow: DapiAutoFlow, beneficiaryInfoForBankID bankID: String, supportsCreateBeneficiary: Bool) -> DapiBeneficiaryInfo {
        print("autoFlow:beneficiaryInfoForBankID")
        let beneficiaryInfo = DapiBeneficiaryInfo()
        return beneficiaryInfo
    }
    
    func autoFlow(_ autoFlow: DapiAutoFlow, didSuccessfullyTransferAmount amount: Double, fromAccount senderAccountID: String, toAccuntID recipientAccountID: String) {
        print("autoFlow:didSuccessfullyTransferAmount")
    }
    
    func autoFlow(_ autoFlow: DapiAutoFlow, didFailToTransferFromAccount senderAccountID: String, toAccuntID recipientAccountID: String?, withError error: Error) {
        print("autoFlow:didFailToTransferFromAccount")
    }
    
}
