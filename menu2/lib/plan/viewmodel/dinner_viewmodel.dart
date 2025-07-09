
import 'package:intl/intl.dart'; //DateFormat使用するため。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_repository.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_utils.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';
import 'package:menu2/plan/data/model/dinner.dart';


//各種処理
class DinnerViewModel {

  final Ref ref;
  final FirestoreRepository dinnerRepo;
  final FirestoreRepository customMenuRepo;

    DinnerViewModel(this.ref)
  : dinnerRepo = ref.read(dinnerRepositoryProvider),
  customMenuRepo = ref.read(customMenuRepositoryProvider);

  Dinner createDinner(){
    ref.read(loadingFlgProvider.notifier).state = true;

    final dispMenus = ref.read(dispMenusProvider);
    final dispCustomMenus = ref.read(dispCustomMenusProvider);
    final selectedDate = ref.read(selectedDateProvider);
    //final peopleMap = ref.read(peopleMapProvider);
    final familyId = ref.read(familyIdProvider);
    //final allMenus = [...dispMenus, ...dispCustomMenus];
    final menuViewModel = ref.read(menuViewModelProvider);
    //final dinner =Dinner();
    int totalPrice = ref.read(dinnerTotalProvider);
    
    //料理名がないときはデータ保存しない。
    /*
    if (dinner!.menus.isEmpty) {
      ref.read(errorMessageProvider.notifier).state = 'メニューがありません';
      print('メニューがありません');
      print('');
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }
    */

    //menusの作成。List<Map<String, dynamic>> menus;//menuId,name,customFlg
    final dinnerMenus1 = dispMenus.map((menu)
     {
      //final people = peopleMap[menu.id] ?? 1; // peopleMapから取得、なければ1人前
      //totalPrice += ((menu.price/menu.people) * people).round();
      menu.dinnerDateBuf = menu.dinnerDate;
      menu.dinnerDate = selectedDate;
      menuViewModel.iconProcess(menu);
      return{'menuId':menu.id, 'name':menu.name, 'customFlg':false};}
     ).toList();

     //menusの作成。List<Map<String, dynamic>> menus;//menuId,name,customFlg
    final dinnerMenus2 = dispCustomMenus.map((menu)
     {
      //totalPrice +=  menu.price;
      return{'menuId':menu.id, 'name':menu.name, 'customFlg':true};}
     ).toList();

     final dinnerMenus = [...dinnerMenus1, ...dinnerMenus2];

      final dinner = Dinner(
      date: selectedDate,// ?? DateTime.now(),
      menus: dinnerMenus,
      totalPrice: totalPrice,
      familyId: familyId!,
    );

    return dinner;
  }

  //自由登録メニューの新規登録=========================================
  Future<bool> newDinner() async {
    final dispDinners = ref.read(dispDinnersProvider);
   // print("dispDinner:${dispDinners.length}");
    bool limitCheckResult = limitCheck(ref, dispDinners);

    //匿名ログインの場合は保存に制限あり
    if(!limitCheckResult){
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }

final dinner = createDinner();
if(dinner.menus.isEmpty){
  ref.read(errorMessageProvider.notifier).state="夕食を選択してください";
  ref.read(loadingFlgProvider.notifier).state = false;
  return false;
}
    dinnerRepo.addData(dinner);
    ref.read(loadingFlgProvider.notifier).state = false;
    return true;
    
  }

   //メニュー削除
  Future<void> deleteDinner(dinner) async {
    final menuViewModel = ref.read(menuViewModelProvider);
    final allMenus = ref.read(menusProvider).value ?? []; //List<Menu>
    //print("deleteDinner");
    //await menuRepo.deleteMenu(menu!);//メニューの削除
    //print(dinner.menus.length);
    dinner.menus.forEach((menu){
      if(!menu["customFlg"]){
        
        final menu1 = allMenus.firstWhere(
          (allMenu)=>allMenu.id == menu["menuId"],
          orElse: () => Menu(),
          );
      //print(menu["name"]);
      //print(menu1.name);
      if(menu1.name!=""){//メニューが消されている場合あるため。
      menu1.dinnerDate = menu1.dinnerDateBuf;
      menu1.dinnerDateBuf=null;
      menuViewModel.iconProcess(menu1);
      }
      
      }
      

    });

  
    await dinnerRepo.deleteData(dinner);//メニューの削除

    //ref.read(menuProvider.notifier).state = null;
  }

  //フィルター日数の表示
  String dispFilterDate(){
    final selectedDate = ref.read(selectedDateProvider);
    final selectedDropDown = ref.read(selectedDropDownProvider);
    final selectWeek = calWeek(selectedDate); //選択日の１週間リスト
    String dispText = "";

    //selectedDate == null //日付選択がまだの状態
      //? dispText = "日付選択して下さい"
      //: 
      selectedDropDown == "月" //フィルタ選択が月の場合
        ? dispText = '${selectedDate.year}年${selectedDate.month}月'
        : selectedDropDown == "週" //フィルタ選択が月の場合
          ? dispText = "${DateFormat('yyyy/MM/dd(E)','ja').format(selectWeek[0])}～${DateFormat('yyyy/MM/dd(E)','ja').format(selectWeek[6])}"
          //'${dateFormat(selectWeek[0])} ～ ${dateFormat(selectWeek[6])}' //フィルタ選択が週の場合
          : dispText = DateFormat('yyyy/MM/dd(E)','ja').format(selectedDate);
    return dispText;
  }

//夕食選択の合計金額
int dinnerTotalPrice(){
  final dispMenus = ref.read(dispMenusProvider);
  final dispCustomMenus = ref.read(dispCustomMenusProvider);

  //menuの合計
  final totalPriceMenus = dispMenus.fold<int>(0, (sum, menu) {
    final count = ref.watch(peopleMapProvider)[menu.id] ?? 1;
    return sum + ((menu.price/count) * count).round();
  });
  //customMenusの合計
  final totalPriceCustomMenus = dispCustomMenus.fold<int>(0, (sum, menu) {
    return sum + menu.price ;
  });
  return totalPriceMenus + totalPriceCustomMenus;
  }

  //夕食履歴の合計金額
int dispDinnersTotalPrice(){
  final dispDinners = ref.read(dispDinnersProvider);

  //dinnersの合計
  final totalPrice = dispDinners.fold<int>(0, (sum, dinner) {
    return sum + dinner.totalPrice;
  });
  return totalPrice;
  }


}

//メソッドーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
// 月曜日の日付取得
DateTime foundMonday(DateTime date) {
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

//選択日付を含む週の算出
List<DateTime> calWeek(DateTime selectedDate){
  return [
    for (var i = 0; i < 7; i++) foundMonday(selectedDate).add(Duration(days: i))
  ];
}


    
