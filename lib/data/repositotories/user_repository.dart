import '../models/user.dart';
import '../providers/user_api_provider.dart';

class UserRepository {
  final UserApiProvider _apiProvider = UserApiProvider();

  Future<List<User>> getUsers(int page) {
    return _apiProvider.fetchUsers(page);
  }

  Future<dynamic> getUsersDetails(User user) {
    return _apiProvider.getUserDetails(user.id);
  }
}
