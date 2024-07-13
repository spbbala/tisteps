import 'package:demo/data/models/user_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserApiProvider {
  final String baseUrl = "https://reqres.in/";

  Future<List<User>> fetchUsers(int page) async {
    final response = await http.get(Uri.parse('${baseUrl}api/users?page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<User> l = (data['data'] as List).map((json) => User.fromJson(json)).toList();
      return l;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<dynamic> getUserDetails(int id) async{

    final response = await http.get(Uri.parse('${baseUrl}api/users/$id'));

    if (response.statusCode == 200) {
      final UserDetails userDetails = UserDetails.fromJson(json.decode(response.body));
      print(response.body);

      return userDetails;
     return userDetails;
    } else {
      throw Exception('Failed to load users');
    }

  }
}
