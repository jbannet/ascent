/// Extension methods for List to add safe access functionality
extension SafeListAccess<T> on List<T> {
  /// Safely get element at index, returns null if index is out of bounds
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}