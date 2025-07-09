import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io'; //Fileを扱うため
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/main_view.dart';
import 'package:menu2/menu/view/menu_common_widget.dart';
import 'package:menu2/menu/view/menu_detail_view.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/ingredient/view/ingredient_common_widget.dart';


class MenuCreateView extends ConsumerStatefulWidget{
  const MenuCreateView({super.key});

  @override
  ConsumerState<MenuCreateView> createState() => MenuCreateViewState();
}

class  MenuCreateViewState extends ConsumerState<MenuCreateView>{

  @override
  void initState() {
    super.initState();
  }

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
  @override
  void dispose() {
    super.dispose(); // ← 必ず呼ぶ
  }

  @override
  Widget build(BuildContext context) {
    //print("menucreatebuild");

    final menu = ref.read(menuProvider);
    final menuUpdate = menu!.copyWith();

    //print("menuimageURL:${menu.imageURL}");
    final menuTextControllers = ref.read(menuTextControllersProvider); 
    final menuViewModel = ref.read(menuViewModelProvider);
    final editFlg = ref.read(editFlgProvider);
    //final createFlg = ref.read(createFlgProvider);
    //final imageURLBuff = menu.imageURL;
    //print("menuimageURLBuff:${ imageURLBuff}");

    bool isLoading = ref.watch(loadingFlgProvider); // 登録処理のローディング状態をリアルタイムに表示させるため。
   
    return Scaffold(
      appBar:AppBar(title: const Text("メニュー登録")),
      //resizeToAvoidBottomInset: false, // キーボードの表示を調整しない
      body: 
      GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じる
      onTap: () {
        // FocusNodeでフォーカスを外す
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child:SingleChildScrollView(//スクロール可能とする
      child: Stack(//ローディング表示のため
        children: [
        
          //お気に入りボタン_===============================================
          /*
          Positioned(
            top: 0,
            right: 0,
            child: MenuFavoriteIcon(menu!)
          ),
           */ 
          Column(
            children: [
              const SizedBox(height: 5,),//材料名テキストフィールドとアプリバーの間に隙間を設ける

              //料理名_====================================================
              textField(
                  hintText: '料理名',
                  controller: menuTextControllers.nameController,
                  keyboardType: TextInputType.text,
                  setWidth: 250,
              ),

              //材料ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
              
              //材料題名_---------------------------------------------------
              Row(//Rowで囲まないと材料が左揃えにならないため。
                children: [
                  const SizedBox(width: 10,),
                  titleText(title: '材料'),
                  const SizedBox(width: 10,),
                  const Text("※左スライドで削除"),


                ]),
              
              //材料タイトルと材料テキストフィールド_-----------------------------
              ingTextFieldTitle(context),
              ingTextFields(context, ref, "menu"),
              selectIngTextFields(context, ref),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,//等間隔 （両端空間なし）
                children: [

                  //材料行の追加ボタン_----------------------------------------
                  TextButton.icon(
                    onPressed: () {
                      ref.read(menuIngTextControllerListProvider.notifier).addController();
                    },
                    icon: const Icon(Icons.control_point_rounded),
                    label: const Text('材料行の追加'),
                  ),

                  //合計金額_--------------------------------------------------
                  Consumer(
                    builder: (context, ref, child) {
                      final menuTotalPrice = ref.watch(ingTotalPriceProvider);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('合計金額: ¥', style: TextStyle(fontSize: 15,),),
                          SizedBox(
                            width: 70, // 幅を固定！
                            child: Text(
                              menuTotalPrice.toString(),
                              textAlign: TextAlign.right, // 右寄せするとよりきれい
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        const SizedBox(width: 5,),//右の隙間
                        

                      ]);
                  }),


              ]),

              //材料一覧から選択_-----------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.start,//等間隔（両端空間あり）
                children: [

                  TextButton.icon(
                    onPressed: () async{
                      
                      ref.read(bottomBarIndexProvider.notifier).state = 1;
                      ref.read(pageIndexProvider.notifier).state = 1;
                      ref.read(selectIngFlgProvider.notifier).state = true;//材料一覧画面でカードタップできるようにする。
                      ref.read(createFlgProvider.notifier).state = true;
                      
                      final ing = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CommonScaffold()),
                      );
                      //材料一覧から材料を選択した時に以下処理を実施。
                      if(ing != null){
                        ref.read(selectIngTextControllerListProvider.notifier).addController(ing, ref);
                        
                      }

                      //材料一覧のページから戻ったらページの設定をメニュー一覧に戻す。戻るボタンを押した時に戻れるように。
                      ref.read(bottomBarIndexProvider.notifier).state = 0;
                      ref.read(pageIndexProvider.notifier).state = 0;
                    },
                    icon: const Icon(Icons.control_point_rounded),
                    label: const Text('材料一覧から材料選択'),
                  ),

              ]),
              const SizedBox(height: 10,),

            //「分量・タグ・作り方題名」と画像の横並----------------------------------                                                
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                    children: [

                      //分量ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                      Row(
                        children: [
                          const SizedBox(width: 10,),
                          titleText(title: '分量'),
                          const SizedBox(width: 10,),
                          Row(
                            children: [
                              textField(
                                hintText: '1',
                                controller: menuTextControllers.peopleController,
                                keyboardType: TextInputType.number,
                                setWidth: 50,
                              ),
                              const Text(" 人前"),
                            ]),
                      ]),

                      //タグ選択ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                      Row(
                        children: [
                          const SizedBox(width: 10,),
                          titleText(title: 'タグ'),
                          const SizedBox(width: 10,),
                          Consumer( //タグ変更時に再描写のエリアを制限するためconsumer使用。
                            builder: (context, ref, child) {
                              final selectedTag = ref.watch(tagProvider); // プルダウンの選択項目
                              return DropdownButton<String>(
                                hint: const Text('カテゴリー無'), // ヒント表示
                                value: selectedTag,
                                items: menuTags.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item), // 表示内容
                                  );
                                }).toList(),
                                onChanged: (String? tag) {
                                  if (tag != null) {
                                    ref.read(tagProvider.notifier).state = tag; // 値を更新
                                  }
                                });
                          }),
                      ]),
                      const SizedBox(height: 10,),

                      //作り方の題名------------------------------------------------------
                      Row(//Rowで囲まないと材料が左揃えにならないため。
                        children: [
                          const SizedBox(width: 10,),
                          titleText(title: '作り方'),
                      ]),


                ])),

                //画像選択ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),// 8ピクセルの余白
                    child: GestureDetector(
                      onTap: () async{
                        await menuViewModel.selectImage();
                      }, // 領域をタップしたら画像選択ダイアログを表示
                      child: Consumer( //画像選択変更時に、ここだけ再描写されるようにconsumer使用。
                        builder: (context, ref, child){
                          bool selectImageFlg = ref.watch(selectImageFlgProvider);
                          final File? selectedImage = ref.watch(selectedImageProvider); //選択画像
                          //print("selectedImage:$selectedImage");
                          //print("画像を表示します");
                          return Stack( //バツのアイコンをつけるため。
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // 背景色
                                  border: Border.all(color: Colors.grey), // 枠線
                                  borderRadius: BorderRadius.circular(10), // 角丸
                                ),
                                child: selectedImage != null
                                //①選択された画像がある場合
                                ? 
                        
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                                    child: 
                                    Image.file(
                                      ref.read(selectedImageProvider)!, //selectedImageだと前に選択した画像が表示されてしまう
                                      fit: BoxFit.cover, // 領域に合わせて表示
                                      //width: 130,
                                      //height: 130,
                                    ),
                                  )

                                //画像を選択するの前の状態
                                : 
                                /*selectImageFlg
                                ?Center(child: CircularProgressIndicator())
                                : */
                              menuUpdate.imageURL=="" 
                                    //②画像選択してください
                                    ? const Center(
                                      child: Text(
                                        '画像を選択',
                                        style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    //③編集前の画像表示
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(10), // 選択画像の角丸
                                      child:
                                        CachedNetworkImage(
                                          imageUrl: menuUpdate.imageURL, // ネットワーク画像のURL
                                          placeholder: (context, url) =>  Transform.scale(//sizedboxでは小さくならなかったのでscaleを使用。
                                            scale: 0.3, // 縮小率を指定
                                            child: const CircularProgressIndicator(strokeWidth: 20.0),
                                          ),
                                          
                                          errorWidget: (context, url, error){
                                            return const Center(child:Text("!再度画像登録してください"));//return const Icon(Icons.error);}
                                          }, // エラーの場合に表示するウィジェット
                                          fit: BoxFit.cover, // 画像の表示方法を指定（例：全体をカバー）
                                        )
                                        )
                              
                          ),

                          // 🧹 右上の消しゴムアイコン
                          if (selectedImage != null || (menuUpdate.imageURL != ""))
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  //menu.imagePathBuf = menu.imagePath;
                                  menuUpdate.imageURL = "";//罰を押したら元々のURLを空欄にする。
                                  ref.read(selectImageFlgProvider.notifier).state = !selectImageFlg;
                                  ref.read(selectedImageProvider.notifier).state = null;
                                  
                                  //setState(() {});//再描写
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    //color: Colors.red, // アイコンの背景色
                                    shape: BoxShape.circle, // 丸型にする
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: const Icon(
                                    Icons.cancel, // 消しゴムの代わりに「×」アイコン
                                    color: Colors.white,
                                    size: 25,
                            )))),

                        ]);
                    })))),


            ]),

            //作り方_======================================================
            const SizedBox(height: 10,),
            textField(
              hintText: "1.材料混ぜて、形を作る。\n2.強火で２分焼く",
              controller: menuTextControllers.howToMakeController,
              keyboardType: TextInputType.multiline,
              setWidth: 350,
              setHeight: 120,
              setMaxline: 5,
              textAlign: TextAlign.left,
            ),

            //メモ_=========================================================
            Row(
              children: [
                const SizedBox(width: 10,),
                titleText(title: 'メモ'),
            ]),
            const SizedBox(height: 10,),
            textField(
              hintText: '美味しかった。また作りたい。',
              controller: menuTextControllers.memoController,
              keyboardType: TextInputType.multiline,
              setWidth: 350,
              setHeight: 60,
              setMaxline: 2,
              textAlign: TextAlign.left,
            ),

            //登録ボタン_======================================================
            editFlg
            //更新ボタン_--------------------------------------------------
            ? OutlinedButton(//枠線ありボタン
              onPressed: () async{ 
                ref.read(menuProvider.notifier).state = menuUpdate;
                final result = await menuViewModel.updateMenu();
                if(result){
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuDetailView()),//詳細ページに遷移
                );
              }
                showMessage("データを更新しました");
              }else{
                showMessage(ref.read(errorMessageProvider));
              }},
              style: OutlinedButton.styleFrom(
                //padding: EdgeInsets.zero, // 完全にパディングを削除
                //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // パディングを調整
                minimumSize: const Size(50, 30), // 最小サイズを指定
                backgroundColor: Colors.blue,
              ),
              child: const Text('変更',
                style: TextStyle(
                //fontSize: 12,
                color: Colors.white
                ),
              ),    
              )

            //新規登録ボタン_----------------------------------------------------
            : OutlinedButton(//枠線ありボタン
              onPressed: () async{ 
                ref.read(menuProvider.notifier).state = menuUpdate;
                final result = await menuViewModel.newMenu();

                if(result){
                  if (context.mounted) {
                    showMessage("データを新規登録しました");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuDetailView()),
                    );
                  }
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
              ))),

            //戻るボタン_=============================================
            TextButton(
              onPressed: () {
                if(context.mounted){
                  //print("imageURLBUff:$imageURLBuff");
                  ref.read(selectedImageProvider.notifier).state = null;
                  //menu.imageURL = imageURLBuff;
                  Navigator.of(context).pop();
                }
                
              },
              child: const Text('戻る'),
            ),
            const SizedBox(height: 50,)


        ]),

        // ローディングインジケーター_----------------------------------
        Positioned(
          top: MediaQuery.of(context).size.height / 2 , // 高さの中央
          right: MediaQuery.of(context).size.width / 2 , // 幅の中央
          child:isLoading
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : const SizedBox.shrink()
        ),


    ])))

    //bottomNavigationBar: const CustomBottomBar(),
    );
  }
}

