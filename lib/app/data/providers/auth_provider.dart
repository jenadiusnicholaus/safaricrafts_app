import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class AuthProvider {
  final ApiService _apiService = Get.find<ApiService>();

  Future<dio.Response> login(String email, String password) async {
    return await _apiService.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<dio.Response> register(Map<String, dynamic> userData) async {
    return await _apiService.post(ApiConstants.register, data: userData);
  }

  Future<dio.Response> logout() async {
    return await _apiService.post(ApiConstants.logout);
  }

  Future<dio.Response> getProfile() async {
    return await _apiService.get(ApiConstants.profile);
  }

  Future<dio.Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiService.put(ApiConstants.updateProfile, data: data);
  }
}
