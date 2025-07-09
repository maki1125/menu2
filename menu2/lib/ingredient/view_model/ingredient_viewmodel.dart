import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_repository.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_utils.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';


//各種処理
class IngViewModel {
  final Ref ref;
  final FirestoreRepository ingRepo;

  IngViewModel(this.ref)
  : ingRepo = ref.read(ingRepositoryProvider);


  //材料の新規登録
  Future<bool> newIngs() async {
    //ref.read(isLoadingProvider.notifier).state = true;
    final dispIngs = ref.read(dispIngsProvider);
    //print("dispDinner:${dispIngs.length}");
    bool limitCheckResult = limitCheck(ref, dispIngs);

    //匿名ログインの場合は保存に制限あり
    if(!limitCheckResult){
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }

    final ingTextControllersList = ref.read(ingTextControllerListProvider);
    
    //全てのテキストフィールドのバリデーションチェック
    final result = validation(ingTextControllersList);
    if(!result){
      return false;
    }
    
    //登録処理
    for (int i = 0; i < ingTextControllersList.length; i++){
      //テキストフィールドの内容からingProviderを更新。
      textControllerToIng(ingTextControllersList[i]); 

      //メニューの新規保存
      final ing = ref.read(ingProvider);
      ingRepo.addData(ing);
    }
    return true;

    }

  //メニュー更新==============================================
  Future<bool> updateIng() async {
    final ingTextControllersList = ref.read(ingTextControllerListProvider);
    //バリデーションチェック
    final result = validation(ingTextControllersList);
    if(!result){
      return false;
    }

    //更新処理
    final ingTextConList = ref.read(ingTextControllerListProvider);
    textControllerToIng(ingTextConList[0]);
    final ing = ref.read(ingProvider);
    ingRepo.updateData(ing);
    //print("update");

    return true;

  }

  //テキストフィールの内容から材料作成============================
  void textControllerToIng(ingTextCon){
    //final ingTextConList = ref.read(ingTextControllerListProvider);
    if(ingTextCon.nameController.text.isNotEmpty){
      final ing = ref.read(ingProvider);
    ing.name = ingTextCon.nameController.text;
    ing.quantity = double.tryParse(ingTextCon.quantityController.text)!;//trim() は 文字列の前後の空白（スペースや改行など）を削除 する
    ing.unit = ingTextCon.unitController.text;
    ing.price = int.tryParse(ingTextCon.priceController.text)!;//trim() は 文字列の前後の空白（スペースや改行など）を削除 する

    ref.read(ingProvider.notifier).state = ing;
    }
    
    //ingTextCon.priceController.clear();
  }

  //材料一覧から選択のテキストフィールの内容から材料作成============================
  void selectTextControllerToIng(index){
    final selectIngTextConList = ref.read(selectIngTextControllerListProvider);
    final ing = ref.read(ingProvider);
    ing.name = selectIngTextConList[index].name;
    ing.quantity = double.tryParse(selectIngTextConList[index].quantityController.text)!;//trim() は 文字列の前後の空白（スペースや改行など）を削除 する
    ing.unit = selectIngTextConList[index].unit;
    ing.price = selectIngTextConList[index].subtotal.round();
    ref.read(ingProvider.notifier).state = ing;
  }

//メニュー削除==================================================
  Future<void> deleteIng(ing) async {
    //await ingRepo.deleteIng(ing!);//メニューの削除
    await ingRepo.deleteData(ing!);//メニューの削除
    ref.read(ingProvider.notifier).state = Ing();
  }

  //新規登録のフローティングボタン押下時の処理=====================
  void addBotton(){
    Ing ing = Ing();
    ref.read(ingEditFlgProvider.notifier).state = false;
    ref.read(ingProvider.notifier).state = ing;
    ref.read(ingTextControllerListProvider.notifier).disposeAll();
  }

