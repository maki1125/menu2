import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menu2/common/common_providers.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/menu/data/model/menu.dart';


//材料登録時のテキストフィールド１行分_=========================================
//画面サイズによりテキストフィールドの大きさを設定する為にcontextを渡す。

Widget ingTextFieldUnit(IngTextControllers ingTextCons, BuildContext context, WidgetRef ref) {
  final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
    children: [

      //料理名
      textField(
        hintText: '材料名',
        controller: ingTextCons.nameController,
        keyboardType: TextInputType.text,
        setWidth: screenWidth * 0.39,
      ),

      //数量
      textField(
        hintText: '数量',
        controller: ingTextCons.quantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),//小数点入力できるようにする
        setWidth: screenWidth * 0.19,
      ),
      //単位
      textField(
        hintText: '単位',
        controller: ingTextCons.unitController,
        keyboardType: TextInputType.text,
        setWidth: screenWidth * 0.19,
      ),
      //値段
      textField(
          hintText: '値段',
          controller: ingTextCons.priceController,
          keyboardType: TextInputType.number,
          setWidth: screenWidth * 0.19,
          onChanged: (value){
         
          ref.read(menuTotalPriceCalTrigerProvider.notifier).state = !ref.read(menuTotalPriceCalTrigerProvider);//値段の入力を変えた時にリアルタイムに合計値計算するため。
      
        }
      ),


    ]);
}




//材料登録時のテキストフィールド複数行(List分全て表示）_=========================================
Widget ingTextFields(BuildContext context, WidgetRef ref, String id) {

  dynamic ingTextControllersList;
   if(id=="menu"){
    //メニュー登録画面の時
    ingTextControllersList = ref.watch(menuIngTextControllerListProvider); //テキストフィールドを増やしたりするのでwatchで再描写できるようにする。
   }else{
    //材料登録画面の時
    ingTextControllersList = ref.watch(ingTextControllerListProvider); //テキストフィールドを増やしたりするのでwatchで再描写できるようにする。
   }
   
   //１行以降は左スワイプで削除できるように設定
   return //ingTextControllersList.length==1
    //? ingTextFieldUnit(ingTextControllersList[0], context, ref)
    //: 
    Column(
        children: [   
          for (int i = 0; i < ingTextControllersList.length; i++)
          (ref.read(bottomBarIndexProvider)==1 && ingTextControllersList.length==1)//材料のページのみ。メニューの材料行はselectもあるので削除できるようにする。
          ? ingTextFieldUnit(ingTextControllersList[i], context, ref) // 1行だけなら普通に表示
            //テキストフィールド１行分
          :  
          Dismissible(
              key: ValueKey(ingTextControllersList[i].id),
              direction: DismissDirection.endToStart, // 右スワイプ
              onDismissed: (direction) {
                //print("dismissibleid:${ingTextControllersList[i].id}");
                // スワイプ時の処理（コントローラ削除）
                //Future.microtask(() {
                  if(id=="menu"){
                    ref.read(menuIngTextControllerListProvider.notifier).removeController(i);
                  }else{
                    ref.read(ingTextControllerListProvider.notifier).removeController(i);
                  }
                
          //});
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete),//, color: Colors.white),
              ),
              child: ingTextFieldUnit(ingTextControllersList[i], context, ref),
            ),
              

        ]);
}


//材料一覧から選択時のテキストフィールド１行分
//画面サイズによりテキストフィールドの大きさを設定する為にcontextを渡す。
//Widget selectIngTextFieldUnit(SelectIngTextControllers selectIngTextCons, BuildContext context, WidgetRef ref) {
Widget selectIngTextFieldUnit(SelectIngTextControllers selectIngTextCons, double width, WidgetRef ref) { 
  final screenWidth = width;//MediaQuery.of(context).size.width; // 端末の画面幅を取得
  //
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
    children: [

      //材料名
      SizedBox(
        width: screenWidth * 0.39,
        child:Text(selectIngTextCons.name,
        textAlign: TextAlign.center, // テキストを中央揃え),
        overflow:TextOverflow.ellipsis,
        maxLines: 2,
        )
      ),
      //数量
      textField(
        hintText: '数量',
        controller: selectIngTextCons.quantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),//小数点入力できるようにする
        setWidth: screenWidth * 0.19,
        onChanged: (value){
          ref.read(menuTotalPriceCalTrigerProvider.notifier).state = !ref.read(menuTotalPriceCalTrigerProvider);
          
          //価格の計算
          if(value.isNotEmpty){
            selectIngTextCons.subtotal = (double.tryParse(value)! * (selectIngTextCons.unitPrice));
          }else{
            selectIngTextCons.subtotal = selectIngTextCons.unitPrice;
          }
          
        }
      ),
      //単位
      SizedBox(
        width: screenWidth * 0.19,
        child:Text(selectIngTextCons.unit,
        overflow:TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.center, // テキストを中央揃え),
        )
      ),
      //値段
      Consumer(builder: (context, ref, child) {
        ref.watch(menuTotalPriceCalTrigerProvider);
        return SizedBox(
        width: screenWidth * 0.19,
        child:Text(selectIngTextCons.subtotal.toStringAsFixed(1)[selectIngTextCons.subtotal.toStringAsFixed(1).length -1]=="0"
                            ? selectIngTextCons.subtotal.toStringAsFixed(0)//整数表示
                            : selectIngTextCons.subtotal.toStringAsFixed(1),//少数第一位まで表示,//小数点第一位まで表示
        textAlign: TextAlign.center, // テキストを中央揃え),
        overflow:TextOverflow.ellipsis,
        maxLines: 2,
        ),
      );
      },),
     

    ]);
}

