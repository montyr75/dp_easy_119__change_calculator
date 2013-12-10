library currency_unit;

// include Polymer to have access to @observable
import 'package:polymer/polymer.dart';

class CurrencyUnit {
  final String name;
  final int atomicValue;   // value compared to atomic currency unit for the system (pennies in USD)
  final num primaryValue;  // value compared to primary currency unit for the system (dollars in USD)
  @observable int qty = 0;

  CurrencyUnit(this.name, this.atomicValue, this.primaryValue);

  String toString() {
    return "$name: $qty";
  }
}