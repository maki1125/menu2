import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/menu/view_model/menu_view_model.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:menu2/menu/data/model/menu.dart';

class MenuCreateView extends ConsumerStatefulWidget{
  @override
  ConsumerState<MenuCreateView> createState() => MenuCreateViewState();
}

class  MenuCreateViewState extends ConsumerState<MenuCreateView>{

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
  @override
  void dispose() {
    super.dispose(); // ← 必ず呼ぶ
  }

    @override
  void initState() {
    super.initState();

     //テキストフィールドの初期値の設定

  }

  
    @override
  Widget build(BuildContext context) {

    final menu = ref.watch(menuProvider);
    final nameTextController = ref.read(nameTextControllerProvider);

    if(menu!=null){
    nameTextController.text=menu.name;
    }

    

    return Column(
            children: [
              const SizedBox(height: 5,),//材料名テキストフィールドとアプリバーの間に隙間を設ける

              //料理名ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
              buildTextField(
                  hintText: '料理名',
                  controller: nameTextController,
                  keyboardType: TextInputType.text,
                  setWidth: 250,
              ),
            ]
    );

  }
}