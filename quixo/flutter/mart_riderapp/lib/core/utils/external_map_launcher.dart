import 'external_map_launcher_stub.dart'
    if (dart.library.html) 'external_map_launcher_web.dart'
    if (dart.library.io) 'external_map_launcher_io.dart';

Future<void> openMapSearch(String query) => openMapSearchImpl(query);
