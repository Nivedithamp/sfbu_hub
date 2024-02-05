import 'dart:math';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sfbu_hub/api_layer/graphql_config.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlApi {
  static GraphQLConfig _graphQLConfig = GraphQLConfig();
  GraphQLClient _client = _graphQLConfig.clientToQuery();

  Future<LoginResponse> getOtp(String email) async {
    final String getOtp = """
      query {
        otpRequest(email: "$email") {
          token,
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(getOtp),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return LoginResponse.fromJson(result.data!['otpRequest']);
  }

  Future<LoginResponse> login(String email, String otp) async {
    final String login = """
      query {
        login(email: "$email", otp: "$otp") {
          token,
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(login),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return LoginResponse.fromJson(result.data!['login']);
  }

  Future<CourseResponse> getCourses() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String getCourses = """
      query {
        getCourses(token: "$token", email: "$email") {
            courses {
              id,
              name,
              is_public,
              schdule_day,
              schdule_time1,
              schdule_time2,
              location
            },
            error,
            error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(getCourses),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    CourseResponse courseResponse =
        CourseResponse.fromJson(result.data!['getCourses']);
    if (courseResponse.error! &&
        courseResponse.error_message == "Invalid token") {
      LocalStorageApi().clearLocal();
    }

    return courseResponse;
  }
}

class LocalStorageApi {
  Future<String?> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginToken');
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> setLoginToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loginToken', token);
  }

  Future<void> setEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  //https://sso.canvaslms.com/canvas/login?code_android=1934efb31640c2c6600ae6f5c5119b250833b5d65e95da643c785858ffd8636732df0294bb57485b42da8aac5e5a6603e0d7723a34aa198a5d10a911a0b83c63&code_ios_teacher=71a7fde2bf45ded4fbc40c89365ba23ff304f8234897b6b7fb9fc3e61430de673784f8517f22e9aa1798098cade597d7d60b4de2532a778ab81af18eebf08341&code_android_teacher=f42a4bf181eef05355791cabb27e0065777e6cf9f78a5d6ac24cc7300c25b6c82f642273bdc834dbe10d37f764f0112186350ee34555ad69b7d06d4a4bbf777b&code_ios_parent=b7e8ae4118eef9594d36e9bd2d59073bd3039eeae43e2bc1c6895eff0540d0d44b300c6e2bfbeb73dea81696b659a537cb56f69a20ba1adf6bc32228e7353d7f&code_android_parent=6677533b4bc5652d5265898b873220d844a0e457a29239461236e83ebf5f6751b12212f13b3382e78ed6597029704307eaa8b7198b5aeb10c15749a237a98627&code=bdeb7dd864d1445c0f6d7c8165fe3e6edf3057e782ece77d972acf3cefc6d0dc90355bc37394d07d239ea2f3d421af67461e970892d6cd8bbedab014cc3a06f1&domain=sfbu.instructure.com
  //https://sso.canvaslms.com/canvas/login?code_android=a0fc2728e503ffc1ad4b088c148eae56760b37766a55037e48dda88d6f88f6adc13b0473843a88537ecf34094b503b6e8c660b1c092eff5d912d26157df2d40e&code_ios_teacher=70bc00a6164451fc3d845aa6af157af0046067d0f208fbc6fe50d3d358258e30257c0a48fe61482d13f97dfc4bd5d49ad2d99198ebf762a2675bda92d15748bc&code_android_teacher=3898318b5cc638be804b8938ca082ebde69b580a7af8c2e58eede12378a231df97ce85f56eb70a571918195662f4b9c4cf02d41403bb45e78467361b638f33d3&code_ios_parent=c1696ce00de1c800a36b47d59c2f5026f60ac55f38cbc2d528839ae011755ffbc6b73be00468d2ee44a99826dea6bc7a91a4cef319632fe0638fe6a2f51faa2b&code_android_parent=18c7d9a319bd5f7b3a6cc8af32008ec235367a36e2f703fd2fdc3d84d887c3cc3e99fbd2e9b71eee7e9328f2b1681161f2f893ac20bac75395619b35c8e7502d&code=4d5c9e2175e7a6fb813d316a12612020d9b12d33986fd675478799252aa974fc482ff4f9a5de78418853167f2f5c2e54e7f2412c36744f588e6073f1df687ede&domain=sfbu.instructure.com
  Future<void> clearLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginToken');
    prefs.remove('email');
  }
}
