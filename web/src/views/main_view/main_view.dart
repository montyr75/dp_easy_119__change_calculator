/*
 * A program that takes a floating point number from the user representing a sum of
 * money (such as 15.47) and calculates the minimum number of coins required to equal it.
 */

// TODO: Bug-- "Convert Gold" calculation updates unit qty values, but this is not reflected in the
// "Total Value (Gold)" panel...and probably vice versa.

library main_view;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart';
import '../../utils/filters.dart';
import '../../model/currency_unit.dart';

@CustomTag('main-view')
class MainView extends PolymerElement {
  // constants
  static const String DEFAULT_MSG_STATE = "label-default";
  static const String ERROR_MSG_STATE = "label-danger";

  // strings
  static const String DEFAULT_MSG = "Enter values.";
  static const String INVALID_INPUT = "Invalid input.";

  // UI properties (these should typically have default values assigned here)
  @observable String convertOutputHeader = "Change";
  @observable num dollars;
  @observable num gold;
  @observable String convertMessage = DEFAULT_MSG;
  @observable List<CurrencyUnit> outputUnits;
  @observable String totalMessage = DEFAULT_MSG;
  @observable String outputTotal = "0.00 gp";
  @observable String convertMessageState = DEFAULT_MSG_STATE;
  @observable String totalMessageState = DEFAULT_MSG_STATE;

  // filters and transformers can be referenced as class fields
  final Transformer asInteger = new StringToInt();
  final Transformer asNum = new StringToNum();

  // list of USD currency units
  final List<CurrencyUnit> unitsUSD = toObservable([
    //new CurrencyUnit("dollar", 100, 1),
    new CurrencyUnit("quarter", 25, 0.25),
    new CurrencyUnit("dime", 10, 0.1),
    new CurrencyUnit("nickel", 5, 0.05),
    new CurrencyUnit("penny", 1, 0.01)
  ]);

  // list of D&D currency units (except electrum, as it's rarely used)
  final List<CurrencyUnit> unitsDnD = toObservable([
    new CurrencyUnit("pp", 1000, 10),
    new CurrencyUnit("gp", 100, 1),
    //new CurrencyUnit("ep", 50, 0.5),
    new CurrencyUnit("sp", 10, 0.1),
    new CurrencyUnit("cp", 1, 0.01)
  ]);

  MainView.created() : super.created();

  @override void enteredView() {
    super.enteredView();
    print("MainView::enteredView()");
  }

  void convertDollars(Event event, var detail, Element target) {
    if (convertToCoins(dollars, unitsUSD)) {
      outputConversion(unitsUSD, "USD");
    }
  }

  void convertGold(Event event, var detail, Element target) {
    if (convertToCoins(gold, unitsDnD)) {
      outputConversion(unitsDnD, "D&D");
    }
  }

  bool convertToCoins(num primaryUnitAmount, List<CurrencyUnit> units) {
    if (primaryUnitAmount == null) {
      convertMessage = INVALID_INPUT;
      convertMessageState = ERROR_MSG_STATE;
      return false;
    }

    // the atomic amount is the value expressed in the system's most basic unit (pennies for USD)
    int atomicAmount = (primaryUnitAmount * 100).round();

    units.forEach((CurrencyUnit unit) {
      unit.qty = (atomicAmount / unit.atomicValue).floor();
      atomicAmount %= unit.atomicValue;
    });

    convertMessage = DEFAULT_MSG;
    convertMessageState = DEFAULT_MSG_STATE;

    return true;
  }

  void outputConversion(List<CurrencyUnit> units, String headerText) {
    // send output to console
    print("");
    units.forEach((CurrencyUnit unit) => print(unit));

    // send output to web page
    convertOutputHeader = headerText;
    outputUnits = toObservable(new List<CurrencyUnit>.from(units));
  }

  void calculateTotal(Event event, var detail, Element target) {
    if (event != null) {
      event.preventDefault();
    }

    if (unitsDnD.any((CurrencyUnit unit) => unit.qty == null)) {
      totalMessage = INVALID_INPUT;
      totalMessageState = ERROR_MSG_STATE;
      return;
    }

    num total = 0;

    unitsDnD.forEach((CurrencyUnit unit) {
      total += unit.qty * unit.primaryValue;
    });

    totalMessage = DEFAULT_MSG;
    totalMessageState = DEFAULT_MSG_STATE;

    gold = total;

    outputTotal = "$total gp";
  }

  // prevent app reload on <form> submission
  void submit(Event event, var detail, Element target) {
    event.preventDefault();
  }

  // this lets the global CSS bleed through into the Shadow DOM of this element
  bool get applyAuthorStyles => true;
}

