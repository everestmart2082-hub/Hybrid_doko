import 'package:url_launcher/url_launcher.dart';

Future<void> openMapSearchImpl(String query) async {
  final q = query.trim();
  if (q.isEmpty) return;
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
