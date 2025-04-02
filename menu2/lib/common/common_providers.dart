import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

//ボトムバーの選択
final bottomBarIndexProvider = StateProvider<int>((ref) => 0); 
//ボトムバーの選択
final pageIndexProvider = StateProvider<int>((ref) => 0); 

//検索ボックステキスト
final searchTextProvider = StateProvider<String>((ref) => '');

//検索ボックステキストフィールドのコントローラ管理.テキストフィールドをクリアするため。
final searchTextControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

//カードのソート（あいう順）
final sortAiuFlgProvider = StateProvider<bool>((ref) => false);

//カードのソート（日付降順順）
final sortDayFlgProvider = StateProvider<bool>((ref) => false);
