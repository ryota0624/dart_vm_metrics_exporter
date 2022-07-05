import 'dart:io';

import 'package:prometheus_client_shelf/shelf_handler.dart';
import 'package:prometheus_client_shelf/shelf_metrics.dart' as shelf_metrics;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:io' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:vm_metrics_exporter/vm_metrics.dart' as vm_metrics;

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host = Platform.environment['HOST'] ?? '0.0.0.0';
  final dartDevServerURI = Platform.environment['DDS_URI'];
  vm_metrics.register(ddsUri: dartDevServerURI);

  final app = Router();
  app.get('/metrics', prometheusHandler());
  app.all('/<ignored|.*>', (shelf.Request request) {
    return shelf.Response.notFound('Not Found');
  });

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf_metrics.register())
      .addMiddleware(shelf.logRequests())
      .addHandler(app);
  var server = await shelf_io.serve(handler, host, port);
  print('Serving at http://${server.address.host}:${server.port}');
  await io.ProcessSignal.sigterm.watch().first;
  await server.close();
}
