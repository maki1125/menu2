import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/menu/data/model/menu.dart';
//import 'package:rxdart/rxdart.dart'; //StreamZip使用のため
import 'package:async/async.dart'; //StreamZip使用のため

class UserRepository {

  //使用するuserIdの取得
  Future<String?> fetchUserId(String uid) async {
  
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('linkUsers') // 🔹 コレクション名
        .doc(uid) // 🔹 取得したいドキュメントID
        .get(); // 🔹 データを1回取得

    if (doc.exists) {
      return doc.get('userId'); // 🔹 userId フィールドを取得
    } else {
      print("データが存在しません");
      return null;
    }

  }

}