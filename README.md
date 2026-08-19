# kong-mcp-testbed
Kong Gatewayの3.12で登場したMCP Proxy及びAI MCP OAuth2プラグインの試験環境です。

環境はDocker Composeを利用してKong Gatewayを立ち上げ、decKを利用してサービス/ルート定義やプラグインの設定を行うサンプルを併せて提供しています。

> [!IMPORTANT] 
> Kong Enterpriseのライセンスが必要です。

## 事前準備
利用するサンプル環境によっては、Docker Composeでゲートウェイを立ち上げる前に外部サービス側の準備が必要です。

- [OpenWeather](/weather.md)を試す場合: OpenWeatherMapのAPIキーの発行が必要（詳細は[weather.mdの事前準備](/weather.md#事前準備---openweatherのapiキーの取得)を参照）。
- [MCP ACL with OIDC](/mcp-acl-with-oidc.md)を試す場合: Auth0の無料テナント作成、およびTerraform実行用M2Mアプリケーションの発行が必要（詳細は[mcp-acl-with-oidc.mdの事前準備](/mcp-acl-with-oidc.md#事前準備---auth0テナント作成)を参照）。

[Transactions](/transactions.md)のみを試す場合は追加の事前準備は不要です。

## ゲートウェイの立ち上げ
1. Kong Gateway Enterpriseライセンスを`.env`に設定。
2. 以下のコマンドを実行
```
docker compose up -d
```
3. [http://localhost:8002](http://localhost:8002) にアクセス

## サンプル環境
1. [OpenWeather](/weather.md) - ```conversion-listener```モードで既存のREST APIに対してMCPサーバを用意。
2. [Transactions](/transactions.md) - ```listener```と```conversion-only```モードを組み合わせる事により、異なる2つのサービスへのアクセスを集約したMCPサーバを構築。
3. [MCP ACL with OIDC](/mcp-acl-with-oidc.md) - OIDC（Auth0）で認証したユーザーのdepartment属性を元に、```ai-mcp-proxy```のネイティブACL機能でMCP Toolへのアクセスを制御。

## アクセス (insomnia)
バックエンドとなるOpenWeather、Account、Transactionの各種サービスに接続する際に利用できる[Insomnia Collection](/collections/kong-mcp-testbed-collection.yaml)を用意。InsomniaからImportすることが可能。

## 関連ドキュメンテーション
[KongにおけるMCPサーバー機能の概要](https://developer.konghq.com/mcp/)

[サンプルチュートリアル](https://developer.konghq.com/mcp/kong-mcp/get-started/)

[AI MCP Proxyプラグイン](https://developer.konghq.com/plugins/ai-mcp-proxy/)

[AI MCP OAuthプラグイン (Tech Preview)](https://developer.konghq.com/plugins/ai-mcp-oauth2/)