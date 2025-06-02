# Dev Container で利用するプレビルドイメージのソース

## プレビルドイメージの概要

- 各イメージは基本的には `src/basic` を継承していく(`Dockerfile` の `FROM` にプレビルドイメージを指定)
  - 継承は必須ではない
- 各イメージは `src/<VARIANT>/test-project/test.sh` スクリプトを使いテストされる
- 各イメージは `linux/amd64` `linux/arm64` のマルチプラットフォーム用にビルドとテストが行われる
- 各イメージは `<VARIANT>_latest` `<VARIANT>_YYYY-MM-DD` タグが付与される
  - プルリクエストのワークフロー実行時に作成されるイメージでは `<VARIANT>_<BRANCH NAME>_YYYY-MM-DD` タグが付与される

## イメージビルド用のファイル

### 設定

設定は `src/<VARIANT>/.devcontainer/devcontainer.json` へ配置する。`Dockerfile` の内容は任意だが、以下のように作成するとワークフローによるビルド＆プッシュ時に直前にビルドされたプレビルドイメージを利用できる。

```Dockerfile
ARG BASE_REPO="ghcr.io/hankei6km/h6-dev-containers"
ARG BASE_TAG_SUFFIX="latest"
FROM ${BASE_REPO}:basic_${BASE_TAG_SUFFIX}
```

### テストスクリプト

イメージをテストするスクリプトは `src/<VARIANT>/test-project/test.sh` へ配置する。

現状ではテストフレームワークなどはとくに利用していない。

プラットフォーム別に異なるテストを行う場合は `$DOCKER_DEFAULT_PLATFORM` を利用する。テストスクリプトが実行されるときには常に指定されている。

> [!NOTE]
> `src/<VARIANT>/test-project/test.sh` は必ず配置しておく必要があります（空のスクリプトでも問題ありません）。

## ローカルでのビルド

スクリプトファイルを利用する(内部では `devcontainer build` が使われる)。

基本的には以下のように利用する。

```sh
export GH_TOKEN="<GHCR TOKEN>"
./scripts/image_build.sh --user "<USER>" --repo "<REPO>" --tag test --platform linux/arm64 basic
```

以下は、具体的な値を指定している例。

```sh
./scripts/image_build.sh --user "hankei6km" --repo "hankei6km/h6-dev-containers" --tag test --platform linux/amd64 basic
```

> [!NOTE]
> ラベル `org.opencontainers.image.source` の指定は行っていない。`devcontainer build` の不具合により、現状では `--label` が使えないため。

### マルチプラットフォーム

マルチプラットフォーム用のイメージをビルドする場合は、ビルダーの設定が必要となる。これは以下の様にスクリプトを利用する。
(Chromebook ARM64 Linux の Dev Container dind 環境ではエラーとなった)

```sh
./scripts/image_setup_builder.sh
```

なお、マルチプラットフォーム用のイメージはローカルへ書き出すことはできないので、基本的には ghcr.io へプッシュすることになる。

```sh
export GH_TOKEN="<GHCR TOKEN>"
./scripts/image_build.sh --user "<USER>" --repo "<REPO>" --tag test --platform linux/amd64,linux/arm64 --push true basic
```

### ロックファイル

以下のように手動でコマンドを実行し作成する(これが正規の方法であるかは不明)。

```sh
devcontainer upgrade \
    --workspace-folder "./src/${VARIANT}/" \
    --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
```

なお、既存の variant は dependabot で bump されるようにしてある。

## ローカルでのテスト

スクリプトファイルを利用する(内部では `devcontainer up` と `devcontainer exec` が使われる)。

```sh
export GH_TOKEN="<GHCR TOKEN>"
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./scripts/test_devcontainer.sh --user "<USER>" --repo "<REPO>" --tag test basic
```

実行環境(Docker ホスト)と異なるプラットフォームのテストを行う場合、ビルドと同様に `./scripts/image_setup_builder.sh` でビルダーを設定することで実施できる。

## プレビルドキャッシュ利用

以下のようにレジストリ上の basic variant などのキャッシュを指定することもできる。
(プレビルドのキャッシュをどの程度保持するかは決めていない)

以下、basic variant ビルド時にキャッシュを指定している例。

```sh
./scripts/image_build.sh --user "hankei6km" --repo "hankei6km/h6-dev-containers" --tag test --platform linux/amd64 --cache-from "type=registry,ref=ghcr.io/hankei6km/h6-dev-containers/cache:basic_latest" basic
 ```


## パッケージ

以下のパッケージ(リポジトリ)を作成し利用する。

- `ghcr.io/<USER>/<REPO>/image` : プレビルドイメージが配置される(各 Variant 用のリポジトリは作成されない)
- `ghcr.io/<USER>/<REPO>/cahse` : ビルド用キャッシュが配置される(各 Variant 用のリポジトリは作成されない)

基本的に作成はワークフロー実行時に行われる。可視設定などはデフォルトのままで変更しない、必要であれば手動で変更する。

ローカルでビルドスクリプトを実行しプッシュした場合でも作成されるが、この場合はリポジトリとの関連付けが行われないので、GitHub Actions(リポジトリ)へのアクセスを追加する必要がある。


> [!NOTE]
> 前述のようにイメージへのラベルは設定されないので、各イメージがパッケージ(リポジトリ)を指すためのメタ情報は常に含まれない。


## 新しい Variant を追加

以下の手順で追加することでワークフローによるビルドとテスト、dependabot による featuresの更新が行われる。

`foo` variant を追加する場合。

> [!NOTE]
> タグ内の最初の `_` は Variant 名と付加情報を分割する意味合いがある。よって Variant 名には `_` は含めない。Variant 内で単語を分割するようなときは `-` を利用する。

### ファイルを配置

以下のファイルを配置する。

- `src/foo/.devcontainer/devcontainer.json`
  - Dockerfile なども必要であれば配置する
- `src/foo/test-project/test.sh`
  - Dev Container内の remote user 用に実行権限を追加する

### テスト

以下のようにテストを行い正常終了することを確認する。

```sh
export GH_TOKEN="<GHCR TOKEN>"
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./scripts/test_devcontainer.sh --user "<USER>" --repo "<REPO>" --tag test foo
```

### ロックファイル

必要であれば(Feature を利用している場合)、以下のようにロックファイルを作成する。

```sh
devcontainer upgrade \
    --workspace-folder "./src/foo/" \
    --config "./src/foo/.devcontainer/devcontainer.json" \
```

### ワークフローファイルへの追加

`.github/workflows/image-build.yml` の `build` ジョブの `Build and Push Variant` ステップと、`test` ジョブの `Test Variant` ステップの `VARIANTS` 環境変数に `foo` を追加する。

```yaml
        env:
          VARIANTS: "basic dind node typescript-node clasp rust-base rust rust-cli foo"
```

> [!NOTE]
> 追加するとき、継承関係にある Variant があればその後ろに追加する。


### dependabot 設定へ追加

`.github/dependabot.yml` へ以下のように設定を追加する。

```yaml
  - package-ecosystem: "devcontainers"
    directory: "/src/foo"
    schedule:
      interval: "weekly"
```

## プッシュ先を設定

イメージ、キャッシュをプッシュするリポジトリやタグなどを変更するような場合、`scripts/util.sh` 内の各関数を変更する。



