library vm_metrics_exporter.vm_metrics;

import 'package:prometheus_client/prometheus_client.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class _VMMetricsCollectNames {
  final String vmMemoryUsage = "vm_memory_usage";
  final String isolateId = "isolate_id";
  final String isolateName = "isolate_name";
}

class _WithIsolate<T> {
  _WithIsolate(this.isolateRef, this.data);

  final IsolateRef isolateRef;
  final T data;
}

/// 利用するにはobserveオプションを付与してアプリケーションの起動が必要
class VMMetricsCollector extends Collector {
  VMMetricsCollector(String ddsUri) {
    _vmServiceF = vmServiceConnectUri(ddsUri);
  }

  late Future<VmService> _vmServiceF;
  final String _vmMemoryUsageName = "vm_memory_usage";
  final _VMMetricsCollectNames _names = _VMMetricsCollectNames();

  @override
  Future<Iterable<MetricFamilySamples>> collect() async {
    final vmService = await _vmServiceF;
    VM vm = await vmService.getVM();
    print(vm);
    final getMemoryUsagesF = (vm.isolates?.map((e) async {
          final usage = await vmService.getMemoryUsage(e.id!);
          return _WithIsolate(e, usage);
        })) ??
        const [];
    final memoryUsages = await Future.wait(getMemoryUsagesF);
    final memorySamples = memoryUsages
        .map((usage) {
          final tagNames = [_names.isolateId, _names.isolateName];
          final tagValues = [usage.isolateRef.id!, usage.isolateRef.name!];
          return [
            Sample("heap_capacity", tagNames, tagValues,
                usage.data.heapCapacity!.toDouble()),
            Sample("heap_usage", tagNames, tagValues,
                usage.data.heapUsage!.toDouble()),
            Sample("external_usage", tagNames, tagValues,
                usage.data.externalUsage!.toDouble()),
          ];
        })
        .expand((element) => element)
        .toList();
    return [
      MetricFamilySamples(_names.vmMemoryUsage, MetricType.gauge,
          "Dart VM Memory Usage", memorySamples)
    ];
  }

  @override
  Iterable<String> collectNames() {
    return [_vmMemoryUsageName];
  }
}

void register({String? ddsUri, CollectorRegistry? registry}) {
  registry ??= CollectorRegistry.defaultRegistry;
  final uri = ddsUri ?? "ws://0.0.0.0:8181";
  registry.register(VMMetricsCollector(uri));
}
