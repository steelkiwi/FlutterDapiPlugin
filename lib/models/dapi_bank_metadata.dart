import 'address.dart';
import 'cool_down_period.dart';
import 'country.dart';
import 'transaction_range.dart';
import 'transfer_bound.dart';

class DapiBankMetadata {
  Address address;
  String bankName;

  CoolDownPeriod beneficiaryCoolDownPeriod;
  String branchAddress;
  String branchName;
  Country country;
  bool isCreateBeneficiaryEndpointRequired;
  String swiftCode;
  TransactionRange transactionRange;
  List<TransferBound> transferBounds;

  @override
  String toString() {
    return 'AccountsMetadata{address: $address, bankName: $bankName, branchAddress: $branchAddress, branchName: $branchName, country: $country, isCreateBeneficiaryEndpointRequired: $isCreateBeneficiaryEndpointRequired, swiftCode: $swiftCode, transactionRange: $transactionRange, transferBounds: $transferBounds}';
  }

  DapiBankMetadata(
      {this.address,
      this.bankName,
      this.beneficiaryCoolDownPeriod,
      this.branchAddress,
      this.branchName,
      this.country,
      this.isCreateBeneficiaryEndpointRequired,
      this.swiftCode,
      this.transactionRange,
      this.transferBounds});

  factory DapiBankMetadata.fromJson(Map<String, dynamic> json) {
    return DapiBankMetadata(
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      bankName: json['bankName'],
      beneficiaryCoolDownPeriod: json['beneficiaryCoolDownPeriod'] != null
          ? CoolDownPeriod.fromJson(
              json['beneficiaryCoolDownPeriod'])
          : null,
      branchAddress: json['branchAddress'],
      branchName: json['branchName'],
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
      isCreateBeneficiaryEndpointRequired:
          json['isCreateBeneficiaryEndpointRequired'],
      swiftCode: json['swiftCode'],
      transactionRange: json['transactionRange'] != null
          ? TransactionRange.fromJson(json['transactionRange'])
          : null,
      transferBounds: json['transferBounds'] != null
          ? (json['transferBounds'] as List)
              .map((i) => TransferBound.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bankName'] = this.bankName;
    data['branchAddress'] = this.branchAddress;
    data['branchName'] = this.branchName;
    data['isCreateBeneficiaryEndpointRequired'] =
        this.isCreateBeneficiaryEndpointRequired;
    data['swiftCode'] = this.swiftCode;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
//        if (this.beneficiaryCoolDownPeriod != null) {
//            data['beneficiaryCoolDownPeriod'] = this.beneficiaryCoolDownPeriod.toJson();
//        }
    if (this.country != null) {
      data['country'] = this.country.toJson();
    }
    if (this.transactionRange != null) {
      data['transactionRange'] = this.transactionRange.toJson();
    }
    if (this.transferBounds != null) {
      data['transferBounds'] =
          this.transferBounds.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
