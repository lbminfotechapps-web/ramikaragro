/// Combines geocoder fields, which may already contain a full postal address.
String formatAddressParts(Iterable<String> parts) {
  final result = <String>[];
  final normalized = <String>[];

  for (final part in parts.expand((part) => part.split(','))) {
    final value = part.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value.isEmpty) continue;
    final key = value.toLowerCase();
    // Whole-token matching avoids treating "Nagar" as "Ahmednagar".
    if (normalized.any((existing) =>
        existing == key || ' $existing '.contains(' $key '))) {
      continue;
    }
    result.add(value);
    normalized.add(key);
  }

  return result.join(', ');
}
