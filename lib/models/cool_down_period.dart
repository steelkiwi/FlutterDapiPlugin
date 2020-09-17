class CoolDownPeriod {
    String unit;
    int value;

    CoolDownPeriod({this.unit, this.value});

    factory CoolDownPeriod.fromJson(Map<String, dynamic> json) {
        var value=json["value"].toString();
        return CoolDownPeriod(
            unit: json['unit'], 
            value: value.isEmpty?24:value,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['unit'] = this.unit;
        data['value'] = this.value;
        return data;
    }
}