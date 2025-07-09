import 'package:cloud_firestore/cloud_firestore.dart';

  
class CustomMenu {

  //要素
  String id; //ドキュメントID
  DateTime date;
  List<Map<String, dynamic>> menus;//menuId,name,people,unitPrice,customFlg
  int totalPrice;
  DateTime createdAt;
  String familyId;

  //初期値
  CustomMenu({
    this.id = '',
    DateTime? date,
    this.menus = const [],
    this.totalPrice = 0,
    DateTime? createdAt,
    this.familyId = '',
  }): date = date ?? DateTime.now(),
  createdAt = createdAt ?? DateTime.now();

  //コピー
  CustomMenu copyWith({
    String? id,
    DateTime? date,
    List<Map<String, dynamic>>? menus,
    int? totalPrice,
    DateTime? createdAt,
    String? familyId,
  }) {
    return CustomMenu(
      id: id ?? this.id,
      date: date ?? this.date,
      menus: menus ?? this.menus,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      familyId: familyId ?? this.familyId,
    );
  }

  //firebaseからデータ取得
  factory CustomMenu.fromFirestore(Map<String, dynamic> data) {
    return CustomMenu(
      id: data['id'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      menus: List<Map<String, dynamic>>.from(data['menus']),
      totalPrice: data['totalPrice'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      familyId: data['familyId'] ?? '',
    );
  }
  
  //firebase保存のためcustomMenu型→map変換
  //使い方：customMenu.toMap(),
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'menus': menus,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'familyId': familyId,
    };
  }

  
}