import 'package:cloud_firestore/cloud_firestore.dart';

  
class Dinner {

  String id;
  DateTime date;
  List<Map<String, dynamic>> menus;//menuId,name,customFlg
  int totalPrice;
  DateTime createdAt;
  String familyId;

  Dinner({
    this.id = '',//ドキュメントID
    DateTime? date,
    this.menus = const [],
    this.totalPrice = 0,
    DateTime? createdAt,
    this.familyId = '',
  }): date = date ?? DateTime.now(),
  createdAt = createdAt ?? DateTime.now();

  Dinner copyWith({
    String? id,
    DateTime? date,
    List<Map<String, dynamic>>? menus,
    int? totalPrice,
    DateTime? createdAt,
    String? familyId,
  }) {
    return Dinner(
      id: id ?? this.id,
      date: date ?? this.date,
     menus: menus ?? this.menus,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      familyId: familyId ?? this.familyId,
    );
  }

  factory Dinner.fromFirestore(Map<String, dynamic> data) {
    return Dinner(
      id: data['id'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(), // 安全にnullチェック
      menus: (data['menus'] as List<dynamic>?)
    ?.map((menu) => Map<String, dynamic>.from(menu as Map))
    .toList() ?? [],
      totalPrice: data['totalPrice'] as int? ?? 0, // intにキャストしておくと安心
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      familyId: data['familyId'] ?? '',
    );
  }


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