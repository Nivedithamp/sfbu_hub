import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

ValueNotifier<GraphQLClient> clientFor({
  required String uri,
  String? subscriptionUri,
}) {
  Link link = HttpLink(uri);
  if (subscriptionUri != null) {
    final WebSocketLink websocketLink = WebSocketLink(
      subscriptionUri,
    );

    link = Link.split((request) => request.isSubscription, websocketLink, link);
  }

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    ),
  );
}

