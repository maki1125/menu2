import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/menu/data/model/menu.dart';
//import 'package:rxdart/rxdart.dart'; //StreamZip使用のため
import 'package:async/async.dart'; //StreamZip使用のため

class MenuRepository {

  final db = FirebaseFirestore.instance;
  List<Menu> menuListBuff = []; 

  //メニューリストのリアルタイム取得
  Stream<List<Menu>> fetchMenus(String userId) {
    
    return db.collection('users/$userId/menus')
    .orderBy('createAt', descending: false)
    .snapshots()
    .map((snapshot) {

      //firebaseのデータが変更ある毎にリストを作成する。変更を感知させるためsnapshot内で定義
      List<Menu> menuList = List.from(menuListBuff); 

      // 変更された部分だけを取得
      for (final change in snapshot.docChanges) {
        print("docChange");
        final menu = Menu.fromFirestore(change.doc.data() as Map<String, dynamic>);
        
        switch (change.type) {
          //追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.added:
            print("add");
            print(menu.name);
            if ((menu.id == "" && !menuList.any((m) => ( ""== menu.id)))//データ追加された時にまだidがついていない場合がある。
              || !menuList.any((m) => (m.id == menu.id))){//すでにリストにある場合は追加しない。初回に2回addしてしまうため。
              menuList.insert(0, menu);
            }
            break;

          //修正（既存アイテムを更新）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.modified:
          print("modified");
            final index = menuList.indexWhere((m) => (m.id == menu.id || m.id == ""));
            if (index != -1) {
              menuList[index] = menu;
            }
            break;

          //削除ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.removed:
          print("removed");
            menuList.removeWhere((m) => m.id == menu.id);
            break;
        }
      }
      menuListBuff = menuList;
      return menuList;
    });   
  }

  //データ追加
  Future<void> addMenu(Menu menu) async{
    // Firestore のドキュメント ID を事前に生成
    String newId = db.collection('users/${menu.userId}/menus').doc().id;

    await db.collection('users/${menu.userId}/menus').doc(newId).set({
    ...menu.toMap(), // menu のデータを展開
    'id': newId,     // 事前に作った ID をセット
  });
  }

  //データ削除
  Future<void> deleteMenu(Menu menu) async{
    await db
    .collection('users/${menu.userId}/menus')
    .doc(menu.id)
    .delete();
  }

  //データ更新
  Future<void> updateMenu(Menu menu) async{
    await db
    .collection('users/${menu.userId}/menus')
    .doc(menu.id)
    .update(menu.toMap());
  }

}
