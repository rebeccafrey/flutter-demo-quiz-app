class ElementModel {
  ElementModel({
    this.key,
    this.atomicNumber,
    this.element,
    this.symbol,
    this.group,
    this.period,
    this.droppedKey,
    this.accepting,
    this.successfulDrop,
    this.correctDrop,
    this.answer,
  });
  String key;
  int atomicNumber;
  String element;
  String symbol;
  int group;
  int period;
  String droppedKey = "";
  bool accepting = false;
  bool successfulDrop = false;
  bool correctDrop = false;
  String answer = "";
}
