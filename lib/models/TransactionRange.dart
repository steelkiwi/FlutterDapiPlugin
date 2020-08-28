
class TransactionRange {
    String unit;
    int value;

    TransactionRange({this.unit, this.value});

    factory TransactionRange.fromJson(Map<String, dynamic> json) {
        return TransactionRange(
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