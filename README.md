# shintaroasuzuki-restapi-lambda-template

## 目次

-   [環境構築](#environment-setup)
-   [ディレクトリ設計](#directory-design)
-   [マイグレーション](#migration)
-   [単体テスト](#unit-test)
-   [CI/CD](#cicd)

<h2 id="environment-setup">環境構築</h2>

```shell
yarn install
```

<h2 id="directory-design">ディレクトリ設計</h2>

```
.
├── flyway
│   └── migration/
├── openapi/
│   └── components/
│       └── schemas
├── src
└── terraform/
    ├── common
    └── envs/
        ├── dev
        ├── stg
        └── prd
```

<h2 id="migration">マイグレーション</h2>

[Flyway](https://flywaydb.org)を利用します。

```shell
brew install flyway
```

`V{major_version}_{minor_version}_{patch_version}__foo.sql` という命名規則で、`flyway/migration/` 配下にマイグレーションファイルを作成してください。

<h2 id="unit-test">単体テスト</h2>

単体テスト時の DB の接続先は、ローカルで立ち上げた MySQL イメージを使ったコンテナを指定しています。

### ローカルで MySQL の起動

ルートディレクトリで下記のコマンドを実行して、コンテナを起動します。

```shell
docker compose up -d
```

### マイグレーションの実行

```shell
flyway migrate
```

カバレッジが 100%になるように単体テストを記述します。

<h2 id="cicd">CI/CD</h2>

ブランチ戦略は GitLab-flow を採用しています。

main, staging, production という 3 つのブランチを立てています。

1. ローカルでのコミット

-   formatter
-   linter

2. Pull Request の作成

-   単体テスト
-   PR のコメントにカバレッジレポートを作成
-   terraform plan

3. Pull Request のマージ

-   terraform apply
