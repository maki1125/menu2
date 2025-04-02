import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:menu2/ingredient/data/model/ingredient.dart';

class Menu {

  DateTime createAt;
  String name;
  String imageURL;
  String imagePath;
  int quantity;
  String tag;
  List<Ingredient> ingredients;
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
  String userId;

  Menu({
    DateTime? createAt, //メニュー作成年月日
    this.name = '',//料理名
    this.imageURL = '', //firestrageの画像のURL
    this.imagePath = '',//firestrageのフォルダパス
    this.quantity = 1,//何人前
    this.tag = '',//タグ
    List<Ingredient>? ingredients, //材料のリスト
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
    this.userId = '', //ユーザーID(u0)
  }) : createAt = createAt ?? DateTime.now(), // nullの場合今の時間を初期値に設定
       ingredients = ingredients ?? [];
       
  Menu copyWith({
    DateTime? createAt,
    String? name,
    String? imageURL,
    String? imagePath,
    int? quantity,
    String? tag,
    List<Ingredient>? ingredients,
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
    String? userId,
  }) {
    return Menu(
      createAt: createAt ?? this.createAt,
      name: name ?? this.name,
      imageURL: imageURL ?? this.imageURL,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      tag: tag ?? this.tag,
      ingredients: ingredients ?? List.from(this.ingredients), // リストはコピー
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
      userId: userId ?? this.userId,
    );
  }
  

  //FirestoreからのデータからMenusインスタンスを生成する.
  factory Menu.fromFirestore(Map<String, dynamic> data) {
    return Menu(
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(), //TimestampはDateTimeに変換
      name: data['name'] as String? ?? "",
      imageURL: data['imageURL'] as String? ?? "",
      imagePath: data['imagePath'] as String? ?? "",
      quantity: data['quantity'] as int? ?? 1,
      tag: data['tag'] as String? ?? "",
      ingredients: (data['ingredients'] as List<dynamic>?)
        ?.map((e) => Ingredient.fromFirestore(e as Map<String, dynamic>)) // List<dynamic>の各要素をMap<String, dynamic>に変換
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
      userId: data['userId'] as String? ?? '',
    );
  }

  //menu型をfirebaseで保存するためmap型に変換.
  Map<String, dynamic> toMap(){
    return{
      'createAt': Timestamp.fromDate(createAt),//firebaseはtimestap型で保存される。
      'name': name,
      'imageURL': imageURL,
      'imagePath': imagePath,
      'quantity': quantity,
      'tag': tag,
      'ingredients': ingredients.isEmpty
          ? []
          : ingredients.map((ingredient) => ingredient.toMap()).toList(),
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
      'userId': userId,
    };
  }
}
