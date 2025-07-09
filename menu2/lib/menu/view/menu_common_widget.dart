import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:intl/intl.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/view/menu_create_view.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';
import 'package:menu2/plan/view/dinner_list_view.dart';


//メニューお気に入りボタン_==================================================================================================
/*使い方-------------------
MenuFavoriteIcon(menu),
--------------------------*/
class MenuFavoriteIcon extends ConsumerWidget {
  final Menu menu;
  const MenuFavoriteIcon(this.menu, {super.key});//({super.key, required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuViewmodel = ref.read(menuViewModelProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
      child: Padding(
        padding: const EdgeInsets.all(4.0), // タッチ領域を調整
        child: Icon(
          Icons.favorite,
          size: 23,
          color: menu.isFavorite
      ? Colors.pink
      : Colors.grey,
        ),
      ),
      onTap: () async{ 
        final updatedMenu = menu.copyWith(isFavorite: !(menu.isFavorite)); //copyWithで新しいインスタンス作成。
        ref.read(menuProvider.notifier).state = updatedMenu;//プロバイダーが変更を検知できるように新しいインスタンスを入れる。
        
        //新規登録のお気に入りボタンの場合、idがまだないため、idがある時だけ以下処理を実施する。
        if(updatedMenu.id.isNotEmpty){
          menuViewmodel.iconProcess(updatedMenu);
        }
      });
}}

//メニュー編集アイコン_====================================================
/*使い方--------------------
MenuEditIcon(menu, false),
---------------------------*/
class MenuEditIcon extends ConsumerWidget {
  final bool detailFlg;//詳細画面の時は、画面遷移時に今の画面を消して遷移させる。リストからの遷移は今のページの上に新しい画面を表示させる。
  final Menu menu;
  const MenuEditIcon(this.menu, this.detailFlg, {super.key});//({super.key, required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuViewmodel = ref.read(menuViewModelProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
      child: const Padding(
        padding:  EdgeInsets.all(4.0), // タッチ領域を調整
        child: Icon(
          Icons.edit,
          size: 23,
        ),
      ),
      onTap: () async{ 
        //print("編集ボタン押しました。");
        menuViewmodel.editBotton(menu);

        //詳細画面の時は、画面遷移時に今の画面を消して遷移させる。リストからの遷移は今のページの上に新しい画面を表示させる。
        if(detailFlg){
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuCreateView()),
        );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MenuCreateView()),
          );
        }
        
      });
}}

//メニュー削除アイコン_=========================================================
/*使い方1（一つ前の画面に戻る場合）-------------
MenuDeleteIcon(menu,
  onDeleted: () {
    Navigator.pop(context);
  },
),
使い方２（今のページのままの場合）
MenuDeleteIcon(menu)
--------------------------------------------*/
class MenuDeleteIcon extends ConsumerWidget {
  final Menu menu;
  final VoidCallback? onDeleted; // ← 削除後に呼ばれるコールバック。編集のページでは、元の画面に戻るために設定。
  const MenuDeleteIcon(this.menu, {this.onDeleted, super.key});//({super.key, required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuViewmodel = ref.read(menuViewModelProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(50), // 丸い波紋効果
      child: const Padding(
        padding:  EdgeInsets.all(4.0), // タッチ領域を調整
        child: Icon(
          Icons.delete,
          size: 23,
        ),
      ),
      onTap: () async{ 
        final bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => const ConfirmDialog2(
            message: 'このメニューを削除しますか？',
          ),
        );

        if (result == true) {
          ref.read(menuProvider.notifier).state = menu;
          menuViewmodel.deleteMenu(menu);
          showMessage("データを削除しました。");
          onDeleted?.call(); //コールバックで、onDeletedの処理実行。編集ページで削除したときは、元のページに戻る。
        }
      });
}}

//タイトルテキストの設定_============================================
Widget titleText({
  required String title,
}) {
  return Text(
    title,
    style: const TextStyle(
      //color: Colors.red,
      fontSize: 20,
      fontWeight: FontWeight.bold
    ),
    textAlign: TextAlign.left,
  );
}

//メニューの自由入力ボタン========================================================
/*使い方---------------------
const CustomMenuAddButton(),
-----------------------------*/
class CustomMenuAddButton extends ConsumerWidget {
  const CustomMenuAddButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textControllers = ref.read(menuTextControllersProvider);
    
    final customMenuViewmodel = ref.read(customMenuViewModelProvider);//customMenuの処理のメソッド集
    
