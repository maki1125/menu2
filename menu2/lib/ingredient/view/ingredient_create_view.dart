import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/ingredient/view/ingredient_common_widget.dart';


//材料登録画面_======================================================
class IngCreateView extends ConsumerStatefulWidget{
  const IngCreateView({super.key});
  @override
  ConsumerState<IngCreateView> createState() => IngCreateViewState();}

class IngCreateViewState extends ConsumerState<IngCreateView>{

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
  @override
  void dispose() {
    super.dispose(); 
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final ing = ref.read(ingProvider);
    final viewModel = ref.read(ingViewModelProvider);
    final ingEditFlg = ref.read(ingEditFlgProvider);
    final ingTextControllersList = ref.read(ingTextControllerListProvider); 
   

    //編集時のテキストフィールドの初回表示の設定
    if(ingEditFlg){
      ingTextControllersList[0].nameController.text=ing.name;
      ingTextControllersList[0].quantityController.text=ing.quantity.toString();
      ingTextControllersList[0].unitController.text=ing.unit;
      ingTextControllersList[0].priceController.text=ing.price.toString();
    }

    return Scaffold(
      appBar:AppBar(title: const Text("材料登録")),
      body: Column(
        children: [
          
          //注意書き-------------------------------------------------
          const SizedBox(height: 5,),//材料名テキストフィールドとアプリバーの間に隙間を設ける
          const Text('左スワイプで削除'),
          const SizedBox(height: 10,),

          //タイトル--------------------------------------------------
          ingTextFieldTitle(context),

          //テキストフィールドエリア-------------------------------------
          ingTextFields(context, ref, "ing"),
          /*
          if(ingTextControllersList.length==1)
            ingTextFieldUnit(ingTextControllersList[0], context, ref)
          else
            ...[      
    
              for (int i = 0; i < ingTextControllersList.length; i++)

                //テキストフィールド１行分
                Dismissible(
                  key: UniqueKey(), // 一意なキーを使う必要があります！
                  direction: DismissDirection.endToStart, // 右スワイプ
                  onDismissed: (direction) {
                    // スワイプ時の処理（コントローラ削除）
                    ref.read(ingTextControllerListProvider.notifier).removeController(i);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete),//, color: Colors.white),
                  ),
                  child: ingTextFieldUnit(ingTextControllersList[i], context, ref),
                ),
              

            ],
            */
          //テキストフィールド追加ボタンーーーーーーーーーーーーーーーーーーーーーー
          ingEditFlg //新規登録だけ追加ボタンを機能させる
            ? const SizedBox.shrink()
            :
            //材料行の追加ボタン_----------------------------------------
                  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ref.read(ingTextControllerListProvider.notifier).addController();
                    },
                    icon: const Icon(Icons.control_point_rounded),
                    label: const Text('材料行の追加'),
                  ),
                ]),
          
              
          //更新ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          ingEditFlg
          ? OutlinedButton(//枠線ありボタン
            onPressed: () async{ 
              final result =await viewModel.updateIng();


              if(result){
                if(context.mounted){
                  Navigator.pop(context);
                }
              
              //ref.read(ingTextControllerProvider.notifier).disposeAll();

              //更新メッセージ
             showMessage("データを更新しました");
                
              }else{
                showMessage(ref.read(errorMessageProvider));
              }
            },
            style: OutlinedButton.styleFrom(
              //padding: EdgeInsets.zero, // 完全にパディングを削除
              //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
              minimumSize: const Size(50, 30), // 最小サイズを指定
              backgroundColor:  Colors.blue,
            ),
            child: const Text('変更',
              style:  TextStyle(
              //fontSize: 12,
              color: Colors.white
              ),
            ),    
          )

          //新規登録ボタンーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
          : OutlinedButton(//枠線ありボタン
            onPressed: () async{ 
              final result = await viewModel.newIngs();

              if(result){
                if(context.mounted){
                 Navigator.pop(context); 
                }
              
              //ref.read(ingTextControllerProvider.notifier).disposeAll();

              //更新メッセージ
              showMessage("データを新規登録しました");
              }else{
                showMessage(ref.read(errorMessageProvider));
              }
            },
            style: OutlinedButton.styleFrom(
              //padding: EdgeInsets.zero, // 完全にパディングを削除
              //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
              minimumSize: const Size(50, 30), // 最小サイズを指定
              backgroundColor:  Colors.orange,
            ),
            child: const Text('新規登録',
              style: TextStyle(
              //fontSize: 12,
              color: Colors.white
              ),
            ),    
          ),

          //戻るボタン----------------------------------------------
          returnButtton(context),


        ]));
}}
