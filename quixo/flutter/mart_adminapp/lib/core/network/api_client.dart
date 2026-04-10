import 'package:dio/dio.dart';

abstract class ApiClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? query});
  Future<dynamic> post(String path, dynamic data, {Options? options});
  Future<dynamic> put(String path, dynamic data);
  Future<dynamic> delete(String path, dynamic data);
}
