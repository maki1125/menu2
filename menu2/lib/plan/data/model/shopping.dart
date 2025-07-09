import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//買い物データの型
class Shopping {

  //要素
  String id; //ドキュメントID
  DateTime date;//買い物をした日
  String shopName; //お店の名前
  int price;//値段
  String memo; //メモ
  DateTime createdAt;//登録日
  String familyId;//ファミリーID

  //初期値
  Shopping({
    this.id = '',
    DateTime? date,
    this.shopName='',
    this.price = 0,
    this.memo='',
    DateTime? createdAt,
    this.familyId = '',
  }): date = date ?? DateTime.now(),
  createdAt = createdAt ?? DateTime.now();

  //コピー
  Shopping copyWith({
    String? id,
    DateTime? date,
    String? shopName,
    int? price,
    String? memo,
    DateTime? createdAt,
    String? familyId,
  }) {
    return Shopping(
      id: id ?? this.id,
      date: date ?? this.date,
      shopName: shopName ?? this.shopName,
      price: price ?? this.price,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      familyId: familyId ?? this.familyId,
    );
  }

  //firebaseからデータ取得
  factory Shopping.fromFirestore(Map<String, dynamic> data) {
    return Shopping(
      id: data['id'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      shopName: data['shopName'] as String? ?? '',
      price: data['price'] ?? 0,
      memo: data['memo'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'] ?? '',
    );
  }
  
  //firebase保存のためcustomMenu型→map変換
  //使い方：customMenu.toMap(),
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'shopName': shopName,
      'price': price,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
      'familyId': familyId,
    };
  }

  
}


//メニューのテキストコントローラーセット
class ShoppingTextControllers {
  final shopNameController = TextEditingController();
  final priceController = TextEditingController();
  final memoController = TextEditingController();

  ShoppingTextControllers();

  void dispose() {
    shopNameController.dispose();
    memoController.dispose();
    priceController.dispose();
  }

  void clear(){
    shopNameController.clear();
    memoController.clear();
    priceController.clear();
  }


}