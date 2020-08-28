
class CoolDownPeriod {
    String unit;
    int value;

    CoolDownPeriod({this.unit, this.value});

    factory CoolDownPeriod.fromJson(Map<String, dynamic> json) {
        return CoolDownPeriod(
            unit: json['unit'], 
            value: json['value'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['unit'] = this.unit;
        data['value'] = this.value;
        return data;
    }
}