# Dart VM Metrics Exporter

Dart VMのメトリクスをprometheusなんかで取得するためのパッケージ

## 利用方法

### 前提

[Dart VM Service](https://github.com/dart-lang/sdk/blob/main/runtime/vm/service/service.md)からメトリクスを取得します。
Dartアプリケーションの実行時に`--observe`オプションを付けてDart VM Serviceを有効にする必要があります。

また、`--disable-service-auth-codes`も付与しないと起動が難しいです。

`--disable-service-auth-codes`を無効にした場合、Dart VM Serviceのポートが外部から不正にアクセスされないように、外部からトラフィックを受け入れない設定が必要です。

起動コマンド例
```
dart run --disable-service-auth-codes --observe=8181/0.0.0.0 YOUR_DART_APP
```

### agent

[agentディレクトリ](./agent/example)にあるdocker-compose.ymlを参考にします。
agentのコンテナは環境変数*DDS_URI*で接続先を設定します。

### library

[bin/example_server.dart](bin/example_server.dart)を参考にします。

## Run Example

```
docker compose -f ./agent/example/docker-compose.yml up
```

[127.0.0.0:3000](http://127.0.0.1:3000)へアクセスするとGrafanaが見れます。
データソースにprometheusを追加することでheap系のメトリクスが参照できます。
初期ID/Passはadmin/adminです。

## TODO

- [] heap以外のメトリクスにも対応する
