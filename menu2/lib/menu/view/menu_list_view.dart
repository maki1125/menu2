//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ
import 'package:intl/intl.dart';//日付のフォーマット
//import 'package:flutter_cache_manager/flutter_cache_manager.dart'; //画像キャッシュのクリアのため

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:menu2/menu/view/menu_create_view.dart';
import 'package:menu2/menu/view/menu_detail_view.dart';
import 'package:menu2/menu/view/menu_common_widget.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';
import 'package:menu2/plan/view/dinner_list_view.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';




class MenuList extends ConsumerStatefulWidget{
  const MenuList({super.key});
  @override
  ConsumerState<MenuList> createState() => MenuListState();
}

class  MenuListState extends ConsumerState<MenuList> with SingleTickerProviderStateMixin{//アニメーション制御Tickerに必要。vsynsが使用できる。タブコントローラで使用。
  late TabController _tabController;//メニュー一覧の上部タブに使用
  
  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(menuToptabIndexProvider);
    
    //ref.read(searchTextControllerProvider).text.;//検索単語のクリア
    _tabController = TabController(length: tabs.length, vsync: this,initialIndex: initialIndex,);
    // Riverpodの状態と同期させる
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(menuToptabIndexProvider.notifier).state = _tabController.index;
        
        //検索ボックスのテキストクリア
        final searchTextController = ref.read(searchTextControllerProvider);
        searchTextController.clear();
        ref.read(searchTextProvider.notifier).state = '';

        //ソートクリア
        ref.read(sortAiuFlgProvider.notifier).state = false;
        ref.read(sortDayFlgProvider.notifier).state = false;

        //夕食の日付設定
        if(_tabController.index==1){
          ref.read(selectedDateProvider.notifier).state = DateTime.now();
        }

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
    final topTabIndex = ref.watch(menuToptabIndexProvider);
    final menuViewmodel = ref.read(menuViewModelProvider);
    final dinnerViewmodel = ref.read(dinnerViewModelProvider);
   
    //DefaultCacheManager().emptyCache();

    //final parentContext = context; 

    // index がズレているときに同期させる
  if (_tabController.index != topTabIndex) {
    _tabController.animateTo(topTabIndex); // または jumpTo も可
  }
    
