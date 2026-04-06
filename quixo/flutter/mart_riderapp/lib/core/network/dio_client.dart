import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../failures/api_exceptions.dart';
import '../failures/network_exception.dart';
import 'api_client.dart';
import 'token_provider.dart';

class DioClient implements ApiClient {
  final Dio _dio;
  final tokenProvider = SharedPreferencesTokenProvider();

  DioClient({
    required String baseUrl,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final token = await tokenProvider.getToken();
      if (token == null) {
        final response = await _dio.get(
          path,
          queryParameters: query,
        );
        // throw AuthFailure;
        return response.data;
      }

      final response = await _dio.get(
        path,
        queryParameters: query,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.from(e).failure;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> post(String path, dynamic data) async {
    try {
      final token = await tokenProvider.getToken();
      final response = await _dio.post(path, data: data, options: Options(headers: {
            'Authorization': 'Bearer $token', 
          },));
      return response.data;
    } 
    on DioException catch (e) {
      debugPrint(e.message);
      throw ApiException.from(e).failure;
    } 
    catch (e) {
      // throw NetworkException.noInternet();
      debugPrint(e.toString());
      // debugPrintStack(e.);
    }
  }

  
  @override
  Future<dynamic> postWithFile(String path, dynamic data) async {
    try {
      final token = await tokenProvider.getToken();
      final response = await _dio.post(path, data: data, options: Options(headers: {
            'Authorization': 'Bearer $token', 
            "content-type": "multipart/form-data"
          },));
      return response.data;
    } 
    on DioException catch (e) {
      debugPrint(e.message);
      throw ApiException.from(e).failure;
    } 
    catch (e) {
      // throw NetworkException.noInternet();
      debugPrint(e.toString());
      // debugPrintStack(e.);
    }
  }

  @override
  Future<dynamic> put(String path, dynamic data) async {
    try {
      final token = await tokenProvider.getToken();
      final response = await _dio.put(path, data: data, options: Options(headers: {
            'Authorization': 'Bearer $token',
          },));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.from(e).failure;
    } catch (_) {
      throw NetworkException.noInternet();
    }
  }

  @override
  Future<dynamic> delete(String path, dynamic data) async {
    try {
      final token = await tokenProvider.getToken();
      final response = await _dio.delete(path,data:data, options: Options(headers: {
            'Authorization': 'Bearer $token',
          },));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.from(e).failure;
    } catch (_) {
      throw NetworkException.noInternet();
    }
  }
}
