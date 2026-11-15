import 'package:natyapp/core/auth/authenticated_user.dart';
import 'package:natyapp/core/network/api_client.dart';

abstract interface class ProfileAccountRepository {
  Future<AuthenticatedUser> fetchAccount();
}

class ProfileAccountRepositoryApi implements ProfileAccountRepository {
  ProfileAccountRepositoryApi(this._api);
  final ApiClient _api;

  @override
  Future<AuthenticatedUser> fetchAccount() async {
    final user = AuthenticatedUser.fromProfileJson(
      await _api.getJson('/api/v1/usuarios/me'),
    );
    _api.updateCurrentUser(user);
    return user;
  }
}
