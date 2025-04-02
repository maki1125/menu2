import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/data/repository/menu_repository.dart';
import 'package:menu2/user/view_model/user_view_model.dart';
import 'package:menu2/user/data/repository/user_repository.dart';

//メニューリポジトリのプロバイダー
final menuRepoProvider = Provider<MenuRepository>((ref){
  return MenuRepository();
});

//全メニューリスト
final menusProvider = StreamProvider<List<Menu>>((ref) {
  final menuRepo = ref.read(menuRepoProvider);
  final userId = ref.watch(userIdProvider);

  //userIdは非同期で取得のため、タイミングによってnullの場合あるため。
  if (userId == null) {
    return Stream.value([]); // userIdがnullなら空リストを返す
  }
  //print(userId);
  return menuRepo.fetchMenus(userId);
});

//表示用メニューリスト
final dispMenusProvider = Provider<List<Menu>>((ref){
  final allMenus = ref.watch(menusProvider).value ?? []; //List<Menu>
  final tabIndex = ref.watch(tabIndexProvider);
  //final searchTextController = ref.watch(searchTextControllerProvider);
  final searchText = ref.watch(searchTextProvider);
  final sortAiuFlg = ref.watch(sortAiuFlgProvider);
  final sortDayFlg = ref.watch(sortDayFlgProvider);
  
  List<Menu> dispMenus = allMenus;

  //カテゴリーフィルター
  if(tabIndex>=4){
    dispMenus = (allMenus).where((menu) {
      final isMatch = tagToIndex(menu.tag) == tabIndex;
      return isMatch;
    }).toList();
  }

  //検索単語フィルター
  if(searchText.isNotEmpty){
    dispMenus = (dispMenus).where((menu) {
      final isMatch = menu.name.contains(searchText);
      return isMatch;
    }).toList();
  }

  //あいうえお順ソート
  if(sortAiuFlg){
    print("あいうえお順ソート実行");
    dispMenus = [...dispMenus]..sort((a, b) => a.name.compareTo(b.name));
  }

  //日付降順ソート
  if(sortDayFlg){
    print("日付降順ソート実行");
    dispMenus = [...dispMenus]..sort((a, b) => b.createAt.compareTo(a.createAt));
  }

  return dispMenus;
});

//タグ名からタブバーのindexに変換する関数。タグを表示する順番を変更できるように。
int tagToIndex(String tag){
  return tagToTabindex[tag] ?? 0;
}

// タブのインデックスを管理する StateProvider
final tabIndexProvider = StateProvider<int>((ref) => 0);

//詳細メニュー
class MenuNotifier extends StateNotifier<Menu?> {
  final MenuRepository _menuRepo;
  MenuNotifier(this._menuRepo) : super(null);//MenuRepositoryを受け取る。


  //状態をセットするメソッド
  void setMenu(Menu menu){
    state = menu;
  }

  //メニューを削除
  Future<void> deleteMenu() async {
    //if (state == null) return;
    await _menuRepo.deleteMenu(state!);
    state = null; // 削除後は state を null にする
  }

  //メニューを追加
  Future<void> addMenu(Menu menu) async {
    //if (state == null) return;
    await _menuRepo.addMenu(menu);
    state = menu; // 削除後は state を null にする
  }

  //メニューを更新
  Future<void> updateMenu(Menu menu) async {
    //print("updateしました。${state}");
    //if (state == null) return;
    await _menuRepo.updateMenu(menu);
    //print("updateしました。");
    state = menu.copyWith(); //インスタンスを更新して変更を検知する
  }
}

//単一メニューのプロバイダー
final menuProvider = StateNotifierProvider<MenuNotifier, Menu?>((ref) {
  final repository = ref.read(menuRepoProvider);
  return MenuNotifier(repository);
});

//final menuProvider = StateProvider<Menu?>((ref)=>null);

//検索ボックステキストフィールドのコントローラ管理.テキストフィールドをクリアするため。
final nameTextControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

//登録ボタンの処理
void editButtonFunc(){

}


