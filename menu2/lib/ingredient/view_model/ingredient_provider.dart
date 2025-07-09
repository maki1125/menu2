import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_repository.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/ingredient/view_model/ingredient_viewmodel.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';


//材料リポジトリのプロバイダー_======================================
final ingRepositoryProvider = Provider((ref) {
  return FirestoreRepository<Ing>(
    ref: ref,
    collectionName: "ingredients",
    fromFirestore: (data) => Ing.fromFirestore(data),
    toFirestore: (ing) => ing.toMap(),
  );
});

//リアルタイム材料ーリスト取得を管理するプロバイダー_===================================================
final ingsProvider = StreamProvider<List<Ing>>((ref) {
  final ingRepo = ref.read(ingRepositoryProvider);
  final familyId = ref.watch(familyIdProvider);
  //final userId = ref.watch(userIdProvider);

  //userIdは非同期で取得のため、タイミングによってnullの場合あるため。
  if (familyId == null) {
    //print("familyIdがnullなので[]");
    return Stream.value([]); // userIdがnullなら空リストを返す
  }
  return ingRepo.fetchData();
});

//表示用メニューリスト_==============================================
final dispIngsProvider = Provider<List<Ing>>((ref){
  final allIngs = ref.watch(ingsProvider).value ?? []; //List<Menu>
  final searchText = ref.watch(searchTextProvider);
  final sortAiuFlg = ref.watch(sortAiuFlgProvider);
  final sortDayFlg = ref.watch(sortDayFlgProvider);
  
  List<Ing> dispIngs = allIngs;

  //検索単語フィルター
  if(searchText.isNotEmpty){
    dispIngs = (dispIngs).where((ing) {
      final isMatch = ing.name.contains(searchText);
      return isMatch;
    }).toList();
  }

  //あいうえお順ソート
  if(sortAiuFlg){
    dispIngs = [...dispIngs]..sort((a, b) => a.name.compareTo(b.name));
  }

  //日付降順ソート
  if(sortDayFlg){
    dispIngs = [...dispIngs]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  return dispIngs;
});

//複数メニューのテキストフィールドの状態メソッド============================================
final ingTextControllerListProvider = StateNotifierProvider<IngTextConNotifier, List<IngTextControllers>>((ref) {
  return IngTextConNotifier();
});

class IngTextConNotifier extends StateNotifier<List<IngTextControllers>> {
  IngTextConNotifier() : super([IngTextControllers()]);

  //テキストフィールド１行追加
  void addController() {
    state = [...state, IngTextControllers()];
  }

  //指定のテキストフィールド削除
  void removeController(int index) {
    if (index >= 0 && index < state.length) {
      state[index].allDispose(); // メモリリーク防止
      final newList = [...state]..removeAt(index);
      state = newList;
    }
  }

  //全てのテキストフィールドの削除
  void disposeAll() {
    for (final controllers in state) {
      controllers.allDispose();
    }
    state = [IngTextControllers()];
  }

  //指定の要素数にする
  void setList(int i){
    //state = List.filled(i, IngTextControllers());同じインスタンスを入れている
    state = List.generate(i, (_) => IngTextControllers());//別のインスタンスを入れる。
  }

  // 材料テキストフィールドに初期値をセットする
  void initializeFromMenu(List<Ing> ings) {
    // いったん全部 dispose
    disposeAll();
    // 初期データを入れ直し
    final newList = ings.map((ing) => IngTextControllers(ing: ing)).toList();
    state = newList.isEmpty ? [IngTextControllers()] : newList;
    //print("state:${state.length}");
  }

}
//複数メニューのテキストフィールドの状態メソッド============================================
final menuIngTextControllerListProvider = StateNotifierProvider<MenuIngTextConNotifier, List<IngTextControllers>>((ref) {
  return MenuIngTextConNotifier();
});

class MenuIngTextConNotifier extends StateNotifier<List<IngTextControllers>> {
  MenuIngTextConNotifier() : super([IngTextControllers()]);

  //テキストフィールド１行追加
  void addController() {
    state = [...state, IngTextControllers()];
  }

  //指定のテキストフィールド削除
  void removeController(int index) {
    if (index >= 0 && index < state.length) {
      state[index].allDispose(); // メモリリーク防止
      final newList = [...state]..removeAt(index);
      state = newList;
    }
  }

  //全てのテキストフィールドの削除
  void disposeAll() {
    for (final controllers in state) {
      controllers.allDispose();
    }
    state = [IngTextControllers()];
  }

  //指定の要素数にする
  void setList(int i){
    //state = List.filled(i, IngTextControllers());同じインスタンスを入れている
    state = List.generate(i, (_) => IngTextControllers());//別のインスタンスを入れる。
  }

  // 材料テキストフィールドに初期値をセットする
  void initializeFromMenu(List<Ing> ings) {
    // いったん全部 dispose
    disposeAll();
    // 初期データを入れ直し
    final newList = ings.map((ing) => IngTextControllers(ing: ing)).toList();
    state = newList.isEmpty ? [IngTextControllers()] : newList;
    //print("state:${state.length}");
  }

}

//複数メニューのテキストフィールドの状態メソッド============================================
final selectIngTextControllerListProvider = StateNotifierProvider<SelectIngTextConNotifier, List<SelectIngTextControllers>>((ref) {
  return SelectIngTextConNotifier();
});

class SelectIngTextConNotifier extends StateNotifier<List<SelectIngTextControllers>> {
  SelectIngTextConNotifier() : super([]);

  //テキストフィールド１行追加
  void addController(Ing ing, WidgetRef ref) {
    //print("addcontroller");
    //print(ref.read(menuTotalPriceCalTrigerProvider));
    
    final newList = [...state, SelectIngTextControllers(ing:ing)];
    state = newList;
    ref.read(menuTotalPriceCalTrigerProvider.notifier).state = !ref.read(menuTotalPriceCalTrigerProvider);
    //print(ref.read(menuTotalPriceCalTrigerProvider));
    
  }

  //指定のテキストフィールド削除
  void removeController(int index) {
    if (index >= 0 && index < state.length) {
      state[index].dispose(); // メモリリーク防止
      final newList = [...state]..removeAt(index);
      state = newList;
    }
  }

  //全てのテキストフィールドの削除
  void disposeAll() {
    for (final controllers in state) {
      controllers.dispose();
    }
    state = [];
  }

}


//単一メニューのプロバイダー_==================================
final ingProvider = StateProvider<Ing>((ref) {
  return Ing();
});

// viewmodelの管理=========================================
final ingViewModelProvider = Provider((ref) => IngViewModel(ref));

//合計金額の計算トリガー_==================================
final menuTotalPriceCalTrigerProvider = StateProvider<bool>((ref) {
  return false;
});

//材料一覧から選択フラグのプロバイダー_==================================
final selectIngFlgProvider = StateProvider<bool>((ref) {
  return false;
});

// 編集か新規登録か管理============================
final ingEditFlgProvider = StateProvider<bool>((ref) => false);






