
class TaskImageConfig {
  TaskImageConfig._();

  // Configure these using verified server image directories.
  static const String taskImageBaseUrl = '';

  static const String completedImageBaseUrl = '';

  static String? _resolve(
    String? filename,
    String baseUrl,
  ) {
    final value = filename?.trim() ?? '';

    if (value.isEmpty ||
        value.toLowerCase() == 'null') {
      return null;
    }

    final uri = Uri.tryParse(value);

    if (uri != null &&
        (uri.scheme == 'https' ||
            uri.scheme == 'http') &&
        uri.hasAuthority) {
      return value;
    }

    if (baseUrl.isEmpty) return null;

    final base = Uri.tryParse(baseUrl);

    if (base == null ||
        !base.hasAuthority ||
        (base.scheme != 'http' &&
            base.scheme != 'https')) {
      return null;
    }

    return base.resolve(value).toString();
  }

  static String? resolve(String? filename) {
    return _resolve(filename, taskImageBaseUrl);
  }

  static String? resolveCompleted(String? filename) {
    return _resolve(
      filename,
      completedImageBaseUrl,
    );
  }
}
