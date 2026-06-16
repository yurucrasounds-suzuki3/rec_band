# RecBand MVP

「スマホ1台で、誰でもバンドができる」を最優先にした、Flutter + Firebase の iOS 向け MVP です。

この段階では、

- ユーザー登録 / ログイン
- 曲の投稿
- 曲一覧
- 曲詳細
- 参加音源の投稿
- 元曲と参加音源の個別再生

までを実装しています。高音質化、同期再生、コメント、SNS 的機能はあえて入れていません。

## 技術スタック

- Flutter 3.38.x
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- `provider`
- `just_audio`
- `file_picker`

## 画面構成

- ログイン画面
- 新規登録画面
- ホーム画面
- 曲一覧画面
- 曲投稿画面
- 曲詳細画面
- 参加音源投稿画面
- マイページ画面

ホーム画面は下部タブで以下を切り替えます。

- `曲を探す`
- `曲を投稿`
- `マイページ`

## ディレクトリ構成

```text
lib/
  app.dart
  main.dart
  models/
    app_user.dart
    part.dart
    song.dart
  screens/
    app_bootstrap_screen.dart
    auth/
    home/
    mypage/
    parts/
    songs/
  services/
    auth_service.dart
    part_service.dart
    song_service.dart
    storage_service.dart
  theme/
    app_theme.dart
  utils/
    formatters.dart
  widgets/
    audio_player_tile.dart
    brand_header.dart
    part_card.dart
    song_card.dart
```

## 必要なパッケージ

`pubspec.yaml` に追加済みです。

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `file_picker`
- `just_audio`
- `provider`
- `intl`

## Firestore 設計

### `users`

ユーザー基本情報です。

```json
{
  "uid": "auth uid",
  "displayName": "Kuniaki",
  "email": "user@example.com",
  "createdAt": "server timestamp"
}
```

### `songs`

元曲の投稿です。

```json
{
  "songId": "auto id",
  "title": "夏のデモ",
  "comment": "ギター募集、ドラム募集",
  "ownerUid": "auth uid",
  "ownerName": "投稿者名",
  "audioUrl": "https://...",
  "audioPath": "songs/{uid}/{songId}/{filename}",
  "createdAt": "server timestamp"
}
```

### `parts`

参加音源です。

```json
{
  "partId": "auto id",
  "songId": "songs の doc id",
  "partName": "ギターソロ",
  "uploaderUid": "auth uid",
  "uploaderName": "参加者名",
  "audioUrl": "https://...",
  "audioPath": "parts/{songId}/{uid}/{partId}/{filename}",
  "createdAt": "server timestamp"
}
```

### Firestore インデックス

`parts` は `where(songId == ...) + orderBy(createdAt desc)` を使うので複合インデックスが必要です。

同梱ファイル:

- [firestore.indexes.json](/Users/kuniaki/Documents/GitHub/rec_band/firestore.indexes.json)
- [firestore.rules](/Users/kuniaki/Documents/GitHub/rec_band/firestore.rules)

## Storage 設計

### 保存パス

- 元曲: `songs/{uid}/{songId}/{filename}`
- 参加音源: `parts/{songId}/{uid}/{partId}/{filename}`

### ルール例

同梱ファイル:

- [storage.rules](/Users/kuniaki/Documents/GitHub/rec_band/storage.rules)

## Firebase 設定手順

### 1. Firebase プロジェクトを作成

1. Firebase Console で新規プロジェクトを作成
2. Authentication, Firestore, Storage を有効化
3. iOS アプリを追加

### 2. iOS アプリを登録

Firebase Console で以下を設定します。

- Apple bundle ID: `com.example.recBand` など任意
- App nickname: `RecBand`

その後、`GoogleService-Info.plist` をダウンロードして [ios/Runner](/Users/kuniaki/Documents/GitHub/rec_band/ios/Runner) に追加してください。

Xcode を開いたら `Runner` ターゲット配下に `GoogleService-Info.plist` が入っていることを確認してください。

### 3. Authentication を設定

Firebase Console の Authentication で以下を有効化します。

- メール / パスワード

### 4. Firestore を設定

1. Firestore Database を作成
2. 最初はテストモードで作成してもよいですが、実機確認前に `firestore.rules` を反映してください
3. 複合インデックスが必要なので `firestore.indexes.json` も反映してください

CLI を使う場合の例:

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 5. Storage を設定

1. Storage を作成
2. `storage.rules` を反映

CLI を使う場合の例:

```bash
firebase deploy --only storage
```

## ローカル起動手順

### 前提

- Flutter SDK が入っていること
- Xcode が入っていること
- iOS 実機または Simulator が使えること
- Firebase の `GoogleService-Info.plist` を配置済みであること

### 起動

```bash
flutter pub get
flutter run
```

iOS デバイスを明示する場合:

```bash
flutter devices
flutter run -d <device_id>
```

## iOS 実機テスト手順

1. iPhone を Mac に接続
2. `open ios/Runner.xcworkspace` で Xcode を開く
3. `Runner` の Signing & Capabilities で Team を選ぶ
4. Bundle Identifier を Firebase に登録したものと一致させる
5. `GoogleService-Info.plist` が `Runner` ターゲットに含まれていることを確認
6. 実機を選んでビルド
7. 初回は iPhone 側で開発者モードや署名許可を行う

## MVP の使い方

1. 新規登録する
2. `曲を投稿` で音声ファイルと曲名、募集メッセージを登録する
3. `曲を探す` で投稿された曲一覧を見る
4. 任意の曲詳細を開く
5. `この曲に参加する` から自分の演奏音源を投稿する
6. 元の曲と参加音源をそれぞれ個別に再生する

## 実装上の割り切り

- 音声は個別再生のみ
- 同期再生やミックスは未実装
- 録音機能は未実装
- まずは端末内の音声ファイル選択のみ
- Android は未対応

## 今後の拡張候補

- アプリ内録音
- 参加音源の絞り込み
- 自分の投稿曲 / 参加曲一覧
- 同期再生プレビュー
- 通知
- 波形表示

## 検証状況

2026-06-17 時点で、ローカルで以下を実行しています。

- `flutter analyze`
- `flutter test`

どちらも成功しています。
