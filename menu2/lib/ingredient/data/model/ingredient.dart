import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // ランダムな一意ID生成のためのパッケージ

//材料データの設定===============================================
class Ing {//flutter/material.dartと名前が被るため、Ingと命名。
  
  DateTime createdAt;
  String name;
  double quantity; //0.5玉など入力可能
  String unit;
  int price; //入力するときは値段は小数点はないのでintにする。
  String id;
  String userId;

  Ing({
    DateTime? createdAt,//作成日
    this.name = '',//材料名
    this.quantity = 1.0,//数量
    this.unit = '',//単位
    this.price = 0,//値段
    this.id = '',//ドキュメントID
    this.userId = '', //ユーザーID(u0)
  }): createdAt = createdAt ?? DateTime.now();

  Ing copyWith({
    DateTime? createdAt,
    String? name,
    double? quantity,
    String? unit,
    int? price,
    String? id,
    String? userId,
  }) {
    return Ing(
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      id: id ?? this.id,
      userId: userId ?? this.userId,
    );
  }

  //FirestoreからのデータからIngredientインスタンスを生成する
  factory Ing.fromFirestore(Map<String, dynamic> data) {
    return Ing(
      createdAt:  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //TimestampはDateTimeに変換
      name: data['name'] as String? ?? '',
      quantity: data['quantity'] as double? ?? 1.0, //0.5玉など入力可能
      unit: data['unit'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      
    );
  }

  //Firestoreに保存するためにingredient型からMap型に変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'id': id,
      'userId': userId,
    };
  }
}

//材料のテキストコントローラーセット=================================================
class IngTextControllers {
  final String id; // ← 一意なID
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController priceController;

  //ingを受け取った場合は、テキストフィールドのテキストに初期値を設定する。
  IngTextControllers({Ing? ing})//名前月引数
      : id = const Uuid().v4(), // 一意なIDを生成
      nameController = TextEditingController(text: ing?.name ?? ''),
        quantityController = TextEditingController(text: ing != null ? ing.quantity.toString() : ''),
        unitController = TextEditingController(text: ing?.unit ?? ''),
        priceController = TextEditingController(text: ing != null ? ing.price.toString() : '');
  
  void allDispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    priceController.dispose();
  }
}

//材料一覧から選択の材料コントローラセット=================================================
class SelectIngTextControllers {
  //final Ing ing;
  final String id; // ← 一意なID
  final String name; // 材料名
  final TextEditingController quantityController;// 単位 0.5玉など入力できるようにdouble
  final String unit;   
  final double unitPrice;   // 単価 0.7円など入力できるようにdouble
  double subtotal; 

  SelectIngTextControllers({required Ing ing})
   : //required Ing ing, 
   id = const Uuid().v4(), // 一意なIDを生成
    name = ing.name,
    quantityController = TextEditingController(text: "1"),
    unit = ing.unit,
    unitPrice = (ing.quantity != 0) ? ing.price / ing.quantity : 0,
    subtotal = (ing.quantity != 0) ? ing.price / ing.quantity : 0;//double.parse((ing.price/ing.quantity).toStringAsFixed(1));


  void dispose() {
    quantityController.dispose();
  }
}