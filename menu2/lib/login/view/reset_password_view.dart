import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/login/data/model/login.dart';

class ResetPasswordView extends ConsumerStatefulWidget{
  const ResetPasswordView({super.key});
  @override
  ConsumerState<ResetPasswordView> createState() => ResetPasswordState();
}

class  ResetPasswordState extends ConsumerState<ResetPasswordView> {
  late final LoginTextControllers textControllers;

    @override
  void initState() {
    super.initState();
    textControllers = ref.read(loginTextControllersProvider);
  }

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
  @override
  void dispose() {
    //textControllers.dispose();
    super.dispose(); // ← 必ず呼ぶ
  }

@override
  Widget build(BuildContext context) {
    final viewModel = ref.read(loginViewModelProvider);

return Scaffold(
    appBar:const CustomAppBar(title: "パスワードリセット"),
    body:Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 縦方向で中央揃え
        children: [
          const SizedBox(height: 30),
        
          const Text('登録したメールアドレスを入力してください。\nパスワードリセットのリンクが送信されます。',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          textField(
                hintText: 'メールアドレス',
                controller: textControllers.emailController,
                keyboardType: TextInputType.emailAddress,
                setWidth: 300,
                setHeight: 40
              ),

              customButton(
                text: 'リセットリンクを送信する', 
                fixedSize: const Size(220, 35),
                onPressed: () async{ 
                  await viewModel.resetPassword();
                  }),


          ]
    ),
    ),
    
    
    //bottomNavigationBar: const CustomBottomBar(),
);

}}