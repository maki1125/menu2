/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/data/repository/image_repository.dart';
import 'package:menu2/menu/view_model/menu_viewmodel.dart';
import 'package:menu2/menu/data/repository/menu_repository.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';

class MenuRepository {

  final Ref ref;
  final String collectionName; //menuとcustomMenuで共通で使えるようにするために。
  final db = FirebaseFirestore.instance;

  MenuRepository(this.ref, this.collectionName);

  List<Menu> menuListBuff = []; 

  //メニューリストのリアルタイム取得
  Stream<List<Menu>> fetchMenus() {
    final familyId = ref.read(familyIdProvider);
     print('familyId:$familyId');

    return db.collection('families/$familyId/$collectionName')
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
     final familyId = ref.read(familyIdProvider);

    // Firestore のドキュメント ID を事前に生成
    String newId = db.collection('families/$familyId/$collectionName').doc().id;

    await db.collection('families/$familyId/$collectionName').doc(newId).set({
    ...menu.toMap(), // menu のデータを展開
    'id': newId,     // 事前に作った ID をセット
  });
  }

  //データ削除
  Future<void> deleteMenu(Menu menu) async{
     final familyId = ref.read(familyIdProvider);
    await db
    .collection('families/$familyId/$collectionName')
    .doc(menu.id)
    .delete();
  }

  //データ更新
  Future<void> updateMenu(Menu menu) async{
     final familyId = ref.read(familyIdProvider);
    await db
    .collection('families/$familyId/$collectionName')
    .doc(menu.id)
    .update(menu.toMap());
  }

}
*/
