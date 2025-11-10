# OpenWeather -　conversion-listener
![OpenWeatherMap](/resources/openweather-overview.png)
MCP Proxyを```conversion-listner```モードで利用する事により、REST APIに対するMCPのエンドポイントをKong Gateway上に構築。利用するOpenWeather側ではAPIキー（```appid```という名前を指定）と合わせて、全てをリクエストパラメータとして受け取る方式となっている。本サンプルでは、接続に必要なAPIキーもゲートウェイ側で管理するモデルとしており、個別のエージェントとMCPサーバとの認証は別の方式を採用する事も可能。

## 事前準備 - OpenWeatherのAPIキーの取得
[OpenWeatherMapに登録の上、APIキーを発行](https://home.openweathermap.org/api_keys)する必要がある。
![OpenWeatherMap - APIキー画面](/resources/openweather-ui.png)

APIへのアクセスは、CollectionのWeatherMapにて確認可能。この際、上記で取得したAPIキーを```appid```として指定。
![OpenWeatherMap - Insomnia](/resources/openweather-insomnia.png)

## Step 1 -　ゲートウェイ定義の適用（Service/Route/Plugin）
ルーティングは[conversion-wether.yaml](/conversion-weather.yaml)に定義。但しOpenWeatherのAPIキーは参照変数指定する設定となっている為、decKコマンド実施前に設定。
```bash
export DECK_OPENWEATHER_API_KEY=YOUR_API_KEY
```
その後decK syncコマンドを実行。
```bash
deck gateway sync conversion-weather.yaml
```
[Kong Manager](http://localhost:8002)にアクセスし、MCP Proxyプラグインが設定されていること、設定内の```query.appid```という項目にOpenWeatherMapのAPIキーが設定されていることを確認。
![Konnect - MCP Proxyプラグイン設定画面](/resources/konnect-plugin-config.png)

##　 Step 2 - MCP Inspectorの起動
ローカル環境にてMCP Inspectorを起動
```bash
npx @modelcontextprotocol/inspector
```
npxからモジュールダウンロードの確認が出る。yesとするとMCP Inspectorがブラウザで立ち上がる。
```bash
npx @modelcontextprotocol/inspector
Need to install the following packages:
@modelcontextprotocol/inspector@0.16.8
Ok to proceed? (y) y

npm warn deprecated node-domexception@1.0.0: Use your platform's native DOMException instead
Starting MCP inspector...
⚙️ Proxy server listening on localhost:6277
🔑 Session token: 42decd48f3f70b635b1560d376029b84dad00778c1753e43a47238427599359e
   Use this token to authenticate requests or set DANGEROUSLY_OMIT_AUTH=true to disable auth

🚀 MCP Inspector is up and running at:
   http://localhost:6274/?MCP_PROXY_AUTH_TOKEN=42decd48f3f70b635b1560d376029b84dad00778c1753e43a47238427599359e

🌐 Opening browser...
```

##　Step 3 - MCP Inspectorを利用した接続確認
MCP Inspector上で以下の設定の上、Connectをクリックして接続。
- ```Transport Type```に```StreamableHTTP```を設定。
- ```Connection Type```に```Via Proxy```を設定。
- URLにMCP Proxyプラグインで指定したURL([http://localhost:8000/weather/mcp](http://localhost:8000/weather/mcp))を設定。

接続Initializeの結果が反映されている事を確認。また、MCP Inspectorのログには以下の様に出力される。
```bash
New StreamableHttp connection request
Query parameters: {"url":"http://localhost:8000/accounts/mcp","transportType":"streamable-http"}
Created StreamableHttp client transport
Client <-> Proxy  sessionId: d537f628-a27a-4aa7-9dac-249ebf7e025b
Proxy  <-> Server sessionId: 06178b76-a0a1-49ee-81f3-5f3b00c659e1
Received POST message for sessionId d537f628-a27a-4aa7-9dac-249ebf7e025b
Received GET message for sessionId d537f628-a27a-4aa7-9dac-249ebf7e025b
```

### MCPにリクエストを送信
MCP Inspector上でTool Listから```current-weather-by-longitute-and-latitude```を選択。

その後パラメータである```lat```（緯度）と```lon```（経度）を指定してリクエストを実行。
![MCP Inspector - Run Tool](/resources/mcp-inspector-runtool.png)

### 結果
結果はAPIのレスポンスボディがそのままtext形態で出力される。

Request:
```json
{
  "method": "tools/call",
  "params": {
    "name": "current-weather-by-longitude-and-latitude",
    "arguments": {
      "query_lat": 35.666,
      "query_lon": 139.732
    },
    "_meta": {
      "progressToken": 0
    }
  }
}
```

Response:
```json
{
  "content": [
    {
      "type": "text",
      "text": "{\"coord\":{\"lon\":139.732,\"lat\":35.666},\"weather\":[{\"id\":804,\"main\":\"Clouds\",\"description\":\"overcast clouds\",\"icon\":\"04d\"}],\"base\":\"stations\",\"main\":{\"temp\":25.99,\"feels_like\":25.99,\"temp_min\":25.99,\"temp_max\":25.99,\"pressure\":1019,\"humidity\":38,\"sea_level\":1019,\"grnd_level\":1018},\"visibility\":10000,\"wind\":{\"speed\":6.98,\"deg\":83,\"gust\":6.01},\"clouds\":{\"all\":92},\"dt\":1758521872,\"sys\":{\"country\":\"JP\",\"sunrise\":1758486523,\"sunset\":1758530351},\"timezone\":32400,\"id\":1856950,\"name\":\"Mita\",\"cod\":200}"
    }
  ],
  "isError": false
}
```
![レスポンスJSON](/resources/mcp-inspector-result.png)

## Step 4 - jqプラグインによるレスポンスフォーマットの変換
レスポンスJSONオブジェクトの変換にはいくつかアプローチがあるが、今回はKongが提供する[jqプラグイン](https://developer.konghq.com/plugins/jq/examples/jq-request-program/)を利用する。このプラグインはリクエスト、もしくはレスポンスのペイロードJSONに対してjqコマンドを適用することができる。

今回は[response_jq_program](https://developer.konghq.com/plugins/jq/reference/#schema--config-response-jq-program)を指定して、ペイロードから必要な属性のみ抽出する。jqプラグインの定義は以下のとおり：
```bash
- name: jq
  config:
    response_jq_program: '{"観測所": "\(.name)", "気温": "\(.main.temp)度", "湿度": "\(.main.humidity)%"}'

```

### Kong Gatewayにプラグインを適用
jqプラグインによる変換を含んだ[conversion-listener-jq.yaml](/conversion-listener-jq.yaml)を適用。
```bash
deck gateway sync conversion-listener-jq.yaml
```
結果は以下のとおり：
![OpenWeatherMap](/resources/mcp-inspector-result-jq.png)
