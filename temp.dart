String? extractUrl(String text) {
  final urlPattern = RegExp(
    r'((http|https):\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/[^\s]*)?',
    caseSensitive: false,
  );

  final match = urlPattern.firstMatch(text);
  return match?.group(0);
}
