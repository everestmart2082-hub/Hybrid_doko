/// Normalizes values returned from the API when Mongo extended JSON is decoded
/// (e.g. `{"$oid": "..."}`) or plain strings.
String mongoIdToString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final o = v[r'$oid'];
    if (o is String) return o;
  }
  return v.toString();
}

String dynamicToPlainString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}
