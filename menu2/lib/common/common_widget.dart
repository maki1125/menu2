import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/login/view/login_view.dart';


//ボトムバー
class CustomBottomBar extends ConsumerWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomBarIndex = ref.watch(bottomBarIndexProvider);

    return BottomNavigationBar(
      currentIndex: bottomBarIndex,
      onTap: (index) {

        ref.read(bottomBarIndexProvider.notifier).state = index;
        ref.read(pageIndexProvider.notifier).state = index;
        //if(index==0 && ref.read(menuToptabIndexProvider)!=1){
        ref.read(menuToptabIndexProvider.notifier).state = 0;//ボトムバーの「メニュー一覧」を押したら「全て」のタブが表示されるように。
        //検索ボックスのテキストクリア
        final searchTextController = ref.read(searchTextControllerProvider);
        searchTextController.clear();
        ref.read(searchTextProvider.notifier).state = '';
        //}
        
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'メニュー一覧',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.filter_vintage),
          label: '材料一覧',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flatware),
          label: '献立',
        ),
      ],
    );
  }
}

//AppBar
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {//AppBarとして使用するためPreferredSizeWidgetを使用
  //AppBarの高さを指定するためのWidget
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(50); //AppBarの高さを指定

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.pacifico(), //Googleフォントを使用
      ),
      centerTitle: true, //タイトルを中央に配置
      elevation: 10.0, //影の設定
      actions: title=="ユーザー" || title=='ユーザー連携' || title=='パスワードリセット'
      ? null //ユーザー画面の時は右のアイコンを非表示にする
      : <Widget>[
        authState.when(
          data: (user) {
            //FirebaseAuth.instance.currentUser?.reload();
          //final user = FirebaseAuth.instance.currentUser;
            if (user?.isAnonymous == false) {
            return  Padding(
              padding: const EdgeInsets.only(right: 10), 
              child:
            
                user!.photoURL != null
                ? GestureDetector(
                  onTap: () {
                    //ref.read(pageIndexProvider.notifier).state = 4;
                    ref.read(loadingFlgProvider.notifier).state = false;
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoURL!),
                    radius: 15, // 小さくする（25 → 20）
                  ),
                )
                : IconButton(
                  icon: const Icon(Icons.account_circle, size: 32),
                  onPressed: () {
                    //ref.read(pageIndexProvider.notifier).state = 4;
                    ref.read(loadingFlgProvider.notifier).state = false;
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView())
                    );
                    
                  },
                )
                );
            } else {
              //匿名ログイン
              return IconButton(
                icon: const Icon(Icons.no_accounts, size: 32), // ユーザーが存在しない場合
                onPressed: () {
                  //ref.read(pageIndexProvider.notifier).state = 4;
                  ref.read(loadingFlgProvider.notifier).state = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView())
                  );
                  
                },
              );
            }
          },

          loading: () => const CircularProgressIndicator(), // ローディング中
          error: (error, stack) => const Icon(Icons.error), // エラー時
        ),
      ],
      //centerTitle: true,
      backgroundColor: Colors.white,
    );
  }
}


//検索ボックス
class SearchBox extends ConsumerWidget {
  
  final String hint; //ヒント句をページによって変えるため
  const SearchBox({super.key, required this.hint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextController = ref.read(searchTextControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: searchTextController,
        keyboardType: TextInputType.text, // キーボードタイプ
        onChanged: (text) => {
          ref.read(searchTextProvider.notifier).state = text,
        },
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none, // 枠線を非表示
          //border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          hintStyle: const TextStyle(
            color: Color.fromARGB(255, 198, 198, 198)
          ), // hintTextの色を設定
          //右側のアイコン
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,  // アイコンを必要な分だけ並べる
            children: [
              IconButton(
                // あいうえお順ソート
                icon: const Icon(
                  Icons.abc,
                  size: 25,
                ),
                onPressed: () {
                  ref.read(sortAiuFlgProvider.notifier).state = true;
                  ref.read(sortDayFlgProvider.notifier).state = false;
                  //("aiu");
                 // print(ref.read(sortAiuFlgProvider));               
                },
              ),
              IconButton(
                // 作成順ソート
                icon: const Icon(
                  Icons.sort,
                  size: 25,
                ),
                onPressed: () {
                  ref.read(sortAiuFlgProvider.notifier).state = false;
                  ref.read(sortDayFlgProvider.notifier).state = true;
                  //print("日付");
                  //print(ref.read(sortDayFlgProvider));  
                },
              ),


            ]
          ),
        ),
      ),
    );
  }
}




//確認ダイアログ(２択)
/*使い方======================================
final bool? result = await showDialog<bool>(
  context: context,
  builder: (context) => const ConfirmDialog2(
    message: 'このメニューを削除しますか？',
  ),
);
if (result == true) {
  showMessage("データを削除しました。");
}
==============================================*/
class ConfirmDialog2 extends StatelessWidget {
  final String message;

