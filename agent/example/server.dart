import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io' as io;
void main() async {
  final app = Router();
  app.all('/ok', (shelf.Request request) {
    return shelf.Response.ok("OK");
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(app);
  var server = await shelf_io.serve(handler, '0.0.0.0', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
  await io.ProcessSignal.sigterm.watch().first;
  await server.close();
}
