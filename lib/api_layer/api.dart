import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sfbu_hub/api_layer/graphql_config.dart';
import 'package:sfbu_hub/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQlApi {
  static final GraphQLConfig _graphQLConfig = GraphQLConfig();
  final GraphQLClient _client = _graphQLConfig.clientToQuery();

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
    print(email);
    final QueryOptions options = QueryOptions(
      document: gql(getOtp),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    print(result.data!['otpRequest']);
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
              schedule_day,
              schedule_time1,
              schedule_time2,
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
    // print(result.data!['getCourses']);
    return courseResponse;
  }

  Future<LoginResponse> setCanvasToken(String canvas_token) async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;

    final String setCanvasToken = """
      mutation {
        setCanvasToken(email: "$email", token: "$token", canvas_token: "$canvas_token") {
          token,
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(setCanvasToken),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      // print(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    // print(result.data!['setCanvasToken']);

    return LoginResponse.fromJson(result.data!['setCanvasToken']);
  }

  Future<bool> hasCanvasToken() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        hasCanvasToken(email: "$email", token: "$token") {
          has_canvas_token
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    print(result.data!);
    print(email + " " + token);
    return result.data!['hasCanvasToken']['has_canvas_token'];
  }

  Future<List<ChatGroup>> getChatGroups() async {
    final String token = (await LocalStorageApi().getLoginToken())!;
    final String email = (await LocalStorageApi().getEmail())!;
    final String query = """
      query {
        getCourses(email: "$email", token: "$token") {
          courses{
            id,
            name,
            members {
              name,
              email
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<ChatGroup> chatGroups = [];
      for (var course in result.data!['getCourses']['courses']) {
        List<ChatMember> members = [];
        for (var member in course['members']) {
          members.add(ChatMember.fromJson(member));
        }
        chatGroups.add(ChatGroup(
          id: course['id'],
          name: course['name'],
          members: members,
        ));
      }

      return chatGroups;
    });
  }

  Future<List<ChatMessage>> getChatMessages(String groupId) async {
    final String query = """
      query {
        getChatMessages(course_id: "$groupId") {
          message,
          sender_name,
          sender_email,
          group_id,
          created_at
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    return _client.query(options).then((result) {
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      List<ChatMessage> chatMessages = [];
      for (var message in result.data!['getChatMessages']) {
        chatMessages.add(ChatMessage.fromJson(message));
      }

      return chatMessages;
    });
  }

  Future<LoginResponse> sendMessage(String text, String groupId) async {
    final String email = (await LocalStorageApi().getEmail())!;
    final String name = (await LocalStorageApi().getEmail())!;
    final String query = """
      mutation {
        addChatMessage(sender_email: "$email", sender_name: "$name", message: "$text", course_id: "$groupId") {
          error,
          error_message
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(query),
    );

    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return LoginResponse.fromJson(result.data!['sendMessage']);
  }
}

class LocalStorageApi {
  Future<String?> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loginToken');
  }

  Future<String?> getShortName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('shortName');
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> setLoginToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loginToken', token);
  }

  Future<void> setShortName(String shortName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('shortName', shortName);
  }

  Future<void> setEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  Future<void> clearLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginToken');
    prefs.remove('email');
    prefs.clear();
  }
}
