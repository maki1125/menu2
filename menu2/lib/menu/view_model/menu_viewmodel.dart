import 'dart:io'; //Fileを扱うため
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; //画像のリサイズ
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_repository.dart';
import 'package:menu2/common/common_utils.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/menu/data/repository/image_repository.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';




//タグ名からタブバーのindexに変換する関数。タグを表示する順番を変更できるように。
int tagToIndex(String tag){
  return tagToTabindex[tag] ?? 0;
}

//各種処理
class MenuViewModel {
  final Ref ref;
  final String menuPatarn; //menu or customMenu
  //final MenuRepository menuRepo;
  final FirestoreRepository menuRepo;
  final ImageRepository imageRepo;
  //final userId;

  MenuViewModel(this.ref, this.menuPatarn)
  : menuRepo = (menuPatarn == 'menu') //menuとcustomMenuを共通にするため。
      ? ref.read(menuRepositoryProvider)

      : ref.read(customMenuRepositoryProvider),
     // : ref.read(customMenuRepositoryProvider)
    imageRepo = ref.read(imageRepositoryProvider){

  //print('menuPatarn: $menuPatarn');
  //print('選ばれたcollectionName: ${menuRepo.collectionName}');
}


  //メニューの新規登録=========================================
  Future<bool> newMenu() async {
    final dispMenus = ref.read(dispMenusProvider);
    bool limitCheckResult = limitCheck(ref, dispMenus);

    ref.read(loadingFlgProvider.notifier).state = true;

    //匿名ログインの場合は保存に制限あり
    if(!limitCheckResult){
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }

    //入力フィールドのバリデーションチェックして保存する
    final result = textControllerToMenu(); //テキストフィールドの内容からmenuProviderを更新。
    if(result){
      await imageRepo.addImage(); //画像の保存。imageURL,imagePathを更新してからmenuを読み込むためにawaitする。
      final menu = ref.read(menuProvider);//画像保存の時にimageURL,imagePath更新のためこのタイミングで読み込む
      
      //メニューの新規保存
      menuRepo.addData(menu);
      //print("メニューをaddしました。");
      //print("${menu!.name},${menu.price}");
      //print('');
      
      ref.read(menuTextControllersProvider).clear();
      return true;
    }else{
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }
  }
  
  //メニュー更新==============================================
  Future<bool> updateMenu() async {
    ref.read(loadingFlgProvider.notifier).state = true;
    final result =  textControllerToMenu();
    
    if(result){
      Menu? menu = ref.read(menuProvider);
      await imageRepo.deleteImage();
      await imageRepo.addImage();
      menu = ref.read(menuProvider)!;
      menuRepo.updateData(menu);
      ref.read(menuTextControllersProvider).clear();
      //print("update");
      ref.read(menuProvider.notifier).state = menu.copyWith();
      ref.read(loadingFlgProvider.notifier).state = false;
      
      //画像再取得履歴のクリア
      final fetchImageUrlBuff = ref.read(fetchImageUrlBuffProvider);
      fetchImageUrlBuff.removeWhere((id) => id == menu!.id);
      ref.read(fetchImageUrlBuffProvider.notifier).state = fetchImageUrlBuff;

      return true;
    }else{
      ref.read(loadingFlgProvider.notifier).state = false;
      return false;
    }
  }

