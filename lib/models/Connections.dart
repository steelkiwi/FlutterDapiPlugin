
import 'CoolDownPeriod.dart';
import 'SubAccount.dart';

class Connections {
    String bankID;
    String clientUserID;
    CoolDownPeriod coolDownPeriod;
    String country;
    String fullBankName;
    bool isCreateBeneficiaryRequired;
    List<Object> pendingBeneficiaries;
    String shortBankName;
    List<SubAccount> subAccounts;
    String swiftCode;
    String userID;

    @override
  String toString() {
    return 'Connections{bankID: $bankID, clientUserID: $clientUserID, coolDownPeriod: $coolDownPeriod, country: $country, fullBankName: $fullBankName, isCreateBeneficiaryRequired: $isCreateBeneficiaryRequired, pendingBeneficiaries: $pendingBeneficiaries, shortBankName: $shortBankName, subAccounts: $subAccounts, swiftCode: $swiftCode, userID: $userID}';
  }

  Connections({this.bankID, this.clientUserID, this.coolDownPeriod, this.country, this.fullBankName, this.isCreateBeneficiaryRequired, this.pendingBeneficiaries, this.shortBankName, this.subAccounts, this.swiftCode, this.userID});

    factory Connections.fromJson(Map<String, dynamic> json) {
        return Connections(
            bankID: json['bankID'], 
            clientUserID: json['clientUserID'], 
            coolDownPeriod: json['coolDownPeriod'] != null ? CoolDownPeriod.fromJson(json['coolDownPeriod']) : null, 
            country: json['country'], 
            fullBankName: json['fullBankName'], 
            isCreateBeneficiaryRequired: json['isCreateBeneficiaryRequired'], 
//            pendingBeneficiaries: json['pendingBeneficiaries'] != null ? (json['pendingBeneficiaries'] as List).map((i) => Object.fromJson(i)).toList() : null,
            shortBankName: json['shortBankName'], 
            subAccounts: json['subAccounts'] != null ? (json['subAccounts'] as List).map((i) => SubAccount.fromJson(i)).toList() : null, 
            swiftCode: json['swiftCode'], 
            userID: json['userID'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['bankID'] = this.bankID;
        data['clientUserID'] = this.clientUserID;
        data['country'] = this.country;
        data['fullBankName'] = this.fullBankName;
        data['isCreateBeneficiaryRequired'] = this.isCreateBeneficiaryRequired;
        data['shortBankName'] = this.shortBankName;
        data['swiftCode'] = this.swiftCode;
        data['userID'] = this.userID;
        if (this.coolDownPeriod != null) {
            data['coolDownPeriod'] = this.coolDownPeriod.toJson();
        }
        if (this.pendingBeneficiaries != null) {
//            data['pendingBeneficiaries'] = this.pendingBeneficiaries.map((v) => v.toJson()).toList();
        }
        if (this.subAccounts != null) {
            data['subAccounts'] = this.subAccounts.map((v) => v.toJson()).toList();
        }
        return data;
    }

}