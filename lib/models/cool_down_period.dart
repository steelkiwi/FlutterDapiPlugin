class CoolDownPeriod {
  String unit;
  String value;

  CoolDownPeriod({this.unit, this.value});
  factory CoolDownPeriod.fromJson(Map<String, dynamic> json) {
    return CoolDownPeriod(
      unit: json['unit'].toString(),
      value: json["value"].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unit'] = this.unit;
    data['value'] = this.value;
    return data;
  }
}
