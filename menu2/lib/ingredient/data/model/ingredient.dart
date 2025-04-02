import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {//flutter/material.dartと名前が被るため、MaterialModelとする。
  
  DateTime createAt;
  String name;
  double quantity; //0.5玉など入力可能
  String unit;
  int price; //値段に小数点ないのでint型
  String id;
  
  Ingredient({
    DateTime? createAt,//作成日
    this.name = '',//材料名
    this.quantity = 1.0,//数量
    this.unit = '',//単位
    this.price = 0,//値段
    this.id = ''//ドキュメントID
  }): createAt = createAt ?? DateTime.now();

  //FirestoreからのデータからIngredientインスタンスを生成する
  factory Ingredient.fromFirestore(Map<String, dynamic> data) {
    return Ingredient(
      createAt:  (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //TimestampはDateTimeに変換
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as double? ?? 1.0, //0.5玉など入力可能
      unit: data['unit'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      id: data['id'] as String? ?? '',
    );
  }

  //Firestoreに保存するためにingredient型からMap型に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'createAt': createAt,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'id': id,
    };
  }
}
