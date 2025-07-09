import 'dart:io'; //Fileを扱うため
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_repository.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/data/repository/image_repository.dart';
import 'package:menu2/menu/view_model/menu_viewmodel.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';


//メニューリポジトリのプロバイダー=====================================
final menuRepositoryProvider = Provider((ref) {
  return FirestoreRepository<Menu>(
    ref: ref,
    collectionName: "menus",
    fromFirestore: (data) => Menu.fromFirestore(data),
    toFirestore: (menu) => menu.toMap(),
  );
});

//画像リポジトリのプロバイダー======================================
final imageRepositoryProvider = Provider((ref) => ImageRepository(ref));

//リアルタイムメニューリスト取得を管理するプロバイダー===================================================
final menusProvider = StreamProvider<List<Menu>>((ref) {
  final menuRepo = ref.read(menuRepositoryProvider);
  final familyId = ref.watch(familyIdProvider);
  //print("menusProvider:$familyId");
  //print("");

  //userIdは非同期で取得のため、タイミングによってnullの場合あるため。
  if (familyId == null) {
    //print("familyIdがnullなので[]");
    return Stream.value([]); // userIdがnullなら空リストを返す
  }
  return menuRepo.fetchData();
});

//メニューリストのバッファのプロバイダー_===========================================
final menusBuffProvider = StateProvider<List<Menu>>((ref) {
  return [];
});



//表示用メニューリスト===================================================
final dispMenusProvider = Provider<List<Menu>>((ref){
  final allMenus = ref.watch(menusProvider).value ?? []; //List<Menu>
  final tabIndex = ref.watch(menuToptabIndexProvider);
  final searchText = ref.watch(searchTextProvider);
  final sortAiuFlg = ref.watch(sortAiuFlgProvider);
  final sortDayFlg = ref.watch(sortDayFlgProvider);
  
  List<Menu> dispMenus = allMenus;

  //夕食フィルター
  if(tabIndex==1){
    dispMenus = (allMenus).where((menu) {
      final isMatch = menu.isDinner == true;
      return isMatch;
    }).toList();
  }

  //予定フィルター
  if(tabIndex==2){
    dispMenus = (allMenus).where((menu) {
      final isMatch = menu.isPlan == true;
      return isMatch;
    }).toList();
  }

  //お気に入りフィルター
  if(tabIndex==3){
    dispMenus = (allMenus).where((menu) {
      final isMatch = menu.isFavorite == true;
      return isMatch;
    }).toList();
  }

  //カテゴリー(メイン、汁物、、、）フィルター
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
    //print("あいうえお順ソート実行");
    dispMenus = [...dispMenus]..sort((a, b) => a.name.compareTo(b.name));
  }

  //日付降順ソート
  if(sortDayFlg){
    //print("日付降順ソート実行");
    dispMenus = [...dispMenus]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return dispMenus;
});



//単一メニューのプロバイダー_===========================================
final menuProvider = StateProvider<Menu?>((ref) {
  return Menu();
});




//メニューのテキストフィールドの管理_==========================================
final menuTextControllersProvider = Provider<MenuTextControllers>((ref) {
  final controllers = MenuTextControllers();
  ref.onDispose(() {
    controllers.dispose();
  });
  return controllers;
});


// 編集か新規登録か管理============================
final editFlgProvider = StateProvider<bool>((ref) => false);

// メニュー登録かメニュー一覧か管理（材料選択に使用）============================
final createFlgProvider = StateProvider<bool>((ref) => false);

//選択画像ファイルを管理
final selectedImageProvider = StateProvider<File?>((ref) => null);

// 画像選択中フラグ============================
final selectImageFlgProvider = StateProvider<bool>((ref) => false);


// viewmodelの管理============================
final menuViewModelProvider = Provider((ref) => MenuViewModel(ref, 'menu'));

// viewmodelの管理==========================================================
// Repoとviewmodelはmenuと共通。同じMenuインスタンスを扱い、保存先が異なるだけのため。
final customMenuViewModelProvider = Provider((ref) => MenuViewModel (ref, 'customMenu'));

//メニュー毎の何人前を管理するプロバイダー。menuId:何人前。夕食登録時に使用。
final peopleMapProvider = StateProvider<Map<String, int>>((ref) => {});

//メニュー毎のカテゴリータグを管理するプロバイダー。メイン、汁物
final tagProvider = StateProvider<String?>((ref) => null);//タグの初期値にhintを表示させるため。valueがnullの時hintが表示される。


//合計金額_=================================================================================
final ingTotalPriceProvider = Provider<int>((ref) {
  ref.watch(menuTotalPriceCalTrigerProvider); //テキストフィールドの値の変更をキャッチする
  final selectIngTextControllersList = ref.watch(selectIngTextControllerListProvider); //材料フィールドの追加や削除
  final ingTextControllersList = ref.watch(menuIngTextControllerListProvider);

  int total = 0;
  for (final controller in ingTextControllersList) {
    final price = int.tryParse(controller.priceController.text) ?? 0;
    total += price;
  }
  for (final controller in selectIngTextControllersList) {
    final price = controller.unitPrice;
    final quantity = double.tryParse(controller.quantityController.text) ?? 0;
    total += (price * quantity).round();
  }

  return total;
});




//画像の再取得履歴。
final fetchImageUrlBuffProvider = StateProvider<List>((ref){
  return []; 
});




