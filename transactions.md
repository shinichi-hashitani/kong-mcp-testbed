# Transactions - listener & conversion-only
![Transactions - Overview](/resources/transactions-overview.png)
複数の関連するサービスに対して、1つの統一的なMCPサーバを提供する例。本サンプルでは、AccountサービスとTransactionサービスの2つに対して、いずれのサービスにも繋がるMCPサーバとする。

内部的には、2種類の異なるMCP Proxyを組み合わせるアプローチとなる：
- ```listener``` - MCPエンドポイントを提供
- ```conversion-only``` - バックエンドサービスに対するInput定義

本サンプルでは1つの```listner```に対して2つの```conversion-only```を紐づけているが、より多くのバックエンドを集約する事も可能。

## Step 1 -　MCP Proxyが無い環境の構築
ルーティングは[conversion-transactions.yaml](/conversion-transactions.yaml)に定義。decK syncコマンド実行により反映。
```bash
deck gateway sync conversion-transactions.yaml
```
この時点で個々のサービスにはアクセス可能となる。Insomniaにて```Accounts```もしくは```Transactions```で開始しているものが対象。
![Transactions - Insomnia](/resources/transactions-insomnia.png)
サービスはそれぞれ：
- Accountサービス http://localhost:8000/accounts
- Transactionサービス http://localhost:8000/transactions/<account_id>

からアクセス可能となっているが、実際のサービスは別々にデプロイされており、それぞれaccount(8081) transaction(8082) にて公開されている。

注意点として、TransactionサービスはAccountサービスに依存しており、該当するアカウントIDが必要となる。

InsomniaのCollectionには、```Accounts - Create``` にスクリプトが定義されており、アカウント作成時に生成されたアカウントIDは```accountId```という名前の環境変数に自動的に設定されている。この為、Accountの作成後であればTransactionサービスのそれぞれのリクエストもそのまま実行可能。

## Step 2 - MCP Proxyの追加
MCP Proxyを含んだ定義は[conversion-transaction-mcp.yaml](/conversion-transactions-mcp.yaml)に定義されている。decKの実行により適用。
```bash
deck gateway sync conversion-transactions-mcp.yaml
```
ToolとしてMCPに提供されるものはそれぞれのプラグイン(```ai-mcp-proxy```)配下、```tools```に定義されている。今回は2つのServiceそれぞれに対して```conversion-only```として定義している為、2箇所に定義されている。これらが双方同じ```listner```にタグを利用して紐付けている。
```yaml
- name: ai-mcp-proxy
  route: accounts-mcp
  config:
    mode: listener
    server:
      tag: accounts-mcp #ListnerのServer定義
...
- name: ai-mcp-proxy
  tags:
  - accounts-mcp #Listenerとのバインディング
  route: accounts
  config:
    mode: conversion-only
    tools:
    - annotations:
        title: Create an account
      description: Create an account with specified initial values.
      method: POST
...
    - annotations:
        title: List all accounts
      description: Get a list of accounts with id, account type, and balance.
      method: GET
...
- name: ai-mcp-proxy
  route: transactions
  tags:
  - accounts-mcp #Listenerとのバインディング
  config:
    mode: conversion-only
    tools:
    - annotations:
        title: Create a transaction
      description: Create a new credit transaction for a given Account ID.
      method: POST
      path: /accounts/{accountId}/transactions
...
    - annotations:
        title: List all transactions
      description: Get a list of transaction with id, date, amount, description, and transaction type for a given account.
      method: GET
...
```

##　 Step ３ - MCP Inspectorの起動
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

## Step 3 - MPC Inspectorを利用した検証
MCP Inspector上で以下の設定の上、Connectをクリックして接続。
- ```Transport Type```に```StreamableHTTP```を設定。
- ```Connection Type```に```Via Proxy```を設定。
- URLにMCP Proxyプラグインで指定したURL([http://localhost:8000/accounts/mcp](http://localhost:8000/accounts/mcp))を設定。

![Transaction - MCP Inspector画面](/resources/transaction-inspector.png)
```List Tools```を選択すると、登録されている4つのToolがリストアップされる。ツールを選択すると、右側にそのツールアクセスに必要な設定項目が表示される。

いずれのToolを利用する場合でも、設定はbody(JSON)としての定義となり、Insomnia出実行した際と同じ方式の定義となる。

1点、Transactionサービスのツール（具体的には```create-a-transaction```と```list-all-transactions```）については、併せて対象となるアカウントIDの指定が必要となる。こちらは、まずAccountサービスのツールを実行して取得するなり、Insomniaにて自動的に取得したアカウントIDなりを設定する必要がある。