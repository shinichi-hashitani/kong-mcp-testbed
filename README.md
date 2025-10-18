# kong-mcp-testbed
Kong Gatewayの3.12で登場したMCP Proxy及びAI MCP OAuth2プラグインの試験環境です。

環境はDocker Composeを利用してKong Gatewayを立ち上げ、decKを利用してサービス/ルート定義やプラグインの設定を行うサンプルを併せて提供しています。

> [!IMPORTANT] 
> Kong Enterpriseのライセンスが必要です。

## ゲートウェイの立ち上げ
1. Kong Gateway Enterpriseライセンスを`.env`に設定。
2. 以下のコマンドを実行
```
docker compose up -d
```
3. [http://localhost:8002](http://localhost:8002) にアクセス

## MCP Proxy Plugin
> [!WARNING] 
> 現在検証中

OpenWeatherMapのAPI用のMCPサーバーをMCP Proxyプラグインを利用して構築するサンプルです。この為、まず[OpenWeatherMapに登録の上、APIキーを発行](https://home.openweathermap.org/api_keys)する必要があります。
![OpenWeatherMap - APIキー画面](/resources/openweather-ui.png)

### Service/Route/Pluginの設定
ルーティング定義は[conversion-listener.yaml](/conversion-listener.yaml)に定義。但しOpenWeatherMapのAPIキーは参照変数指定する設定となっている為、decKコマンド実施前に設定。
```bash
export DECK_OPENWEATHER_API_KEY=YOUR_API_KEY
```
その後decK syncコマンドを実行
```bash
deck gateway sync conversion-listener.yaml
```
[Kong Manager](http://localhost:8002)にアクセスし、MCP Proxyプラグインが設定されていること、設定内の```query.appid```という項目にOpenWeatherMapのAPIキーが設定されていることを確認。
![Konnect - MCP Proxyプラグイン設定画面](/resources/konnect-plugin-config.png)

### MCP Inspectorの実行
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

### MCP Inspectorを利用した接続確認
MCP Inspector上で以下の設定の上、Connectをクリックして接続。
- ```Transport Type```に```StreamableHTTP```を設定。
- ```Connection Type```に```Via Proxy```を設定。
- URLにMCP Proxyプラグインで指定したURL([http://localhost:8000/weather/mcp](http://localhost:8000/weather/mcp))を設定。
![MCP Inspector - ログイン後](/resources/mcp-inspector-after-login.png)
接続Initializeの結果が反映されている事を確認。また、MCP Inspectorのログには以下の様に出力される。
```bash
New StreamableHttp connection request
Query parameters: {"url":"http://localhost:8000/weather/mcp","transportType":"streamable-http"}
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

### 検証中の課題
- StreamableHTTPでは接続出来るが、SSEでの接続ではエラーとなる。

## 関連ドキュメンテーション
[KongにおけるMCPサーバー機能の概要](https://developer.konghq.com/mcp/)

[サンプルチュートリアル](https://developer.konghq.com/mcp/kong-mcp/get-started/)

[AI MCP Proxyプラグイン](https://developer.konghq.com/plugins/ai-mcp-proxy/)

[AI MCP OAuthプラグイン (Tech Preview)](https://developer.konghq.com/plugins/ai-mcp-oauth2/)