    return GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じるためにGestureDetector使用。
      onTap: () {
        // テキストフィールド以外をタッチしたときにキーボードを閉じる。FocusNodeでフォーカスを外す
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Stack(//フローティングボタン配置のため
        children: [
          Column(
            children: [

              //上部のカテゴリバー_===========================================
              TabBar(
                controller: _tabController,
                isScrollable: true, // タブをスクロール可能にする
                tabs: tabs
                  .map((tag) => Tab(text: tag))
                  .toList(),
                labelColor: Colors.black, // 選択中のタブの文字の色
                unselectedLabelColor: Colors.grey, // 選択されていないタブの文字の色
              ),

            (topTabIndex!= 1) 
              //検索ボックス_================================================
             ? const SearchBox(hint:"料理名")
             : //const SizedBox.shrink(),

              //カレンダーアイコン＋選択日付、値段の横並び_---------------
            Row(
             // mainAxisAlignment: MainAxisAlignment.center,//中央よせ
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,//等間隔（両端空間あり） 
              children: [
                Row(
                  
                  children: [
                //Text("日付選択"),
                

                //選択日付と合計金額の表示_============================================
                Consumer(builder: (context, ref, child) {
                  final selectedDate = ref.watch(selectedDateProvider);
                  //final dinnerTotalPrice = ref.watch(dinnerTotalProvider);
                  return Text(DateFormat('yyyy/MM/dd(E)','ja').format(selectedDate),
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                  );
                }),
                const SizedBox(width: 5,),
                //カレンダーアイコン_=======================================
                const Calendar(),
  
                  ],
                ),
                
                 Consumer(builder: (context, ref, child) {
                  final dinnerTotalPrice = ref.watch(dinnerTotalProvider);
                  return Text("合計$dinnerTotalPrice円",
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),);
                }),


            ]),


              //スクロール可能領域_------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  child:Column(
                    children: [
                    
                      dispMenus.isEmpty 
                      //データがない場合_=========================================
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: 
                              topTabIndex==1
                              ? 
                                   const  Row(
                                      mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
                                      children: [
                                        Text('　下の3つの＋から夕食を選択してください。',
                                        //textAlign: TextAlign.center,
                                        ),
                                       

                                      ],
                                    )
                                    

                              
                             
                              :topTabIndex==2 //予定のタブ
                              ? const Text('予定はありません。\n予定ボタンを押したメニューがここに表示されます。')
                              :  topTabIndex==3 //お気に入りのタブ
                              ? const Text('　お気に入りはありません。\n　❤️アイコンを押したメニューがここに表示されます。')
                              : topTabIndex>3 //お気に入りのタブ
                             ? Text('タグに「${tabs[topTabIndex]}」を選択するとここに表示されます。')
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                            children: [Text('データがありません。\n「＋」をタップしてデータを追加してください。'
                              ,textAlign: TextAlign.center,
                            )
                            ],
                          )
                        )
                      //材料カード領域_--------------------------------------------------
                      : ListView.builder(
                        shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
                        physics: const NeverScrollableScrollPhysics(), // スクロール禁止
                        itemCount: dispMenus.length,
                        itemBuilder: (context, index) {
                          final menu = dispMenus[index];
                          final menuId = menu.id;
                          
                          

                          //カード1枚分_------------------------------------------------------
                          return Card(
                            color: Colors.white,
                            elevation: 1, //影の深さ
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                              onTap: () {
                                ref.read(menuProvider.notifier).state = menu.copyWith();
                                //ref.read(pageIndexProvider.notifier).state = 4;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MenuDetailView()),
                                );
                                
                              },
                              child: Padding( //カード内の左側に隙間を設ける
                                padding: const EdgeInsets.only(left: 10.0),
                                child:Row(
                                  children: [
                                    //テキストエリア_-----------------------------------------------------
                                    Expanded(
                                      flex: 3,//テキスト領域の比率
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                                        children: [
                                          //１列目（料理名とアイコン2つの表示)_------------------------------------------------------------------
                                          Row(
                                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
                                            children: [

                                              
                                              //料理名_==================================================
                                              Text(
                                                menu.name,
                                                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                              ),

                                              


                                          ]),

                                          //２列目（値段とタグ)_-----------------------------------------------------------------------------------
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                                            children: [
                                              //値段_=================================================
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
                                                children: [
                                                  Text("${menu.price.round()}円",//（１人前:${(menu.price/menu.people).round()}円）",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold
                                                  //decoration: TextDecoration.underline,
                                              )),
                                              Text("（１人前:${(menu.price/menu.people).round()}円）",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  //decoration: TextDecoration.underline,
                                              )),
                                                ],
                                              ),
                                              


                                              //タグ_=================================================
                                              Padding(
                                                padding: const EdgeInsets.only(right: 5),
                                                child: Text(menu.tag==""
                                                ? "カテゴリー無"
                                                : menu.tag,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  //decoration: TextDecoration.underline,
                                              ))),


                                          ]),

                                          //３列目(最近食べた日）_----------------------------------------
                                          Text("最近食べた日:${menu.dinnerDate != null
                                            ? DateFormat('yyyy/MM/dd(E)','ja').format(menu.dinnerDate!) 
                                            : "ー"}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              //decoration: TextDecoration.underline,
                                          )),

                                          //4列目(夕食・予定ボタンと値段）ーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                                          Row(
                                            
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  //「夕食」ボタン_=============================================
                                                  ElevatedButton(//枠線ありボタン
                                                    onPressed: () { 
                                                      menu.isDinner = !(menu.isDinner);
                                                      menuViewmodel.iconProcess(menu);

                                                      if(menu.isDinner){
                                                        ref.read(menuToptabIndexProvider.notifier).state = 1;
                                                        _tabController.index = 1;//トップタブの表示を「０：全て」にする」
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: dispMenus[index].isDinner ? 0 : 3,//影の深さ
                                                      //padding: EdgeInsets.zero, // 完全にパディングを削除
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                                      minimumSize: const Size(50, 25), // 最小サイズを指定
                                                      backgroundColor: dispMenus[index].isDinner
                                                        ? const Color.fromARGB(255, 157, 210, 244) 
                                                        : const Color.fromARGB(255, 228, 228, 228),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                                    )),
                                                    child: const Text(
                                                      '夕食',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black
                                                      ),
                                                    ),  
                                                  ),
                                                  const SizedBox(width: 10,),

                                                  //「予定」ボタン_=================================================
                                                  ElevatedButton(//枠線ありボタン
                                                    onPressed: () { 
                                                      dispMenus[index].isPlan = !(dispMenus[index].isPlan);
                                                      menuViewmodel.iconProcess(dispMenus[index]);

                                                      if(dispMenus[index].isPlan){
                                                        ref.read(menuToptabIndexProvider.notifier).state = 2;
                                                        _tabController.index = 2;//トップタブの表示を「０：全て」にする」
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: dispMenus[index].isPlan ? 0 : 3,//影の深さ
                                                      //padding: EdgeInsets.zero, // 完全にパディングを削除
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                                                      minimumSize: const Size(50, 25), // 最小サイズを指定
                                                      backgroundColor: dispMenus[index].isPlan
                                                        ? const Color.fromARGB(255, 244, 157, 240)
                                                        : const Color.fromARGB(255, 228, 228, 228),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5), // 角の丸みを20に設定
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      '予定',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black
                                                      ),
                                                    ),  
                                                  ),]),

                                                  //夕飯タブのみ表示_------------------------------------------------

                                                  (topTabIndex==1)
                                                    ? //const SizedBox.shrink()

                                                    Consumer(
                                                      builder: (context, ref, child) { 
                                                        final peopleMap = ref.watch(peopleMapProvider);
                                                        final peopleCount = peopleMap[menuId] ?? dispMenus[index].people;

                                                        return  Row(
                                                          
                                                          children: [

                                                            //マイナスアイコン_====================================
                                                            IconButton(
                                                              onPressed: () {
                                                                if (peopleCount > 0) {
                                                                  final newMap = {...peopleMap};
                                                                  newMap[menuId] = peopleCount - 1;
                                                                  ref.read(peopleMapProvider.notifier).state = newMap;
                                                                }
                                                              },
                                                              icon: const Icon(Icons.do_not_disturb_on_outlined),
                                                              padding: EdgeInsets.zero,
                                                              iconSize: 25,
                                                            ),

                                                            //何人前の表示_==========================================
                                                            SizedBox(
                                                              width: 50,
                                                              child: Column(
                                                                children: [
                                                                  Text("$peopleCount人前 ",style: const TextStyle(fontSize: 13, height:0, fontWeight: FontWeight.bold),),
                                                                  Text("${(peopleCount*(menu.price/menu.people)).round()}円",style: const TextStyle(fontSize: 12, height:0, ),)
                                                                

                                                            ])),

                                                            //プラスアイコン_========================================
                                                            IconButton(
                                                              onPressed: () {
                                                                final newMap = {...peopleMap};
                                                                newMap[menuId] = peopleCount + 1;
                                                                ref.read(peopleMapProvider.notifier).state = newMap;
                                                              },
                                                              icon: const Icon(Icons.control_point_rounded),
                                                              padding: EdgeInsets.zero,
                                                              iconSize: 25,
                                                            ),


                                                          ]);
                                                    })
                                              
                                                    : //const SizedBox.shrink(),
                                                     //アイコン2つ_==============================================
                                              Row(
                                                children: [
                                                  //お気に入り
                                                  MenuFavoriteIcon(menu),
                                                  //削除アイコン
                                                  MenuDeleteIcon(menu),
                                                  //編集アイコン
                                                  MenuEditIcon(menu, false),


                                                ]),
                                                
                                                
                                     // ]),
                                    

                                  ]),


                              ])),

                              //画像エリア_----------------------------------------------------------
                              Expanded(
                                flex: 1,//画像領域の比率
                                child: Stack(//お気に入りアイコンのためにstack使用
                                  children: [

                                    //画像_=====================================================  
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:SizedBox(
                                        width: 115,  // 必要に応じてサイズを設定
                                        height: 115, 
                                        child:dispMenus[index].imageURL != ''
                                        ? CachedNetworkImage(//画像がある場合
                                          imageUrl: dispMenus[index].imageURL, // ネットワーク画像のURL
                                          placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                            scale: 0.3, // 縮小率を指定
                                            child: const CircularProgressIndicator(strokeWidth: 15.0),
                                          ),
                                          errorWidget: (context, url, error) {

                                            //画像のパスのトークンが期限切れの場合、1回再取得を実施。
                                            final fetchImageUrlBuff = ref.read(fetchImageUrlBuffProvider); 
                                            //print(fetchImageUrlBuff);
                                            //countImageUrl[index] += 1;
                                            if(!fetchImageUrlBuff.contains(menu.imageURL)){
                                              //print("リストにないので再取得します。");
                                             menuViewmodel.fetchImageUrl(menu);
                                             //print(fetchImageUrlBuff);
                                           }else{
                                            //print("リストに存在するので再取得しません。");
                                           }
                                            
                                            return const Center(child:Text("!再度画像登録してください")); //const Icon(Icons.error); // エラーの場合に表示するウィジェット
                                          },
                                          fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                        )
                                        : const SizedBox.shrink()
/*
                                        Image.asset( //画像ない場合
                                          'images/no_image.jpg',
                                          fit: BoxFit.cover,
                                    )
                                    */
                                    )),

                                    //お気に入りアイコン_========================================
                                    /*
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: MenuFavoriteIcon(menu),
                                    ),
                                    */

                              ])),


            ]))));
        }),

      //夕食タブのみ表示_----------------------------------------------------------
      (topTabIndex== 1) 
        ? //const SizedBox.shrink()

        Column(
          children: [

            //自由入力メニューのカード表示_==================================
            const CustomMenuCards(),

            //メニュー一覧から夕食を選択ボタン_=============================================
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {

                  ref.read(menuToptabIndexProvider.notifier).state = 0;
                  _tabController.index = 0;//トップタブの表示を「０：全て」にする」

                },
                icon: const Icon(Icons.control_point_rounded),
                label: const Text('メニュー一覧から夕食を選択'),
              ),
            ),

            //材料一覧から選択_-----------------------------------------------
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async{
                  
                  ref.read(bottomBarIndexProvider.notifier).state = 1;
                  ref.read(pageIndexProvider.notifier).state = 1;
                  ref.read(selectIngFlgProvider.notifier).state = true;//材料一覧画面でカードタップできるようにする。
                  ref.read(createFlgProvider.notifier).state = false;



                  //await Navigator.push(
                    //parentContext,
                    //MaterialPageRoute(builder: (context) => CommonScaffold()),
                  //);
                  //材料一覧から材料を選択した時に以下処理を実施。


                },
                icon: const Icon(Icons.control_point_rounded),
                label: const Text('材料一覧から材料選択'),
              ),
            ),

            //自由入力ボタン_=============================================
            const Align(
              alignment: Alignment.centerLeft,
              child: CustomMenuAddButton(),
            ),


            //夕食決定ボタン_==============================================
            const DinnerAddButton(),

            //LINE共有
            TextButton.icon(
              onPressed: () async{

                //print("line");
                final dinner = dinnerViewmodel.createDinner();
                String menuNames = "今日の夕食です٩( 'ω' )و\n";
                menuNames += dinner.menus.map((menu) => "・${menu['name']} ").join('\n');
                //print(menuNames);

                final bool? result = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDialog2(
                    message: 'この内容をLINEで転送します。\n\n$menuNames',
                  ),
                );
                if (result == true) {
                  menuViewmodel.launchLineAppWithMessage(menuNames);
                }
                
              },
              icon: Image.asset(
                'images/icons8-line-48.png',
                width: 30,
                height: 30,
              ),
              label: const Text('夕食をLINEで共有'),
            ),


            //夕飯履歴一覧へのリンク
            TextButton(
              onPressed: (){

                Navigator.push(//AndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DinnerList()),
                  //(Route<dynamic> route) => false, // 条件を false にしてすべて削除
                );


              }, 
              child: const Text("夕食の履歴のページへ移動")
            )
        
          
        ])
   
        : const SizedBox.shrink(),
     
     
      ]))),


    ]),
    // フローティングボタンを配置_==============================================
    Positioned(
      bottom: 16, // 下からの距離
      right: 16,  // 右からの距離
      child: FloatingActionButton(
        onPressed: (){
          menuViewmodel.addBotton();
          // 一瞬待ってから遷移（build前にmenuが更新されるように）
  //Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MenuCreateView()),
          );
  //});

      },
      child: const Icon(Icons.add),
    )),


  ]));
  //bottomNavigationBar: const CustomBottomBar(),
  // );
}}