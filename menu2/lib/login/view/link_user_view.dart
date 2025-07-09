import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_utils.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/login/data/model/login.dart';


class LinkUserView extends ConsumerStatefulWidget{
  const LinkUserView({super.key});
  @override
  ConsumerState<LinkUserView> createState() => LinkUserViewState();
}

class  LinkUserViewState extends ConsumerState<LinkUserView> {

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
    final familyData =  ref.read(familyDataProvider);//「アプリ共有機能」ボタンを押した時に、ファミリーデータを取得している。
    
    return 
    Scaffold(
        appBar:const CustomAppBar(title: "ユーザー連携"),
        body:
        
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 縦方向で中央揃え
            children: [
              const SizedBox(height: 30),
            
              const Text('自分のデータを共有したい相手ユーザーの\n登録メールアドレスを入力してください。\n相手ユーザーのアプリに連携許可を出します。',
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
                    text: '連携を許可する', 
                    fixedSize: const Size(220, 35),
                    onPressed: () async{ 

                      final bool? result = await showDialog<bool>(
                        context: context,
                        builder: (context) => const ConfirmDialog2(
                          message: 'あなたのデータを連携しても良いですか？',
                        ),
                      );

                      //データ連携の確認OKの場合
                      if (result == true) {
                        final bool checkResult = await viewModel.checkRequests(textControllers.emailController.text);
                        
                        //データ連携できる相手か確認OKの場合
                        if(checkResult){
                          //await viewModel.linkuser(textControllers.emailController.text);
                          await viewModel.addRequests(targetEmail: textControllers.emailController.text);
                          
                          if(context.mounted){
                            await showDialog<bool>(
                            context: context,
                            builder: (context) => const ConfirmDialog1(
                              //context: context,
                              message: 'アプリ連携の招待を送りました。\n相手のユーザー画面より「アプリ連携機能」のボタンを押してください。',
                            ),
                          );
                          }
                        
                        //データ連携できる相手か確認NGの場合
                        }else{

                          if(context.mounted){
                            await showDialog<bool>(
                              context: context,
                              builder: (context) => const ConfirmDialog1(
                                //context: context,
                                message: 'このユーザーにはすでに他の方とアプリ連携しているため、アプリ連携の許可は送れません。',
                              ),
                            );
                          }
                        }
                      }

                      
                      }),
                    const SizedBox(height: 20,),
                    familyData != null && familyData['membersEmail']!=null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("現在の連携メンバー: ${familyData['membersEmail'].length}人"),
                        ...familyData['membersEmail'].map<Widget>((email) => Text(dispMaskEmail(email.toString()))).toList(),
                      ],
                    )
                  : const Text("現在の連携メンバーはいません"),
                                
                                
                        ]
        ),
          
        )
        
        
        //bottomNavigationBar: const CustomBottomBar(),
    );

}}