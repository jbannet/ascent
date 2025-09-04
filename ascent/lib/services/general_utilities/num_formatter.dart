/// Formats a double value with a specific number of decimal places
/// 
/// [value] - The double value to format
/// [places] - Number of decimal places to show (0 for integers)
/// 
/// Returns a string representation without trailing zeros
/// 
/// Examples:
/// - formatWithNPlaces(25.0, 0) returns "25"
/// - formatWithNPlaces(25.5, 1) returns "25.5"
/// - formatWithNPlaces(25.50, 1) returns "25.5"
String formatWithNPlaces(double value, int places) {
  if (places == 0) {
    return value.round().toString();
  } else {
    return value.toStringAsFixed(places).replaceAll(RegExp(r'\.?0+$'), '');
  }
}