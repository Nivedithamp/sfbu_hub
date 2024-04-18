import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static HttpLink httpLink =
      HttpLink("https://sfbu-hub-2e4eceb65071.herokuapp.com/");

  static WebSocketLink webSocketLink = WebSocketLink(
    "ws://sfbu-hub-2e4eceb65071.herokuapp.com/",
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );

  GraphQLClient clientToQuery() => GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      );

  GraphQLClient clientToSubscription() => GraphQLClient(
        cache: GraphQLCache(),
        link: webSocketLink,
      );
}