  const ConfirmDialog2({
    super.key,
    required this.message,
  }); 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),//falseを返す
          child: const Text('いいえ'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),//trueを返す
          child: const Text('はい'),
        ),
      ],
    );
  }
}

//確認ダイアログ(1択)
/*使い方========================================
final bool? result = await showDialog<bool>(
  context: context,
  builder: (context) => const ConfirmDialog1(
    message: 'アプリ共有の招待はオーナーに依頼してください。',
  ),
);
if (result == true) {
  showMessage("よろしくです。");
}
===============================================*/
class ConfirmDialog1 extends StatelessWidget {
  final String message;

  const ConfirmDialog1({
    super.key,
    required this.message,
  }); 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),//trueを返す
          child: const Text('はい'),
        ),
      ],
    );
  }
}

//テキストフィールドの設定
/*使い方==============================================
textField(
  hintText: '料理名',
  controller: textControllers.nameController,
  keyboardType: TextInputType.text,
  setWidth: 250,
  onChanged: (value) {
    ref.read(priceUpdateProvider.notifier).state++;
  },
),
=======================================================*/
Widget textField({
  //required String labelText,
  Key? key, // 
  final String hintText = '',
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  double setWidth = 300,
  double setHeight = 30,
  int setMaxline = 1,
  TextAlign textAlign = TextAlign.center,
  bool obscureText = false, // テキストの表示、非表示を切り替える
  void Function(String)? onChanged, //テキストが変わるたび
  String? valuse,
}) {
  return Column(
    children: [
      SizedBox(
        height: setHeight,
        width: setWidth,
        child: TextField(
          autofocus: false,
          key: key,
          maxLines: setMaxline,
          textAlign: textAlign, //hintTextの左右を中央揃え
          controller: controller, // コントローラー
          keyboardType: keyboardType, // キーボードタイプ
          obscureText: obscureText, // パスワードの表示切り替え
          onChanged: onChanged, 
          decoration: InputDecoration(
            // テキストフィールドの装飾
            //labelText: labelText,
            hintText: hintText,
            //floatingLabelAlignment: FloatingLabelAlignment.center,//ラベルがテキストフィールドの中央に配置されます。
            //floatingLabelBehavior: FloatingLabelBehavior.always,//ラベルは常に浮き上がった状態で表示されます。
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 3, vertical: 5), //hintTextの垂直方向を中央に揃える。
            hintStyle: const TextStyle(
                color: Color.fromARGB(255, 198, 198, 198)), // hintTextの色を設定
          ),
        ),
      ),
      const SizedBox(height: 10,),
    ],
  );
}

//ポップアップメッセージ(メッセージのみ)
//使い方：showMessage("ログアウトしました");
void showMessage(String message) {
  Fluttertoast.showToast(
    msg: message, // メッセージを設定
    timeInSecForIosWeb: 1, // 表示時間
    //gravity: ToastGravity.BOTTOM, // 表示位置
    gravity: ToastGravity.CENTER, // 表示位置
    fontSize: 16.0, // フォントサイズ
    //backgroundColor: Colors.black, // 背景色
    //textColor: Colors.white, // 文字色
  );
}


//テキストボタン(ログイン、夕食)
/*使い方=================================
 customButton(
  text: 'ログイン', 
  onPressed: (){
    authRepo.signInEmailAndPassword();
}),
=========================================*/
Widget customButton({
  required String text,
  required VoidCallback onPressed,
  Color backgroundColor = Colors.deepPurple,
  Color fontColor = Colors.white,
  double fontSize = 15,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  Size minimumSize = const Size(70, 30),
  Size? fixedSize,// = null,
  double borderRadiusValue = 4.0, // 角丸の指定
}) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: padding,
      minimumSize: minimumSize,
      fixedSize: 
      //fixedSize != null
      //? 
      fixedSize,
      //: null,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusValue), // ← ここで生成！
      ),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: fontSize, color: fontColor),
      //textAlign: TextAlign.left,
    ),
  );
}

//日付選択
class Calendar extends ConsumerWidget {
  const Calendar({super.key, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return 
    //IconButton(
      ElevatedButton.icon(
        onPressed: () async{
          DateTime? pickDate;
          pickDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // 初期表示日
            firstDate: DateTime(2000), // 選択可能な最小日付
            lastDate: DateTime(2100), // 選択可能な最大日付
            locale: const Locale('ja'), // カレンダーを日本語表示
          );

          if(pickDate != null){//日付選択されなかったときは今日の日付を設定
            
            ref.read(selectedDateProvider.notifier).state = pickDate;//選択日をプロバイダに設定
          //print(pickDate);
          }
        },
        icon: const Icon(Icons.calendar_month),
        label: const Text('日付選択')
        //iconSize: 30,
      );
  }}

//戻るボタン_=================================================  
Widget returnButtton(BuildContext context){
  return TextButton(
    onPressed: () {
      if(context.mounted){
        Navigator.of(context).pop();
      }
    },
    child: const Text('戻る'),
  );
}
