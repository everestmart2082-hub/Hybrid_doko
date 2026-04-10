import 'dart:html' as html;

Future<void> openMapSearchImpl(String query) async {
  final q = query.trim();
  if (q.isEmpty) return;
  final url =
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}';
  html.window.open(url, '_blank');
}