//材料登録時のテキストフィールド複数行(List分全て表示）_=========================================
Widget selectIngTextFields(BuildContext context, WidgetRef ref) {
   final selectIngTextControllersList = ref.watch(selectIngTextControllerListProvider); //テキストフィールドを増やしたりするのでwatchで再描写できるようにする。
     final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得
   //１行以降は左スワイプで削除できるように設定
   return Column(
        children: [   
          for (int i = 0; i < selectIngTextControllersList.length; i++)
             //selectIngTextControllersList.length == 1
          //? selectIngTextFieldUnit(selectIngTextControllersList[i], context, ref) // 1行だけなら普通に表示
            //テキストフィールド１行分
          
            
            //テキストフィールド１行分
            //: 
            Dismissible(
              key: ValueKey(selectIngTextControllersList[i].id),//quantityController),//UniqueKey(), // 一意なキーを使う必要があります！
              direction: DismissDirection.endToStart, // 右スワイプ
              onDismissed: (direction) {
                // スワイプ時の処理（コントローラ削除）
                ref.read(selectIngTextControllerListProvider.notifier).removeController(i);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete),//, color: Colors.white),
              ),
              child: selectIngTextFieldUnit(selectIngTextControllersList[i], screenWidth, ref),
            ),
              

        ]);
}

//テキストフィールドのタイトル表示_=====================================
Widget ingTextFieldTitle(BuildContext context) {
   final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
    children: [
      SizedBox(
        width: screenWidth * 0.39,
        child: const Text("材料", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold), )
      ),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("数量", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("単位", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      SizedBox(
        width: screenWidth * 0.19,
        child: const Text("価格", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      ),


    ]);
}

//夕食の材料一覧から選択のダイアログ表示
void dinnerSelectIngDialog(WidgetRef ref, BuildContext context, Ing ing){
  final textControllers = ref.read(menuTextControllersProvider);
  textControllers.clear();
  final customMenuViewmodel = ref.read(customMenuViewModelProvider);//customMenuの処理のメソッド集
  //final screenWidth = MediaQuery.of(context).size.width; // 端末の画面幅を取得  
  ref.read(selectIngTextControllerListProvider.notifier).disposeAll();                       
  ref.read(selectIngTextControllerListProvider.notifier).addController(ing, ref) ; 
  final selectIngTextControllersList = ref.read(selectIngTextControllerListProvider);  
  ref.read(menuProvider.notifier).state = Menu();

  showDialog(
    context: context,
    builder: (context) =>
  Dialog(
  child: Container(
    constraints: const BoxConstraints.expand(width: 400, height: 280),//ダイアログウィンドウのサイズ
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        //題名************************************
        const Text("材料一覧から夕食登録",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        const SizedBox(height:20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
          children: [
            selectIngTextFieldUnit(selectIngTextControllersList[0], 250, ref),
            const Text("円"),


          ],
        ),
        

        //登録ボタン************************************
        const SizedBox(height: 16),
          customButton(
            text: '決定',
            onPressed: () async {
              final menuTextControllers = ref.read(menuTextControllersProvider);
              menuTextControllers.nameController.text = selectIngTextControllersList[0].name;
              double price = ing.quantity!=0 ?(ing.price/ing.quantity) * double.tryParse(selectIngTextControllersList[0].quantityController.text)! : 0;
              //print("price:${price.toString()}");
              menuTextControllers.priceController.text = price.toString();
              //print("price:${menuTextControllers.priceController.text}");
              customMenuViewmodel.newMenu();
              ref.read(bottomBarIndexProvider.notifier).state = 0;
              ref.read(pageIndexProvider.notifier).state = 0;
              ref.read(selectIngFlgProvider.notifier).state = false; //選択後は、タッチ不可にする。
              
              Navigator.of(context).pop();
            },
          ),

        //材料を選び直すボタン**************************************
        TextButton(
          onPressed: () {
            if(context.mounted){
              Navigator.of(context).pop();
            }
            
          },
          child: const Text('材料を選び直す'),
        ),
        //戻るボタン**************************************
                          TextButton(
          onPressed: () {
            if(context.mounted){
              ref.read(bottomBarIndexProvider.notifier).state = 0;
              ref.read(pageIndexProvider.notifier).state = 0;
              ref.read(selectIngFlgProvider.notifier).state = false; //選択後は、タッチ不可にする。
              Navigator.of(context).pop();
            }
            
          },
          child: const Text('戻る'),
        ),


        ]
      ))));
}