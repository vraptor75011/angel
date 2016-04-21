import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_static/angel_static.dart';
import 'package:http/http.dart' show Client;
import 'package:test/test.dart';

main() {
  group('angel_static', () {
    Angel angel;
    String url;
    Client client = new Client();

    setUp(() async {
      angel = new Angel();
      angel.registerMiddleware("static", serveStatic(new Directory("test")));
      angel.get("*", "Fallback", middleware: ["static"]);

      await angel.startServer(InternetAddress.LOOPBACK_IP_V4, 0);
      url = "http://${angel.httpServer.address.host}:${angel.httpServer.port}";
    });

    tearDown(() async {
      await angel.httpServer.close(force: true);
    });

    test('can serve files, with correct Content-Type', () async {
      var response = await client.get("$url/sample.txt");
      expect(response.body, equals("Hello world"));
      expect(response.headers[HttpHeaders.CONTENT_TYPE], equals("text/plain"));
    });

    test('non-existent files are skipped', () async {
      var response = await client.get("$url/nonexist.ent");
      expect(response.body, equals('"Fallback"'));
    });
  });
}