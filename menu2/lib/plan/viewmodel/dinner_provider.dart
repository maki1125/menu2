import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_repository.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/plan/viewmodel/dinner_viewmodel.dart';
import 'package:menu2/plan/data/model/dinner.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';


//⭐️自由入力メニュー関連**************************************************************
//メニューリポジトリのプロバイダー======================================
final customMenuRepositoryProvider = Provider((ref) {
  return FirestoreRepository<Menu>(
    ref: ref,
    collectionName: "customMenus",
    fromFirestore: (data) => Menu.fromFirestore(data),
    toFirestore: (menu) => menu.toMap(),
  );
});

//⭐️夕食関連**************************************************************
//ディナーリポジトリのプロバイダー======================================
final dinnerRepositoryProvider = Provider((ref) {
  return FirestoreRepository<Dinner>(
    ref: ref,
    collectionName: "dinners",
    fromFirestore: (data) => Dinner.fromFirestore(data),
    toFirestore: (dinner) => dinner.toMap(),
  );
});

//リアルタイム夕食リスト取得を管理するプロバイダー===================================================
final dinnersProvider = StreamProvider<List<Dinner>>((ref) {
  final dinnerRepo = ref.read(dinnerRepositoryProvider);
  final familyId = ref.watch(familyIdProvider);

  //userIdは非同期で取得のため、タイミングによってnullの場合あるため。
  if (familyId == null) {
    return Stream.value([]); // userIdがnullなら空リストを返す
  }
  return dinnerRepo.fetchData();

});

//表示用夕食リスト===================================================
final dispDinnersProvider = Provider<List<Dinner>>((ref){
  final allDinners = ref.watch(dinnersProvider).value ?? []; //List<Menu>
  final selectedDropDown = ref.watch(selectedDropDownProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final selectedWeek = calWeek(selectedDate);
  

  //print("selectedWeeke:${selectedWeek[0]}");

  List<Dinner> dispDinners = allDinners;
  dispDinners = [...dispDinners]..sort((a, b) => b.date.compareTo(a.date));

  //月・週・日フィルター
  switch(selectedDropDown){
    case "月":
     dispDinners = (dispDinners).where((dinner){
      return dinner.date.year == selectedDate.year 
        && dinner.date.month == selectedDate.month;
      }).toList();
    break;

    case "週":
    DateTime toDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final start = toDateOnly(selectedWeek[0]);
    final end = toDateOnly(selectedWeek[6]).add(const Duration(days: 1)); // 翌日の0:00未満まで含める
      dispDinners = dispDinners.where((dinner) {
  final dinnerDate = toDateOnly(dinner.date); // 時刻を落とす
  return (dinnerDate.isAtSameMomentAs(start) || 
          (dinnerDate.isAfter(start) && dinnerDate.isBefore(end)));
}).toList();
        break;
    
    case "日":
      dispDinners = (dispDinners).where((dinner){
        return dinner.date.year == selectedDate.year 
          && dinner.date.month == selectedDate.month 
          && dinner.date.day == selectedDate.day;
          }).toList();
          break;
    
    default:
     break;
  }
  return dispDinners;
});


//リアルタイムメニューリスト取得を管理するプロバイダー===================================================
final customMenusProvider = StreamProvider<List<Menu>>((ref) {

  final customMenuRepo = ref.read(customMenuRepositoryProvider);
  final familyId = ref.watch(familyIdProvider);
  //userIdは非同期で取得のため、タイミングによってnullの場合あるため。
  if (familyId == null) {
    //print("custom familyIdがnullです。");
    return Stream.value([]); // userIdがnullなら空リストを返す
  }
  //print(userId);
  //print("custom familyId:$familyId。");
  //return dinnerRepo.fetchMenus();
  return customMenuRepo.fetchData();
});

//表示用メニューリスト===================================================
final dispCustomMenusProvider = Provider<List<Menu>>((ref){
  //print("dispCustomMenusProvider");
  final allMenus = ref.watch(customMenusProvider).value ?? []; //List<Menu>

  List<Menu> dispMenus = allMenus;
  dispMenus = [...dispMenus]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return dispMenus;
});

//夕飯選択の合計金額
final dinnerTotalProvider = Provider<int>((ref){
  final dispMenus = ref.watch(dispMenusProvider);
  final dispCustomMenus = ref.watch(dispCustomMenusProvider);
  final peopleMap = ref.watch(peopleMapProvider);

  //menuの合計
  final totalPriceMenus = dispMenus.fold<int>(0, (sum, menu) {
    final count = peopleMap[menu.id] ?? menu.people;
    return sum + ((menu.price/menu.people) * count).round();
  });
  
  //customMenusの合計
  final totalPriceCustomMenus = dispCustomMenus.fold<int>(0, (sum, menu) {
    return sum + menu.price ;
  });

  return totalPriceMenus + totalPriceCustomMenus;
});


final dinnerViewModelProvider = Provider((ref) => DinnerViewModel (ref));

//フィルターのプルダウンの選択項目
final StateProvider<String> selectedDropDownProvider = StateProvider<String>((ref) {
  return "";
});

