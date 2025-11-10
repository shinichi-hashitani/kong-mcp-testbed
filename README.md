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



## 関連ドキュメンテーション
[KongにおけるMCPサーバー機能の概要](https://developer.konghq.com/mcp/)

[サンプルチュートリアル](https://developer.konghq.com/mcp/kong-mcp/get-started/)

[AI MCP Proxyプラグイン](https://developer.konghq.com/plugins/ai-mcp-proxy/)

[AI MCP OAuthプラグイン (Tech Preview)](https://developer.konghq.com/plugins/ai-mcp-oauth2/)