abstract class ApiClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? query});
  Future<dynamic> post(String path, dynamic data);
  Future<dynamic> put(String path, dynamic data);
  Future<dynamic> delete(String path, dynamic data);
  Future<dynamic> postWithFile(String path, dynamic data);
}