  //テキストフィールの内容からmenuProvider更新。バリデーションチェックも実施。
  bool textControllerToMenu(){
    
    Menu? menu = ref.read(menuProvider);
    final textControllers = ref.read(menuTextControllersProvider);

    //料理名がないときはデータ保存しない。
    if (textControllers.nameController.text.isEmpty) {
      ref.read(errorMessageProvider.notifier).state = '料理名を入力してください';
      return false;
    }
    menu!.name = textControllers.nameController.text;//trim() は 文字列の前後の空白（スペースや改行など）を削除 する

    //材料の処理
    final ingViewmodel = ref.read(ingViewModelProvider);
    final ingTextControllersList = ref.read(menuIngTextControllerListProvider);
    final selectIngTextControllersList = ref.read(selectIngTextControllerListProvider);
    List<Ing> ings = [];
    //全てのテキストフィールドのバリデーションチェック
    //if(ingViewmodel.validationNeed()){//どこかのテキストフィールドに入力があった場合は、バリデーションチェックを行う。
    final result = ingViewmodel.validation(ingTextControllersList);
    final result2 = ingViewmodel.selectValidation();
    //print("ingvali:${result},${result2}");
    if(menuPatarn=='menu' && (!result || !result2)){
      return false;
    }
    
    //空白１行の時には材料の登録はしない。
    if(!(ingTextControllersList.length==1 && ingTextControllersList[0].nameController.text.isEmpty)){
      for (int i = 0; i < ingTextControllersList.length; i++){
      //テキストフィールドの内容からingProviderを更新。
      ingViewmodel.textControllerToIng(ingTextControllersList[i]); 
      //メニューの新規保存
      final ing = ref.read(ingProvider);
      //print("ing$i:${ing.name}");
      ings.add(ing.copyWith());//別のインスタンスにするためcopyWithを使用
    }
    }
    
    for (int i = 0; i < selectIngTextControllersList.length; i++){
      //テキストフィールドの内容からingProviderを更新。
      ingViewmodel.selectTextControllerToIng(i); 
      //メニューの新規保存
      final ing = ref.read(ingProvider);
      //print("ing$i:${ing.name}");
      ings.add(ing.copyWith());//別のインスタンスにするためcopyWithを使用
    }
    //}
    menu.ings = ings;
    if(menuPatarn=="menu"){
      //print("menuPatarn:menu");
      menu.price = ref.read(ingTotalPriceProvider).round();
    }else{
      //print("menuPatarn:customMenu:${textControllers.priceController.text}");
      menu.price = double.tryParse(textControllers.priceController.text)?.round() ?? 0;
    }
    

    menu.people = int.tryParse(textControllers.peopleController.text) ?? 1;
    menu.tag = ref.read(tagProvider) ?? '';
    menu.howToMake = textControllers.howToMakeController.text;
    menu.memo = textControllers.memoController.text;

    ref.read(menuProvider.notifier).state = menu;

    //textControllers.nameController.clear();
  
    return true;
  }

  //メニュー削除==================================================
  Future<void> deleteMenu(menu) async {
    //print("deleteMenu:${menu.name}");
    if(menu.imagePath.isNotEmpty){
      await imageRepo.deleteImage();//画像の削除
    }
    //await menuRepo.deleteMenu(menu!);//メニューの削除
    await menuRepo.deleteData(menu!);//メニューの削除

    //画像再取得履歴のクリア
    final fetchImageUrlBuff = ref.read(fetchImageUrlBuffProvider);
    fetchImageUrlBuff.removeWhere((id) => id == menu!.id);
    ref.read(fetchImageUrlBuffProvider.notifier).state = fetchImageUrlBuff;
    //print("menu削除");
    //print(fetchImageUrlBuff);

    ref.read(menuProvider.notifier).state = null;
  }

  //アイコン押下時にメニュー更新=======================================
  Future<void> iconProcess(Menu menu) async {
    //menuRepo.updateMenu(menu);
    menuRepo.updateData(menu);
  }

 

  //新規登録ページへの遷移ボタン押下時の処理_=====================
  void addBotton(){
    Menu menu = Menu(familyId: ref.read(familyIdProvider)!);
    ref.read(menuProvider.notifier).state = menu;
    ref.read(tagProvider.notifier).state = "カテゴリー無";
    ref.read(editFlgProvider.notifier).state = false;
    ref.read(loadingFlgProvider.notifier).state = false;
    ref.read(menuTextControllersProvider).clear(); 
    ref.read(menuIngTextControllerListProvider.notifier).disposeAll();
    ref.read(selectIngTextControllerListProvider.notifier).disposeAll();
    ref.read(selectedImageProvider.notifier).state = null;

    //検索ボックスのテキストクリア
    final searchTextController = ref.read(searchTextControllerProvider);
    searchTextController.clear();
    ref.read(searchTextProvider.notifier).state = '';
    //ref.read(sear)
    
  }

