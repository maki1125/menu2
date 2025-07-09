import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //Fileを扱うため
import 'package:firebase_storage/firebase_storage.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
//import 'package:http/http.dart' as http;

import 'package:menu2/menu/data/model/menu.dart';


class ImageRepository {
  final Ref ref;
  ImageRepository(this.ref);

  //画像の保存================================================
  Future<void> addImage() async{
    try{
      //print("addImage");
    final File? file = await ref.read(selectedImageProvider);  // Riverpodで値取得
    final menu = ref.read(menuProvider);
    final familyId = ref.read(familyIdProvider);
    if(file != null){
      //print("ファイル存在");
      final int timestamp = DateTime.now().microsecondsSinceEpoch; //735496096789000
      final String name = file.uri.pathSegments.last; //file.path.split('/').last;
      final String filename = '${timestamp}_$name';
      //print('file: ${file.path}');
      //print('name: $name');
      //print('familyId: $familyId'); // これが null や空でないか確認
      final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child('families/$familyId/images')
        .child(filename)
        .putFile(file);
      //print("get開始");
      final String imageURL = await task.ref.getDownloadURL();
      //print("get終了");
      final String imagePath = task.ref.fullPath;// 画像削除時に使用。users/AC3iWb7RnqM4gCmeLOD9/images/1735480514815890_IMG_0111.jpeg
      menu!.imageURL = imageURL;
      menu.imagePath = imagePath;
      ref.read(menuProvider.notifier).state = menu;
      //print(":imageURL:$imageURL");
      file.delete(); //一時ファイルに保存したデータを削除する。
    }else{
      //print("ファイル存在しません");
    }
    ref.read(selectedImageProvider.notifier).state = null; //次の編集の時に表示されないように、nullにしておく。
    }catch(e){
      //print("画像追加で例外発生");
      //print("画像追加で例外発生: $e");
      //print("スタック: $stack");
    }
  }



  //画像削除===================================================
  Future<void> deleteImage() async{
    try{
      //print("deleteImage");
    final menu = ref.read(menuProvider);
    //print("deleteMenu:${menu}");
    if(menu!.imagePath != ""){
     //print("imagePath:${menu!.imagePath}");
     await FirebaseStorage.instance
      .ref(menu.imagePath)
      .delete();
    menu.imagePath = "";
    ref.read(menuProvider.notifier).state = menu;
    
    //print("画像を削除しました。");
    }
    }catch(_){
      //print("画像削除で例外発生");
      //エラー出たらスルー
    }
  }

    //画像URLの再取得。tokenでURLに期限あるため。
  Future<Menu> fetchImageUrl(Menu menu) async{
    try{
    //print("再取得開始");
    final ref = FirebaseStorage.instance.ref(menu.imagePath);
    final url = await ref.getDownloadURL();
    menu.imageURL = url;
    //print("再取得終了");
    
    return menu;
    }catch(_){
      //print("例外発生しました。");
      return menu;
    }
  }



}