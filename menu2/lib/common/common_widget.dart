import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/menu/view_model/menu_view_model.dart';

class CustomBottomBar extends ConsumerWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomBarIndexProvider);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(bottomBarIndexProvider.notifier).state = index;
        ref.read(pageIndexProvider.notifier).state = index;
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
          label: '夕食の履歴',
        ),
      ],
    );
  }
}


//検索ボックス
class SearchBox extends ConsumerWidget {

  //ヒント句をページによって変えるため
  final String hint;
  const SearchBox(this.hint);

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
          prefixIcon: Icon(Icons.search),
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
                // フィルターや並び替えの機能が追加できる
                icon: const Icon(
                  Icons.abc,
                  size: 25,
                ),
                onPressed: () {
                  ref.read(sortAiuFlgProvider.notifier).state = true;
                  ref.read(sortDayFlgProvider.notifier).state = false;
                  print("aiu");
                  print(ref.read(sortAiuFlgProvider));               
                },
              ),
              IconButton(
                // フィルターや並び替えの機能が追加できる
                icon: const Icon(
                  Icons.sort,
                  size: 25,
                ),
                onPressed: () {
                  ref.read(sortAiuFlgProvider.notifier).state = false;
                  ref.read(sortDayFlgProvider.notifier).state = true;
                  print("日付");
                  print(ref.read(sortDayFlgProvider));  
                },
              ),
            ]
          ),

        ),
      ),
    );
  }
}


//確認ダイアログ
class ConfirmDialog extends StatelessWidget {
  final String message;

  const ConfirmDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

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

//テキストフィールドの設定
Widget buildTextField({
  //required String labelText,
  final String hintText = '',
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  double setWidth = 300,
  double setHeight = 30,
  int setMaxline = 1,
  TextAlign textAlign = TextAlign.center,
}) {
  return Column(
    children: [
      SizedBox(
        height: setHeight,
        width: setWidth,
        child: TextField(
          maxLines: setMaxline,
          textAlign: textAlign, //hintTextの左右を中央揃え
          controller: controller, // コントローラー
          keyboardType: keyboardType, // キーボードタイプ
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

