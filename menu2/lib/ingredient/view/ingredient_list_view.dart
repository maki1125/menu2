import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/ingredient/view/ingredient_create_view.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/ingredient/view/ingredient_common_widget.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';

//材料一覧
class IngList extends ConsumerStatefulWidget{
  const IngList({super.key});

  @override
  ConsumerState<IngList> createState() => IngListState();
}

class  IngListState extends ConsumerState<IngList>{

  @override
  Widget build(BuildContext context) {

    final dispIngs = ref.watch(dispIngsProvider); //材料一覧をリアルタイムに表示させるためwatch
    final viewmodel = ref.read(ingViewModelProvider);

    return GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じるためにGestureDetector使用。
      onTap: () {
        // テキストフィールド以外をタッチしたときにキーボードを閉じる。FocusNodeでフォーカスを外す
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child:Stack(//フローティングボタン配置のため
        children: [
          Column(
            children: [
              //検索ボックス-----------------------------------
              const SearchBox(hint:"材料名"),

              //カードエリア-----------------------------------
              Expanded(
                child: SingleChildScrollView(
                  child:dispIngs.isEmpty
                  //データがない場合*****************************************
                  ? const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                      children: [
                      Text('データがありません。\n「＋」をタップしてデータを追加してください。',)
                      ],
                    )
                  )

                  //材料カード*********************************************
                : ListView.builder(
                  shrinkWrap: true, // 高さ自動調整。ListViewが無限広がろうとするのを防ぐ。
                  physics: const NeverScrollableScrollPhysics(), // スクロール禁止
                  itemCount: dispIngs.length,
                  itemBuilder: (context, index) {
                    final ing = dispIngs[index];

                    return Card(
                      color: Colors.white,
                      elevation: 1, //影の深さ
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(//タップ可能領域（条件によりタップ可能）とアイコン(常時タップ可能）を切り分けるためにstack使用
                        children: [
                          //テキスト領域（タップ可能領域）ーーーーーーーーーーーーーーーーーーー
                          IgnorePointer(
                            //タップできる条件をつける。
                            ignoring: ref.read(selectIngFlgProvider.notifier).state == false, //「材料一覧から選択」時以外はタッチ不可能にする。
                            child: InkWell(//タッチした時にインクが広がる感じのエフェクトを設定
                              onTap: () async{
                                 //検索ボックスのテキストクリア
                                final searchTextController = ref.read(searchTextControllerProvider);
                                searchTextController.clear();
                                ref.read(searchTextProvider.notifier).state = '';
                                              
                                //print("createFlg:${ref.read(createFlgProvider)}");
                                
                                
                                //メニュー一覧の夕食の「材料一覧から選択」の場合
                                if(!ref.read(createFlgProvider)){
                                  dinnerSelectIngDialog(ref, context, ing);
                                //メニュー登録の「材料一覧から選択」場合
                                }else{
                                  ref.read(bottomBarIndexProvider.notifier).state = 0;
                                  ref.read(pageIndexProvider.notifier).state = 0;
                                  ref.read(selectIngFlgProvider.notifier).state = false; //選択後は、タッチ不可にする。
                                  Navigator.pop(context,ing);
                                }
                                //ref.read(ingProvider.notifier).state = ing;
                                        //if (Navigator.canPop(context)) {//遷移前の画面があるかどうか確認
                                          //Navigator.pop(context,ing);
                                         // } 
                                //Navigator.pop(context, ing);
                              
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0), 
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                                  children: [
                                    const SizedBox(width: 25,),//アイコンの領域確保のため

                                    //材料名--------------------------
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        ing.name,
                                        //overflow:TextOverflow.ellipsis,
                                        //maxLines: 1,
                                        //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                      ),
                                    ),

                                    //数量と単位-------------------------
                
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        ing.quantity.toStringAsFixed(1)[ing.quantity.toStringAsFixed(1).length -1]=="0"
                                        ? ing.quantity.toStringAsFixed(0)+ing.unit//整数表示
                                        : ing.quantity.toStringAsFixed(1)+ ing.unit,//少数第一位まで表示
                                        //overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        //maxLines: 1,
                                        //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                      ),
                                    ),

                                    //値段-------------------------------
                                    SizedBox(
                                      width: 70,//5桁(万円）までは表示できる。十万円単位から三点リーダ表示される。
                                      child: Text(
                                        "${ing.price.toString()} 円",
                                        //overflow: TextOverflow.ellipsis,
                                        //maxLines: 1,
                                        textAlign: TextAlign.right,
                                        //style: TextStyle(fontSize: 16), // フォントサイズの調整
                                      ),
                                    ),
                                    const SizedBox(width: 25,)//アイコンの領域確保のため


                                ]))
                                
                              )),

                              Positioned.fill(//カードの上に配置する。アイコンはいつでもタッチできるようにするため。
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // 最小サイズ
                                    mainAxisAlignment: MainAxisAlignment.start, // 右寄せ
                                    children: [
                                //編集アイコン----------------------------
                                InkWell(
                                  borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0), // タッチ領域を調整
                                    child: Icon(
                                      Icons.edit,
                                      size: 23,
                                    ),
                                  ),
                                  onTap: () async{
                                    ref.read(ingEditFlgProvider.notifier).state = true;
                                    ref.read(ingTextControllerListProvider.notifier).disposeAll();
                                    ref.read(ingProvider.notifier).state = ing.copyWith();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const IngCreateView()),
                                    );
                                  }
                                ),


                                          
                                        ]))),

                                        Positioned.fill(//カードの上に配置する。アイコンはいつでもタッチできるようにするため。
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // 最小サイズ
                                    mainAxisAlignment: MainAxisAlignment.end, // 右寄せ
                                    children: [
                               

                              // 削除アイコン--------------------------------
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
                                  builder: (context) =>ConfirmDialog2(
                                    message: "「${ing.name}」を削除しますか？",
                                  ));

                                if (result == true) {
                                  viewmodel.deleteIng(ing);
                                  showMessage("データを削除しました。");
                                }
                              }
                              ),

                                          
                                        ]))),

                       ])
                        
                        );
                  }))),
                  ref.read(selectIngFlgProvider)
                  ?TextButton(
    onPressed: () {

        ref.read(bottomBarIndexProvider.notifier).state = 0;
        ref.read(pageIndexProvider.notifier).state = 0;
        ref.read(selectIngFlgProvider.notifier).state = false;//材料一覧画面でカードタップできるようにする。
        //検索ボックスのテキストクリア
        final searchTextController = ref.read(searchTextControllerProvider);
        searchTextController.clear();
        ref.read(searchTextProvider.notifier).state = '';
        if (Navigator.canPop(context)) {//遷移前の画面があるかどうか確認
  Navigator.pop(context);
} 
    },
    child: const Text('戻る'),
  )
  :const SizedBox.shrink(),
//アイコンの配置ーーーーーーーーーーーーーーーー
                                  

          ]),

          // フローティングボタンを配置ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          Positioned(
            bottom: 16, // 下からの距離
            right: 16,  // 右からの距離
            child: FloatingActionButton(
              onPressed: (){
                viewmodel.addBotton();
                 //検索ボックスのテキストクリア
                final searchTextController = ref.read(searchTextControllerProvider);
                searchTextController.clear();
                ref.read(searchTextProvider.notifier).state = '';
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IngCreateView()),
                );
              },
              child: const Icon(Icons.add),
          )),


      ])); 


}}