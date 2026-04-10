/// Decodes Mongo-style ids from JSON (`{"$oid":"..."}` or plain hex string).
String mongoIdToString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    final o = v[r'$oid'];
    if (o is String) return o;
  }
  return v.toString();
}

double parseDiscountField(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