  //バリデーションチェック(入力フィールド複数行)_=================================================
  //全入力フィールドに不正がないかチェックする
  bool validation(List ingTextControllersList){
    //final ingTextControllersList = ref.read(ingTextControllerListProvider);
    String errorMessage = "";
    int count = 0;
    
    for (int i = 0; i < ingTextControllersList.length; i++){
      if (ingTextControllersList[i].priceController.text.isEmpty) {
        //errorMessage ='材料の材料名が空欄の箇所があります';
        ingTextControllersList[i].priceController.text='0';
        errorMessage = "";
      }
      if(ingTextControllersList[i].quantityController.text.isEmpty){
        //errorMessage ='材料の数量が空欄の箇所があります';
        ingTextControllersList[i].quantityController.text='0';
        errorMessage = "";
      }
      if(ingTextControllersList[i].unitController.text.isEmpty){
        //errorMessage ='材料の単位が空欄の箇所があります';
        ingTextControllersList[i].unitController.text='';
        errorMessage = "";
        //count += 1;
      }
      if (ingTextControllersList[i].nameController.text.isEmpty) {
        errorMessage ='材料の材料名が空欄の箇所があります';
        count += 1;
      }
      
      //print("count:$count");
    }
    if(errorMessage.isNotEmpty && count!=1){
        ref.read(errorMessageProvider.notifier).state = errorMessage; 
        return false;
      }
    return true;
  }
/*
   //バリデーションチェック(入力フィールド複数行)_=================================================
  //全入力フィールドに不正がないかチェックする(メニュー登録の材料のチェック)
  bool validation2(){
    final ingTextControllersList = ref.read(menuIngTextControllerListProvider);
    String errorMessage = "";
    int count = 0;
    //print("vali2:${errorMessage}");
    for (int i = 0; i < ingTextControllersList.length; i++){
      count =0;

      if(ingTextControllersList[i].priceController.text.isEmpty){
        ingTextControllersList[i].priceController.text='0';
        errorMessage = "";
      }
      if(ingTextControllersList[i].quantityController.text.isEmpty){
        ingTextControllersList[i].quantityController.text='0';
        errorMessage = "";
      }
      if (ingTextControllersList[i].nameController.text.isEmpty) {
        errorMessage ='材料の材料名が空欄の箇所があります';
        count += 1;
      }
      if(ingTextControllersList[i].unitController.text.isEmpty){
        errorMessage ='材料の単位が空欄の箇所があります';
        count += 1;
      }
      //("vali2:${errorMessage}");
    }
    if(errorMessage.isNotEmpty && count!=2){
        ref.read(errorMessageProvider.notifier).state = errorMessage; 
        return false;
      }
    return true;
  }
*/
  bool selectValidation(){
    final selectIngTextControllersList = ref.read(selectIngTextControllerListProvider);
    String errorMessage = "";
    
    for (int i = 0; i < selectIngTextControllersList.length; i++){
      if(selectIngTextControllersList[i].quantityController.text.isEmpty){
        errorMessage ='材料の項目に空欄があります';
    }}

    if(errorMessage.isNotEmpty){
        ref.read(errorMessageProvider.notifier).state = errorMessage; 
        return false;
      }
    return true;
  }



  //メニューの材料が１行で何も入力されていないときはバリデーションチェック不要なので、その状態をチェックする。
   bool validationNeed(){
    final ingTextControllersList = ref.read(ingTextControllerListProvider);

    //選択材料のテキストフィールドの入力有無チェック
    for (int i = 0; i < ingTextControllersList.length; i++){
      if(ingTextControllersList[i].nameController.text.isNotEmpty){
        return true;
      }
      if(ingTextControllersList[i].quantityController.text.isNotEmpty){
        return true;
      }
      if(ingTextControllersList[i].unitController.text.isNotEmpty){
        return true;
      }
      if(ingTextControllersList[i].priceController.text.isNotEmpty){
        return true;
      }
    }
    return false;
  }

  int ingTotalPrice() {
    final ingTextControllersList = ref.read(ingTextControllerListProvider);
    final selectIngTextControllersList = ref.read(selectIngTextControllerListProvider);
    int total = 0;

    for (final controller in ingTextControllersList) {
        final price = int.tryParse(controller.priceController.text) ?? 0;
        final quantity = int.tryParse(controller.quantityController.text) ?? 1;
        total += price*quantity;
    }
    for (final controller in selectIngTextControllersList) {
        final price = controller.unitPrice;
        final quantity = int.tryParse(controller.quantityController.text) ?? 0;
        total += (price*quantity).round();
    }

    return total;
  }


}