   //編集ボタン
   void editBotton(Menu menu){

    //材料テキストフィールドの処理（初期値の設定、クリア）
    if (menu.ings.isNotEmpty) {
      ref.read(menuIngTextControllerListProvider.notifier).initializeFromMenu(menu.ings);
    }else{
      ref.read(menuIngTextControllerListProvider.notifier).disposeAll();
    }

    //編集ページの表示のための設定（テキストフィールドの初期値設定など）
    ref.read(menuTextControllersProvider).init(menu);
    ref.read(tagProvider.notifier).state = menu.tag;
    ref.read(editFlgProvider.notifier).state = true;
    ref.read(loadingFlgProvider.notifier).state = false;
    ref.read(menuProvider.notifier).state = menu;
    ref.read(selectIngTextControllerListProvider.notifier).disposeAll();
    ref.read(selectedImageProvider.notifier).state = null;

   }
  

  //画像選択の処理============================================
  Future<void> selectImage() async{
    final XFile? result = await ImagePicker().pickImage(
      source: ImageSource.gallery, // ギャラリーから画像を選択
    );

    if(result != null){
      ref.read(selectImageFlgProvider.notifier).state=true;
      //await Future.delayed(const Duration(milliseconds: 50)); //widget反映のためにちょっとだけまつ
      //print("selectFlg:${ref.read(selectImageFlgProvider)}");
      final File file = File(result.path); //選択したファイルパスの取得.'/Users/maki/Library/Developer/CoreSimulator/Devices/D3DA9B85-B1E2-44EB-BB5C-C04B9B3328A0/data/Containers/Data/Application/CBC9AFE6-6064-4375-AB03-12608EDF94D4/tmp/IMG_0111.jpeg'
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      final resizedImage = img.copyResize(originalImage!,height: 400);//高さ基準でリサイズ。画像が切れる可能性あり。
      final resizedBytes = img.encodeJpg(resizedImage);
      final timestamp = DateTime.now().millisecondsSinceEpoch; // 現在時刻（ミリ秒）735496096789000
      final resizedFile = File('${Directory.systemTemp.path}/${timestamp}_resized_image.jpg'); //一時ファイルに保存。アプリ終了後は消える。
      //print("resizedFileを準備しました。${file.parent.path}");
      await resizedFile.writeAsBytes(resizedBytes);//ファイルにバイナリデータを書き込む
      //print("データ保存しました。");
      //ref.read(selectedImageProvider.notifier).state = null;//resizedFile;//resizedFile;//file;  // Riverpodで状態管理
      ref.read(selectedImageProvider.notifier).state = resizedFile;
      //print("選択画像：${ref.read(selectedImageProvider)!.path}");
     
      ref.read(selectImageFlgProvider.notifier).state = false;
      //file!.delete(); //一時ファイルに保存したデータを削除する。
      //print("resizedFile:${resizedFile}");
      
    }
  }

  Future<void> launchLineAppWithMessage(String message) async {
  final encodedMessage = Uri.encodeComponent(message);
  final url = 'https://line.me/R/msg/text/?$encodedMessage';

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'LINEアプリを起動できません';
  }
}

  //トークン切れた画像のURL再取得し、データ更新
  Future<bool> fetchImageUrl(Menu menu) async{
    try{
       final fetchImageUrlBuff = ref.read(fetchImageUrlBuffProvider); 
      fetchImageUrlBuff.add(menu.imageURL);
      Menu updateMenu = await imageRepo.fetchImageUrl(menu);
      final response = await http.head(Uri.parse(updateMenu.imageURL));
      //print("${response.statusCode}");
      if(response.statusCode==200){//画像がある場合。
      
        menuRepo.updateData(updateMenu);
        fetchImageUrlBuff.removeWhere((n) => n == menu.imageURL);
        ref.read(fetchImageUrlBuffProvider.notifier).state = fetchImageUrlBuff;

      return true;
    }else{
      return false;
    }
    }catch(_){
      return false;
    }
  }



}