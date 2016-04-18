import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:http/http.dart' as http;
import 'package:json_god/json_god.dart';
import 'package:test/test.dart';

main() {
  group('routing', () {
    Angel angel;
    Angel nested;
    Angel todos;
    String url;
    http.Client client;
    God god;

    setUp(() async {
      god = new God();
      angel = new Angel();
      nested = new Angel();
      todos = new Angel();

      todos.get('/action/:action', (req, res) => res.json(req.params));

      nested.post('/ted/:route', (req, res) => res.json(req.params));

      angel.get('/hello', 'world');
      angel.get('/name/:first/last/:last', (req, res) => res.json(req.params));
      angel.use('/nes', nested);
      angel.use('/todos/:id', todos);

      client = new http.Client();
      await angel.startServer(InternetAddress.LOOPBACK_IP_V4, 0);
      url = "http://${angel.httpServer.address.host}:${angel.httpServer.port}";
    });

    tearDown(() async {
      await angel.httpServer.close(force: true);
      angel = null;
      nested = null;
      todos = null;
      client.close();
      client = null;
      url = null;
      god = null;
    });

    test('Can match basic url', () async {
      var response = await client.get("$url/hello");
      expect(response.body, equals('"world"'));
    });

    test('Can match url with multiple parameters', () async {
      var response = await client.get('$url/name/HELLO/last/WORLD');
      var json = god.deserialize(response.body);
      expect(json['first'], equals('HELLO'));
      expect(json['last'], equals('WORLD'));
    });

    test('Can nest another Angel instance', () async {
      var response = await client.post('$url/nes/ted/foo');
      var json = god.deserialize(response.body);
      expect(json['route'], equals('foo'));
    });

    test('Can parse parameters from a nested Angel instance', () async {
      var response = await client.get('$url/todos/1337/action/test');
      var json = god.deserialize(response.body);
      expect(json['id'], equals(1337));
      expect(json['action'], equals('test'));
    });
  });
}