import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/menu/view_model/menu_view_model.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_widget.dart';

class MenuList extends ConsumerStatefulWidget{
  @override
  ConsumerState<MenuList> createState() => MenuListState();
}

class  MenuListState extends ConsumerState<MenuList> with SingleTickerProviderStateMixin{//アニメーション制御Tickerに必要。vsynsが使用できる。タブコントローラで使用。

  late TabController _tabController;//メニュー一覧の上部タブに使用

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    // Riverpodの状態と同期させる
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(tabIndexProvider.notifier).state = _tabController.index;
        
        //検索ボックスのテキストクリア
        final searchTextController = ref.read(searchTextControllerProvider);
        searchTextController.clear();
        ref.read(searchTextProvider.notifier).state = '';

        //ソートクリア
        ref.read(sortAiuFlgProvider.notifier).state = false;
        ref.read(sortDayFlgProvider.notifier).state = false;

      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dispMenus = ref.watch(dispMenusProvider);
    //print("dispMenus:${dispMenus.length}");
    /*
    Ingredient ing = Ingredient();
    ing.name = 'ing0';
    Ingredient ing2 = Ingredient();
    ing2.name = 'ing1';
    Menu menu = Menu();
    FirebaseFirestore.instance
    .collection('menus/u0')
    .add(menu.toMap());
    */

    
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true, // タブをスクロール可能にする
          tabs: tabs
                  .map((tag) => Tab(text: tag))
                  .toList(),
                  
          labelColor: Colors.black, // 選択中のタブの文字の色
                    unselectedLabelColor: Colors.grey, // 選択されていないタブの文字の色
        ),

        //検索ボックス
        SearchBox("料理名"),

     Expanded(
      child: SingleChildScrollView(
      child:dispMenus.isEmpty
      //データがない場合
      ? const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,//中央よせ
            children: [
            Text('データがありません',)
            ],
          )
        )
        //材料カード
    : ListView.builder(
      shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
                        physics: const NeverScrollableScrollPhysics(), // スクロール禁止
        itemCount: dispMenus.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 1, //影の深さ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                onTap: () {
                  ref.read(menuProvider.notifier).setMenu(dispMenus[index]);
                  ref.read(pageIndexProvider.notifier).state = 3;
                },
                child: Padding( //カード内の左側に隙間を設ける
                      padding: const EdgeInsets.only(left: 10.0),
                      child:Row(
                        children: [
                          //テキストエリア===========================================================
                          Expanded(
                            flex: 3,//テキスト領域の比率
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                              children: [
                                //１列目（料理名とアイコン2つの表示）------------------------------------------
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    //料理名-----------------------------------------------
                                    Text(
                                      dispMenus[index].name,
                                      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),

                                    //アイコン2つ-----------------------------------------
                                    Row(
                                      children: [
                                        //編集アイコンーーーーーーーーーーーーーーーーーーーーーーー
                                                    InkWell(
                                                      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                                        child: Icon(
                                                          Icons.edit,
                                                          size: 23,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                         ref.read(menuProvider.notifier).setMenu(dispMenus[index]);
                                                        ref.read(pageIndexProvider.notifier).state = 4;
                                                        }
                                                      
                                                    ),

                                          //削除アイコンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                                    InkWell(
                                                      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 23,
                                                        ),
                                                      ),
                                                      onTap: () async{ 
                                                        final bool? result = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => const ConfirmDialog(
                                                              message: 'このメニューを削除しますか？',
                                                            ),
                                                          );

                                                          if (result == true) {
                                                            ref.read(menuProvider.notifier).setMenu(dispMenus[index]);
                                                            ref.read(menuProvider.notifier).deleteMenu();
                                                            ref.read(pageIndexProvider.notifier).state = 0;
                                                          }
                                                        
                                                      },
                                                    ),

                                              //お気に入りアイコン-------------------------------
                                                    IconButton(
                                                onPressed: () {
                                                  dispMenus[index].isFavorite = !(dispMenus[index].isFavorite);
                                                  print("お気に入り押しました");
                                                  ref.read(menuProvider.notifier).updateMenu(dispMenus[index]);
                                                },
                                                icon: const Icon(Icons.favorite),
                                                color: dispMenus[index].isFavorite
                                                ? Colors.pink
                                                : Colors.grey,
                                                iconSize: 25,
                                              )


                                      ]
                                    )
                                  ]
                                ),


                                //4列目(夕食・予定ボタンと値段）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [

                                                    //「夕食」ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                                    ElevatedButton(//枠線ありボタン
                                                      onPressed: () { 
                                                        dispMenus[index].isDinner = !(dispMenus[index].isDinner);
                                                  ref.read(menuProvider.notifier).updateMenu(dispMenus[index]);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        elevation: dispMenus[index].isDinner! ? 0 : 3,//影の深さ
                                                        //padding: EdgeInsets.zero, // 完全にパディングを削除
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                                        minimumSize: const Size(60, 25), // 最小サイズを指定
                                                        backgroundColor: dispMenus[index].isDinner! 
                                                          ? const Color.fromARGB(255, 157, 210, 244) 
                                                          : const Color.fromARGB(255, 228, 228, 228),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        '夕食',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black
                                                        ),
                                                      ),  
                                                    ),
                                                    const SizedBox(width: 10,),

                                                    //「予定」ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                                    ElevatedButton(//枠線ありボタン
                                                      onPressed: () { 
                                                        dispMenus[index].isPlan = !(dispMenus[index].isPlan);
                                                  ref.read(menuProvider.notifier).updateMenu(dispMenus[index]);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        elevation: dispMenus[index].isPlan! ? 0 : 3,//影の深さ
                                                        //padding: EdgeInsets.zero, // 完全にパディングを削除
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                                        minimumSize: const Size(60, 25), // 最小サイズを指定
                                                        backgroundColor: dispMenus[index].isPlan! 
                                                          ? const Color.fromARGB(255, 244, 157, 240)
                                                          : const Color.fromARGB(255, 228, 228, 228),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        '予定',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black
                                                        ),
                                                      ),  
                                                    ),
                                                  ],
                                                ),
                                              ]
                                            ),






                              ]
                            )
                          ),

                          //画像エリア=============================================================
                          Expanded(
                            flex: 1,//画像領域の比率
                            child: Stack(//お気に入りアイコンのためにstack使用
                              children: [

                                //画像------------------------------------------------           
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child:SizedBox(
                                                width: 115,  // 必要に応じてサイズを設定
                                                height: 115, 
                                                child:dispMenus[index].imageURL.toString() != ''
                                      
                                                ? CachedNetworkImage(//画像がある場合
                                                  imageUrl: dispMenus[index].imageURL.toString(), // ネットワーク画像のURL
                                                  placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                                    scale: 0.3, // 縮小率を指定
                                                    child: const CircularProgressIndicator(strokeWidth: 15.0),
                                                  ),
                                                  
                                                  errorWidget: (context, url, error) => const Icon(Icons.error), // エラーの場合に表示するウィジェット
                                                  fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                                )

                                                :Image.asset( //画像ない場合
                                                  'images/no_image.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            ),


                              ]
                            )
                          )
                        ]
                      )
                )
            )
          );
        },
      )
     )
     )
       ],
    );
    
  }
}