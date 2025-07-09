import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //DateFormatを使用のため。
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';

class DinnerList extends ConsumerStatefulWidget{
  const DinnerList({super.key});
  @override
  ConsumerState<DinnerList> createState() => DinnerListState();
}

class  DinnerListState extends ConsumerState<DinnerList>{

  @override
  Widget build(BuildContext context) {
    final dispDinners = ref.watch(dispDinnersProvider);
    final viewModel = ref.read(dinnerViewModelProvider);

    return 
    Scaffold(
      appBar:AppBar(title: const Text("夕食の履歴")),
      body:
    
    Stack(//フローティングボタン配置のため
      children: [
    Column(
       children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // 中央寄せ
          children: [
           //全てボタン==========================================================
                TextButton(
                  onPressed: () {
                    ref.read(selectedDropDownProvider.notifier).state = ""; //プルダウンの選択を初期化
                    ref.read(selectedDateProvider.notifier).state = DateTime.now(); //選択日付を初期化
                    //print("${dispDinners.length}");
                  },
                  child: const Text(
                    '全て',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                _dropDownFileter(ref),

                 //合計の表示=============================================================
                Text(
                  style: const TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                  ),
                  "合計：${viewModel.dispDinnersTotalPrice()}円"
                ),

          ],
        ),

//選択週の表示＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
        (ref.read(selectedDropDownProvider) != "")//フィルタ選択あり
        ? Row(
         
          children: [
            const Calendar(),

            Expanded(//カレンダーを右端、それ以外は日付表示にするため、テキストエリアをexpandする。
                          child:
            Text(
              
              viewModel.dispFilterDate(),
              style: const TextStyle(
                fontSize: 16,
                
                //fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            )
          ],
        )
        :const SizedBox.shrink(),//フィルタない場合

Expanded(
      child:
         SingleChildScrollView(
      child:dispDinners.isEmpty
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
        itemCount: dispDinners.length,
        itemBuilder: (context, index) {
          final dinner = dispDinners[index];
          return Card(
            color:  dinner.date.weekday == 6 //土曜日(青)
                            ? const Color.fromARGB(255, 225, 246, 255)
                            : dinner.date.weekday == 7 //日曜日（赤）
                              ? const Color.fromARGB(255, 255, 229, 242)
                              : Colors.white,//平日(白）
            elevation: 1, //影の深さ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child:Padding(
                                padding: const EdgeInsets.only(left:10, bottom: 5),
                                child: 
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,// 上下方向の中央寄せ
             crossAxisAlignment: CrossAxisAlignment.start,//左寄せ
              children: [

                //日付と値段と削除アイコン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                  children: [
//日付ーーーーーーーーーーーーーーーーーーーーーーーーーーー
                    Text(
                      DateFormat('yyyy/MM/dd(E)','ja').format(dinner.date),
                      style: const TextStyle(fontSize: 13),
                    ),

                    Row(
                      children: [
                        //値段ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                        Text('${dinner.totalPrice.toString()}円',
                          style: const TextStyle(fontSize: 14)
                        ),

                        //ゴミ箱アイコンーーーーーーーーーーーーーーーーーーーーーーーーーーー
                        InkWell(
                          borderRadius: BorderRadius.circular(50), // 丸い波紋効果
                          child: const Padding(
                            padding: EdgeInsets.all(4.0), // タッチ領域を調整
                            child: Icon(
                              Icons.delete,
                              size: 23,
                            ),
                          ),
                          onTap: ()async{
                            final bool? result = await showDialog<bool>(
                    context: context,
                    builder: (context) =>const ConfirmDialog2(

                      message: 'この夕食履歴を削除しますか？',
                    ),
                  );

                  if (result == true) {
                    //ref.read(menuProvider.notifier).setMenu(menu);
                    //ref.read(menuProvider.notifier).deleteMenu();
                    viewModel.deleteDinner(dinner);
                    showMessage("データを削除しました。");
                    //ref.read(pageIndexProvider.notifier).state = 0;
                  }
                          }
                        ),
                      ],
                    ),

                  ]
                ),

                //メニューの表示ーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                Text(
                  //maxText(dinner.select!.join(", "), 25),
                  dinner.menus.map((menu) => menu['name'] as String).join(", "),
                  style: const TextStyle(fontSize: 15,
                  //fontWeight: FontWeight.bold
                  ),
                  overflow:TextOverflow.ellipsis, // テキストがはみ出た場合の処理
                  maxLines: 2,
                ),
                
                


              ],
            ),
            )


    );})),)



       ]),


      ]),

  
//bottomNavigationBar: const CustomBottomBar(),
    );
  
  }

    // フィルターのドロップダウン
  Widget _dropDownFileter(ref) {
    final selectedValue = ref.watch(selectedDropDownProvider); // プルダウンの選択項目    
    final List<String> dropdownItems = ["月", "週", "日"]; //タグのプルダウンの項目
    return DropdownButton(
      hint: const Text('フィルタ'),
      value: dropdownItems.contains(selectedValue)
            ? selectedValue
            : null, // 選択値がリストに含まれていない場合は`null`
      alignment: Alignment.center,
      items: dropdownItems.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item), // 表示内容
              );
            }).toList(),
      onChanged: (value) {
        ref.read(selectedDropDownProvider.notifier).state = value; // 値を更新
      },
    );
  }

  
}

