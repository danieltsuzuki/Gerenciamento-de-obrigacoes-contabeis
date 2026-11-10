import '../../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../../../responsible/domain/entities/responsible.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<Responsible> register(RegisterRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      body: request.toJson(),
    );
    return LoginResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Responsible> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      body: request.toJson(),
    );
    return Responsible.fromJson(response as Map<String, dynamic>);
  }
}

