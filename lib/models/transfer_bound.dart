
import 'currency.dart';

class TransferBound {
    Currency currency;
    int minimum;
    String type;

    TransferBound({this.currency, this.minimum, this.type});

    factory TransferBound.fromJson(Map<String, dynamic> json) {
        return TransferBound(
            currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null, 
            minimum: json['minimum'], 
            type: json['type'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['minimum'] = this.minimum;
        data['type'] = this.type;
        if (this.currency != null) {
            data['currency'] = this.currency.toJson();
        }
        return data;
    }
}