import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/menu/data/model/menu.dart';


//Firestoreのデータ処理============================================================
/*使い方--------------------------------------------
final menuRepositoryProvider = Provider((ref) {
  return FirestoreRepository<Menu>(
    ref: ref,
    collectionName: "menus",
    fromFirestore: (data) => Menu.fromFirestore(data),
    toFirestore: (menu) => menu.toMap(),
  );
});
-----------------------------------------------------*/
class FirestoreRepository<T> {
  final Ref ref;
  final String collectionName;
  final T Function(Map<String, dynamic> data) fromFirestore;
  final Map<String, dynamic> Function(T) toFirestore;
  final db = FirebaseFirestore.instance;
  List<T> dataListBuff = [];

  FirestoreRepository({
    required this.ref,
    required this.collectionName,
    required this.fromFirestore,
    required this.toFirestore,
  });

  //データリストのリアルタイム取得***************************************
  Stream<List<T>> fetchData() {
    final familyId = ref.read(familyIdProvider);
    
    return db.collection("families/$familyId/$collectionName")
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      
      //firebaseのデータが変更ある毎にリストを作成する。変更を感知させるためsnapshot内で定義
      List<T> dataList = List.from(dataListBuff);

       // 変更された部分だけを取得
      for (final change in snapshot.docChanges) {
        final data = fromFirestore(change.doc.data() as Map<String, dynamic>);

        switch (change.type) {
          //追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.added:
          //print("add");
            //if (!dataList.contains(data)) {
               if (((data as dynamic).id == "" && !dataList.any((d) => ( ""== (data as dynamic).id)))//データ追加された時にまだidがついていない場合がある。
              || !dataList.any((d) => ((d as dynamic).id == (data as dynamic).id))){//すでにリストにある場合は追加しない。初回に2回addしてしまうため。
              dataList.insert(0, data);
            }
            break;

          //修正（既存アイテムを更新）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.modified:
          //print("modi");
            final index = dataList.indexWhere((d) {
              // モデルによってidの持ち方違うなら工夫必要
              final id1 = (d as dynamic).id;
              final id2 = (data as dynamic).id;
              return id1 == id2;
            });
            if (index != -1) {
              dataList[index] = data;
            }
            break;

          //削除ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          case DocumentChangeType.removed:
          //print("removed");
            dataList.removeWhere((d) => (d as dynamic).id == (data as dynamic).id);
            break;
        }
      }
      dataListBuff = dataList;
      return dataList;
    });
  }

  //データ追加***************************************
  Future<void> addData(T data) async {
    final familyId = ref.read(familyIdProvider);
    String newId = db.collection('families/$familyId/$collectionName').doc().id;
    await db.collection('families/$familyId/$collectionName').doc(newId).set({
      ...toFirestore(data),
      'id': newId,
    });

    //メニュー新規追加後、編集するときにid必要のため。一覧からの編集であればid取得できるが、新規登録からの編集は登録時にidをローカルにも更新する必要あり。
    if(collectionName=='menus'){
      (data as dynamic).id = newId;
      ref.read(menuProvider.notifier).state = (data as Menu);
    }
  }

  //データ削除=***************************************
  Future<void> deleteData(T data) async {
    final familyId = ref.read(familyIdProvider);

    await db
        .collection('families/$familyId/$collectionName')
        .doc((data as dynamic).id)
        .delete();
  }

  //データ更新***************************************
  Future<void> updateData(T data) async {
    final familyId = ref.read(familyIdProvider);
    //print("path:${'families/$familyId/$collectionName'}_${(data as dynamic).id}");

    await db
        .collection('families/$familyId/$collectionName')
        .doc((data as dynamic).id)
        .update(toFirestore(data));
    //print("データアップデートしました。${data.id},${data.imageURL}");
  }





}