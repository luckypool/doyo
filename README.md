saikin_doyo
===========

#### 適当なDBスキーマと、それらを操作する基本的な Model の実装
- DBIx::Skiny をつかったModel
- Test::mysqld を使ったテスト

#### また、Mojolicious を使ってJSONRPC経由でDBのデータ操作可能（参照のみ実装）
- WebまわりはMojolicious
- jsonrpc は Mojolicious プラグインの MojoX::JSON::RPC
- 以下は呼び出し例

```
$ curl -X POST http://localhost:3000/api/feed/rpc.json -d '{"jsonrpc": "2.0", "method": "lookup", "params": { "id": 2}, "id": 1}'
{"jsonrpc":"2.0","id":1,"result":{"body":"bodyボディ本文だああああああああ545217","created_at":"2013-02-18 23:53:24","nickname":"nickname:545217","updated_at":"0000-00-00 00:00:00","id":"2"}}
```

#### jQueryを使ってこれらデータを取得・ポストするView（未実装）

- viewはjsで


saikin-doyo
