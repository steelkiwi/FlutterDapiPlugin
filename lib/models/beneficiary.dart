class Beneficiary {
  String accountNumber;
  String iban;
  String id;
  String name;
  String status;
  String type;

  @override
  String toString() {
    return 'Beneficiary{accountNumber: $accountNumber, iban: $iban, id: $id, name: $name, status: $status, type: $type}';
  }

  Beneficiary(
      {this.accountNumber,
      this.iban,
      this.id,
      this.name,
      this.status,
      this.type});

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      accountNumber: json['accountNumber'],
      iban: json['iban'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accountNumber'] = this.accountNumber;
    data['iban'] = this.iban;
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['type'] = this.type;
    return data;
  }
}
