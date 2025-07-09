import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ

import 'package:menu2/menu/view/menu_common_widget.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/common/common_widget.dart';

//メニュー詳細画面_======================================================
class MenuDetailView extends ConsumerStatefulWidget{
  const MenuDetailView({super.key});

  @override
  ConsumerState<MenuDetailView> createState() => MenuDetailViewState();
}

class  MenuDetailViewState extends ConsumerState<MenuDetailView>{

  @override
  Widget build(BuildContext context) {
    final menu = ref.watch(menuProvider); //お気に入りボタンをリアルタイムに変更させるため

    //メニュー削除した時に元ページに戻るが、このページがまだ破棄されてなくてmenuを使用するところでnullエラーが出るため。
    if (menu == null) {
      return const Scaffold(
        body: Center(child: Text('このメニューは存在しません')),
      );
    }

    return Scaffold(
      appBar:AppBar(title: const Text("メニュー詳細")),
      body:SingleChildScrollView(//スクロール可能とする
      child: Center(//全体を左右に中央揃えで、要素を縦に配置
        child: Column(
          children: [

            //「料理名・アイコン」と「画像」の横並び
            Row(
              children: [

                //料理名・アイコン
                Expanded(//が料理名＋アイコンと画像のエリアを分けるためにexpanded使用。
                  flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // 上に寄せる
                      crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                        children: [
                          
                          //アイコンを横並び
                          Row(
                            children: [

                              //お気に入りボタン_================================
                              
                              const SizedBox(width: 5,),
                              MenuFavoriteIcon(menu),
                              const SizedBox(width: 10,),
                              
                               //削除アイコン_==================================
                              MenuDeleteIcon(menu,
                                onDeleted: () {
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }}),
                              const SizedBox(width: 10,),

                              //編集アイコン_===================================
                              MenuEditIcon(menu, true),
                              const SizedBox(width: 10,),

                              //カテゴリ_=======================================
                              Text(menu.tag==""
                                ? "カテゴリー無"
                                :menu.tag
                              ),


                            ]),

                            //料理名_==========================================
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                menu.name,
                                overflow: TextOverflow.ellipsis, // 溢れた場合は "..." で省略
                                maxLines: 2, // 最大2行まで表示
                                style: const TextStyle(
                                  //color: Colors.red,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                                ),
                                //textAlign: TextAlign.center,
                            )),
                            const SizedBox(height: 60,),


                ])),

                //画像_=========================================================
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),// 8ピクセルの余白
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // 背景色
                        border: Border.all(color: Colors.grey), // 枠線
                        borderRadius: BorderRadius.circular(10), // 角丸
                      ),
                      child: menu.imageURL == ""
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                      child:
                      Image.asset( //画像ない場合
                          'images/no_image.jpg',
                          //height: 120,
                          //width: 120,
                          fit: BoxFit.cover,
                        )
                      )
                      :ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                      child: 
                      CachedNetworkImage(
                        imageUrl: menu.imageURL.toString(), // ネットワーク画像のURL
                        placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                          scale: 0.3, // 縮小率を指定
                          child: const CircularProgressIndicator(strokeWidth: 20.0),
                        ),
                        errorWidget: (context, url, error) {
                          return const Center(child:Text("!再度画像登録してください"));//const Icon(Icons.error);
                        }, // エラーの場合に表示するウィジェット
                        fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                        ))))),


            ]),

            //材料の題名_=========================================================
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                titleText(title: '  材料   '),
                Row(
                  children: [
                    Text(menu.people.toString()),
                    const Text("人前"),
                  ]),
                const SizedBox(height: 10,),
              ]),
            const SizedBox(height: 10,),

            //材料表示のエリア
            Column(                  
              children: 
                List.generate(menu.ings.length, (index){//index取得のためList.generate使用。mapではindex取得できないため。
                  final ing = menu.ings[index];
                  //print("ingQuantity:${}")
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 0.0), // すべての辺に16のスペース
                    child: Column(
                      children: [
                        //材料１行分_===================================================
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
                          children: [
                            SizedBox(
                              width: 170,
                              child:Text(ing.name,
                              //textAlign: TextAlign.center, // テキストを中央揃え),
                              )
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                //数量が0の場合
                                ing.quantity.toStringAsFixed(0)=='0'
                                ? ing.unit
                                //整数の時
                                : ing.quantity.toString()[ing.quantity.toString().length-1]=="0"
                              ?ing.quantity.toStringAsFixed(0)+ing.unit//整数表示
                              :ing.quantity.toString()+ing.unit,//小数表示
                              
                              
                              textAlign: TextAlign.right
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text("${ing.price.toString()} 円",
                              textAlign: TextAlign.right
                              ),
                            ),


                          ]),

                        //仕切り線_===========================================================
                        SizedBox(//完全にパディングをなくした横線
                          height: 0.5, // Divider の厚みに合わせる
                          child: Container(
                            color: Colors.grey, // Divider の色に合わせる
                            //margin: EdgeInsets.only(left: 20, right: 20), // indent と endIndent を再現
                          ),
                        ),
                        const SizedBox(height: 2,),
                      ]));
            })),
            const SizedBox(height: 10,),

            //合計_=========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("合計：${menu.price.toString()}円",),
                const SizedBox(width: 28,),
            ]),

            //作り方_========================================================
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                titleText(title: '  作り方   '),
            ]),
            const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // 👈 左右に20の余白
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      menu.howToMake,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),

            //メモ_===========================================================
            Row(//Rowで囲まないと材料が左揃えにならないため。
              children: [
                titleText(title: '  メモ   '),
              ]),
            const SizedBox(height: 5,),
           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // 👈 左右に20の余白
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      menu.memo,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),

            //戻るボタン_=======================================================
            returnButtton(context),
        

      ])))
    //bottomNavigationBar: const CustomBottomBar(),

    );
}}