# kong-mcp-testbed
Kong Gatewayの3.12で登場したMCP Proxy及びAI MCP OAuth2プラグインの試験環境です。

環境はDocker Composeを利用してKong Gatewayを立ち上げ、decKを利用してサービス/ルート定義やプラグインの設定を行うサンプルを併せて提供しています。

> [!IMPORTANT] 
> Kong Enterpriseのライセンスが必要です。

> [!WARNING] 
> 現時点ではKong Gateway 3.12がまだリリースされていない為、ナイトリービルドのイメージを利用しています。

## ゲートウェイの立ち上げ
1. Kong Gateway Enterpriseライセンスを`.env`に設定。
2. 以下のコマンドを実行
```
docker compose up -d
```
3. [http://localhost:8002](http://localhost:8002) にアクセス

## ドキュメンテーション
> [!WARNING] 
> 現時点ではKong Gateway 3.12がまだリリースされていない為、ドキュメントも公開前のバージョンを提示しています。

[KongにおけるMCPサーバー機能の概要](https://deploy-preview-2720--kongdeveloper.netlify.app/mcp/)

[AI MCP Proxyプラグイン](https://deploy-preview-2720--kongdeveloper.netlify.app/plugins/ai-mcp-proxy/unreleased/)

[AI MCP OAuthプラグイン](https://deploy-preview-2883--kongdeveloper.netlify.app/plugins/ai-mcp-oauth2/)