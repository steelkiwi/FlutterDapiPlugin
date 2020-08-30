
import 'currency.dart';

class Balance {
    String accountNumber;
    double amount;
    Currency currency;

    Balance({this.accountNumber, this.amount, this.currency});

    factory Balance.fromJson(Map<String, dynamic> json) {
        return Balance(
            accountNumber: json['accountNumber'], 
            amount: json['amount'], 
            currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['accountNumber'] = this.accountNumber;
        data['amount'] = this.amount;
        if (this.currency != null) {
            data['currency'] = this.currency.toJson();
        }
        return data;
    }
}