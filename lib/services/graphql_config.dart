import 'package:beacon/locator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static String token;
  static final HttpLink httpLink = HttpLink(
    "http://127.0.0.1:4000/graphql",
  );

  static final AuthLink authLink = AuthLink(getToken: () => token);

  static final WebSocketLink websocketLink = WebSocketLink(
    'http://127.0.0.1:4000/graphql',
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
      initialPayload: {
        'headers': {'Authorization': token},
      },
    ),
  );

  Future getToken() async {
    final _token = userConfig.currentUser.authToken;
    token = _token;
    return true;
  }

  static final Link link = authLink.concat(httpLink).concat(websocketLink);
  GraphQLClient clientToQuery() {
    return GraphQLClient(
      cache: GraphQLCache(partialDataPolicy: PartialDataCachePolicy.accept),
      link: httpLink.concat(websocketLink),
    );
  }

  GraphQLClient authClient() {
    final AuthLink authLink = AuthLink(getToken: () async => 'Bearer $token');
    final Link finalAuthLink = authLink.concat(httpLink);
    return GraphQLClient(
      cache: GraphQLCache(),
      link: finalAuthLink,
    );
  }
}