    return TextButton.icon(
      icon: const Icon(Icons.control_point_rounded),
      label: const Text('自由に入力'),
      onPressed: () {
        textControllers.clear();
        ref.read(menuProvider.notifier).state = Menu();
        //ダイアログ表示
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                constraints: const BoxConstraints.expand(width: 400, height: 280),//ダイアログウィンドウのサイズ
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    //題名************************************
                    const Text("自由入力メニュー",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    const SizedBox(height:20),

                    //料理名入力フィールド************************
                    Row(
                      children: [
                        const SizedBox(
                          height: 30,
                          width: 50,
                          child: Text("料理名",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold ))),
                      
                        textField(
                          hintText: "ハンバーガー",
                          controller: textControllers.nameController,
                          keyboardType: TextInputType.text,
                          setWidth: 210,
                        ),
                      ]),

                    //値段入力フィールド**************************
                    Row(
                      children: [
                        const SizedBox(
                          height: 30,
                          width: 50,
                          child: Text("値段",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold ))),
                        textField(
                          hintText: '350',
                          controller: textControllers.priceController,
                          keyboardType: TextInputType.number,
                          setWidth: 170,
                        ),
                        const SizedBox(
                          height: 30,
                          width: 40,
                          child: Text("　円",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold ))),
                      ]),

                    
                    //登録ボタン************************************
                    const SizedBox(height: 16),
                      customButton(
                        text: '決定',
                        onPressed: () async {
                          bool result = await customMenuViewmodel.newMenu();
                          if(result){
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                          }else{
                            showMessage(ref.read(errorMessageProvider));
                          }
                          
                        },
                      ),

                    //戻るボタン**************************************
                    returnButtton(context),


                  ]
                )));
          });
    });
}}


//自由入力メニューのカード表示
/*使い方----------------
const CustomMenuCards()
------------------------*/
class CustomMenuCards extends ConsumerWidget {
  const CustomMenuCards({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customMenuViewmodel = ref.read(customMenuViewModelProvider);//customMenuのメソッド集
    final dispCustomMenus = ref.watch(dispCustomMenusProvider);//表示用の自由入力メニュー

    return ListView.builder(
      shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
      physics: const NeverScrollableScrollPhysics(), // スクロール禁止
        itemCount: dispCustomMenus.length,
        itemBuilder: (context, index) {
          final customMenu = dispCustomMenus[index];

          return Card(
            color: Colors.white,
            elevation: 1, //影の深さ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child:Padding( //カード内の左側に隙間を設ける
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                children: [

                  //料理名
                  SizedBox(
                    width: 200,
                    child: Text(customMenu.name),
                  ),
                  
                  //値段
                  SizedBox(
                    width: 70,//10万円台＋円が入る大きさ
                    child: Text("${customMenu.price}円",
                    textAlign: TextAlign.right,),
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
                      await customMenuViewmodel.deleteMenu(dispCustomMenus[index]);
                  },),

                ],)));
         });
}}

//夕食登録ボタン
/*使い方-----------------
const DinnerAddButton()
-------------------------*/
class DinnerAddButton extends ConsumerWidget {
  const DinnerAddButton({super.key});
 
@override
  Widget build(BuildContext context, WidgetRef ref) {
     final dinnerViewmodel = ref.read(dinnerViewModelProvider);

  return  customButton(
      text: "夕食決定！",
      onPressed: () async{

        final dinner = dinnerViewmodel.createDinner();
        String menuNames ='';
        menuNames += "${DateFormat('yyyy/MM/dd(E)','ja').format(ref.read(selectedDateProvider))}\n";
        menuNames += dinner.menus.map((menu) => "・${menu['name']} ").join('\n');
        menuNames += "\n合計：${ref.read(dinnerTotalProvider).toString()}円";
        final bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => ConfirmDialog2(
            message: 'この内容で夕食登録しますか？。\n\n$menuNames',
          ),
        );
        if (result == true) {
          
        
        bool result = await dinnerViewmodel.newDinner();
        
        if(result){

          //ref.read(bottomBarIndexProvider.notifier).state = 2;
          //ref.read(pageIndexProvider.notifier).state = 3;
          if (context.mounted) {
            Navigator.push(//pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DinnerList()),
              //(Route<dynamic> route) => false, // 条件を false にしてすべて削除
            );
          }
        }else{
          showMessage(ref.read(errorMessageProvider));
        }
        }
        

      });
  }
}