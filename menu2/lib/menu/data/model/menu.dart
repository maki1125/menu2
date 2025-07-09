import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:menu2/ingredient/data/model/ingredient.dart';



class Menu {

  DateTime createdAt;
  String name;
  String imageURL;
  String imagePath;
  int people;
  String tag;
  List<Ing> ings;
  String howToMake;
  String memo;
  bool isFavorite;
  bool isDinner;
  bool isPlan;
  String id;
  DateTime? dinnerDate;
  DateTime? dinnerDateBuf;
  int price;
  int unitPrice;
  String familyId;

  Menu({
    DateTime? createdAt, //メニュー作成年月日
    this.name = '',//料理名
    this.imageURL = '', //firestrageの画像のURL
    this.imagePath = '',//firestrageのフォルダパス
    this.people = 1,//何人前
    this.tag = 'カテゴリー無',//タグ
    List<Ing>? ings, //材料のリスト
    this.howToMake = '',//作り方
    this.memo = '', //メモ
    this.isFavorite = false, //お気に入り
    this.isDinner = false,//夕食
    this.isPlan = false,//予定
    this.id = '',//ドキュメントID
    this.dinnerDate,//夕食の日付
    this.dinnerDateBuf,//夕食の履歴の削除時に元に戻すため。
    this.price = 0,//値段
    this.unitPrice = 0,//1人前の値段
    this.familyId = '', //ユーザーID(u0)
  }) : createdAt = createdAt ?? DateTime.now(), // nullの場合今の時間を初期値に設定
       ings = ings ?? [];

  Menu copyWith({
    DateTime? createdAt,
    String? name,
    String? imageURL,
    String? imagePath,
    int? people,
    String? tag,
    List<Ing>? ings,
    String? howToMake,
    String? memo,
    bool? isFavorite,
    bool? isDinner,
    bool? isPlan,
    String? id,
    DateTime? dinnerDate,
    DateTime? dinnerDateBuf,
    int? price,
    int? unitPrice,
    String? familyId,
  }) {
    return Menu(
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      imageURL: imageURL ?? this.imageURL,
      imagePath: imagePath ?? this.imagePath,
      people: people ?? this.people,
      tag: tag ?? this.tag,
      ings: ings ?? List.from(this.ings), // リストはコピー
      howToMake: howToMake ?? this.howToMake,
      memo: memo ?? this.memo,
      isFavorite: isFavorite ?? this.isFavorite,
      isDinner: isDinner ?? this.isDinner,
      isPlan: isPlan ?? this.isPlan,
      id: id ?? this.id,
      dinnerDate: dinnerDate ?? this.dinnerDate,
      dinnerDateBuf: dinnerDateBuf ?? this.dinnerDateBuf,
      price: price ?? this.price,
      unitPrice: unitPrice ?? this.unitPrice,
      familyId: familyId ?? this.familyId,
    );
  }
  

  //FirestoreからのデータからMenusインスタンスを生成する.
  factory Menu.fromFirestore(Map<String, dynamic> data) {
    return Menu(
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //TimestampはDateTimeに変換
      name: data['name'] as String? ?? "",
      imageURL: data['imageURL'] as String? ?? "",
      imagePath: data['imagePath'] as String? ?? "",
      people: data['people'] as int ,//?? 1,
      tag: data['tag'] as String? ?? "カテゴリー無",
      ings: (data['ings'] as List<dynamic>?)
        ?.map((e) => Ing.fromFirestore(e as Map<String, dynamic>)) // List<dynamic>の各要素をMap<String, dynamic>に変換
        .toList() ?? [], // nullの場合は空のリストを設定
      howToMake: data['howToMake'] as String? ?? "",
      memo: data['memo'] as String? ?? "",
      isFavorite: data['isFavorite'] as bool? ?? false,
      isDinner: data['isDinner'] as bool? ?? false,
      isPlan: data['isPlan'] as bool? ?? false,
      id: data['id'] as String? ?? "",
      dinnerDate: (data['dinnerDate'] as Timestamp?)?.toDate(), //日付ない場合はnull
      dinnerDateBuf: (data['dinnerDateBuf'] as Timestamp?)?.toDate(), //日付ない場合はnull
      price: data['price'] as int? ?? 0,
      unitPrice: data['unitPrice'] as int? ?? 0,
      familyId: data['familyId'] as String? ?? '',
    );
  }

  //menu型をfirebaseで保存するためmap型に変換.
  Map<String, dynamic> toMap(){
    return{
      'createdAt': Timestamp.fromDate(createdAt),//firebaseはtimestap型で保存される。
      'name': name,
      'imageURL': imageURL,
      'imagePath': imagePath,
      'people': people,
      'tag': tag,
      'ings': ings.isEmpty
          ? []
          : ings.map((ing) => ing.toMap()).toList(),
      'howToMake': howToMake,
      'memo': memo,
      'isFavorite': isFavorite,
      'isDinner': isDinner,
      'isPlan': isPlan,
      'id': id,
      'dinnerDate': dinnerDate != null ? Timestamp.fromDate(dinnerDate!) : null,
      'dinnerDateBuf': dinnerDateBuf != null ? Timestamp.fromDate(dinnerDateBuf!) : null,
      'price': price,
      'unitPrice': unitPrice,
      'userId': familyId,
    };
  }
}

//メニューのテキストコントローラーセット
class MenuTextControllers {
  final nameController = TextEditingController();
  final peopleController = TextEditingController();
  final howToMakeController = TextEditingController();
  final memoController = TextEditingController();
  final priceController = TextEditingController();//自由入力で使用。

  MenuTextControllers();

  void init(Menu menu) {
    nameController.text = menu.name;
    peopleController.text = menu.people.toString();
    howToMakeController.text = menu.howToMake;
    memoController.text = menu.memo;
  }

  void dispose() {
    nameController.dispose();
    peopleController.dispose();
    howToMakeController.dispose();
    memoController.dispose();
    priceController.dispose();
  }

  void clear(){
    nameController.clear();
    peopleController.clear();
    howToMakeController.clear();
    memoController.clear();
    priceController.clear();
  }


}
