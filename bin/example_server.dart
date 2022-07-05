import 'package:prometheus_client/runtime_metrics.dart' as runtime_metrics;
import 'package:prometheus_client_shelf/shelf_handler.dart';
import 'package:prometheus_client_shelf/shelf_metrics.dart' as shelf_metrics;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:vm_metrics_exporter/vm_metrics.dart' as vm_metrics;

void main() async {
  runtime_metrics.register();
  vm_metrics.register();
  final app = Router();
  app.get('/metrics', prometheusHandler());
  app.all('/<ignored|.*>', (shelf.Request request) {
    return shelf.Response.notFound('Not Found');
  });

  var handler = const shelf.Pipeline()
      // Register a middleware to track request times
      .addMiddleware(shelf_metrics.register())
      .addMiddleware(shelf.logRequests())
      .addHandler(app);
  var server = await io.serve(handler, 'localhost', 8080);

  print('Serving at http://${server.address.host}:${server.port}');
}
