
import 'package:flutter/material.dart';

import 'package:menu2/menu/view/menu_list_view.dart';
import 'package:menu2/ingredient/view/ingredient_list_view.dart';
import 'package:menu2/plan/view/plan_list_view.dart';

//ボトムバー表示のページ
List<Widget> pages = [
  const MenuList(),
  const IngList(),
  const PlanList(),

];

//ボトムバー表示のタイトル
List<String> appBarTitle = [
  'メニュー一覧',
  '材料一覧',
  '献立',

];

//トップタブの設定
final List<String> tabs = [
  '全て',
  '夕食',
  '予定',
  'お気に入り', 
  'メイン',
  'サブ',
  '麺類',
  'ご飯もの',
  'その他'
];

//トップタブの表示順番
final Map<String, int> tagToTabindex =
{
  'メイン': 4,
  'サブ':5,
  '麺類':6,
  'ご飯もの':7,
  'その他':8
};

//メニュー登録のタグの選択肢
final List<String> menuTags =[
  'カテゴリー無',
  'メイン',
  'サブ',
  '麺類',
  'ご飯もの',
  'その他'
];

// ログイン時のエラーメッセージ
class AuthErrorMessages {
  static const unknownError = 'エラーが発生しました';
  static const userNotFound = 'ユーザーが見つかりません';
  static const wrongPassword = 'パスワードが間違っています';
  static const invalidEmail = '無効なメールアドレスです';
  //static const weakPassword = 'パスワードが脆弱です, 6文字以上で入力してください';
  //static const emailAlreadyInUse = 'そのアカウント名は既に使用されています';
  static const operationNotAllowed = 'アカウントが有効ではありません';
  static const userDisabled = 'ユーザーが存在しません';
  //static const accountExistCrediential = 'このGoogleアカウントは既に使用されています';
  //static const invalidCredential = '無効な認証情報です';
  static const credentialAlreadyInUse = 'その認証情報は既に使用されています';
  //static const requiresRecentLogin = '再度ログインしてください';
}
