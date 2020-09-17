class CoolDownPeriod {
  String unit;
  int value;

  CoolDownPeriod({this.unit, this.value});

  factory CoolDownPeriod.fromJson(Map<String, dynamic> json) {
    var value = 24;
    try {
      value = int.parse(json["value"]);
    } catch (e) {}
    return CoolDownPeriod(
      unit: json['unit'],
      value: value,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unit'] = this.unit;
    data['value'] = this.value;
    return data;
  }
}
