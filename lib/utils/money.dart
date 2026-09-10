String formatMoney(num value) {
  if (value == value.roundToDouble()) {
    return '\$${value.toInt()}';
  }
  return '\$${value.toStringAsFixed(2)}';
}
