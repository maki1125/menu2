import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart'; //画像キャッシュ
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:menu2/main_view.dart';
import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_utils.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/login/view/reset_password_view.dart';
import 'package:menu2/login/view/link_user_view.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/login/data/model/login.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';


class LoginView extends ConsumerStatefulWidget{
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => LoginViewState();
}

class  LoginViewState extends ConsumerState<LoginView> with SingleTickerProviderStateMixin {
  late final LoginTextControllers textControllers;
  late TabController _tabController; //ログインと新規登録

    @override
  void initState() {
    super.initState();
    textControllers = ref.read(loginTextControllersProvider);
    _tabController = TabController(length: 2, vsync: this); // タブコントローラーの初期化
  }

  //リソース解放。ウィジェット破棄後に、コントローラを破棄。
  @override
  void dispose() {
    //textControllers.dispose();
    _tabController.dispose(); // メモリリークを防ぐために破棄
    super.dispose(); // ← 必ず呼ぶ
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(loginViewModelProvider);
    //final currentUser = ref.read(currentUserProvider);
    //final authRepo = ref.read(authRepositoryProvider);
    final authState = ref.watch(authStateProvider);
    final loadingFlg = ref.watch(loadingFlgProvider);

  return 
  Scaffold(
    appBar:const CustomAppBar(title: "ユーザー"),
    body:
    
    authState.when(
      data: (user) {
        //print("user:${user!.isAnonymous}_${user!.uid}");

        //ログイン・新規登録画面（匿名ログインの状態）*****************************
        if(user==null || user.isAnonymous){
          return 
          GestureDetector(// テキストフィールド以外をタッチしたときにキーボードを閉じる
            onTap: () {
              // FocusNodeでフォーカスを外す
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Stack( //ローディングマークを配置するため、stack使用。
              children: [
                Column(
                  
                  children: [
                    TabBar(
                      controller: _tabController, 
                      tabs: const [
                      Tab(text: 'ログイン'),
                      Tab(text: '新規登録'),
                    ]),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(controller: _tabController, 
                        children:[
                          SingleChildScrollView(//スクロール可能とする
                          child:

                          //ログイン画面========================================================
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.center,//中央よせ
                            children:[
                              
                              
                              textField(
                                hintText: 'メールアドレス',
                                controller: textControllers.emailController,
                                keyboardType: TextInputType.emailAddress,
                                setWidth: 300,
                                setHeight: 40
                              ),
                              textField(
                                hintText: 'パスワード',
                                controller: textControllers.passwordController,
                                keyboardType: TextInputType.text,
                                setWidth: 300,
                                setHeight: 40,
                                obscureText:true,//非表示
                              ),
                              SizedBox(
                                height: 40,
                                child:  TextButton(//枠線なしボタン。リンクっぽい？
                                  onPressed: () { 
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ResetPasswordView()),
                                    );

                                  },
                                  child: const Text('パスワードを忘れた場合はこちら'), 
                                ),
                              ),

                              //const SizedBox(height: 10),

                              customButton(
                                text: 'ログイン', 
                                fixedSize: const Size(220, 35),
                                onPressed: () async{ 
                                  bool result = await viewModel.signInEmailAndPassword(); 
                                  if(result){
                                    showMessage("ログインしました");
                                    
                                    //メニュー一覧にページ遷移
                                    ref.read(pageIndexProvider.notifier).state = 0;
                                    ref.read(menuToptabIndexProvider.notifier).state = 0;

                                    if(context.mounted){
                                      Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CommonScaffold()),
                                      (Route<dynamic> route) => false, // 条件を false にしてすべて削除
                                    );
                                    }
                                    
                                    
                                  }else{
                                    showMessage(ref.read(errorMessageProvider));
                          }}),
/*
                    TextButton(//枠線なしボタン。リンクっぽい？
                      onPressed: () { 
                        //print("${user!.uid}");
                        showMessage(user!.uid);
                        //User? user = auth
                       },
                      child: const Text('uid'),
                    ),
                    */

                        //Text("familyId:${ref.read(familyIdProvider)}"), //アドレス表示
                        //Text("uid:${ref.read(userIdProvider)}"), //アドレス表示

                          // 区切り線
                          const Divider(
                            height: 40,
                            thickness: 0.5,
                            indent: 50,
                            endIndent: 50,
                            color: Colors.black,
                          ),
                          const Text("外部アカウントでログイン"),
                          const SizedBox(height: 10,),
                          //appleログインボタン
                          SizedBox(
                            width: 250,
                            height: 35,
                            child:  SignInWithAppleButton(
                              onPressed: () async {
                                bool result = await viewModel.signInApple();
                              //print("result:$result");
                              if(result){//キャンセルやエラーの時は画面遷移しない
                                showMessage("Appleアカウントでログインしました");

                                 //メニュー一覧にページ遷移
                                ref.read(pageIndexProvider.notifier).state = 0;
                                ref.read(menuToptabIndexProvider.notifier).state = 0;
                                if(context.mounted){
                                  Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CommonScaffold()),
                                  (Route<dynamic> route) => false, // 条件を false にしてすべて削除
                                );
                                }
                            }else{
                                showMessage(ref.read(errorMessageProvider));
                              }

                            },
                          ),
                          ),
                          const SizedBox(height: 10,),
                         
                          // Googleログインボタン==================================
                          SizedBox(
                            width: 250,
                            height: 35,
                            child: SignInButton(
                            Buttons.Google,
                            onPressed: () async {
                              bool result = await viewModel.signInGoogle();
                              //print("result:$result");
                              if(result){//キャンセルやエラーの時は画面遷移しない
                                showMessage("googleアカウントでログインしました");

                                 //メニュー一覧にページ遷移
                                ref.read(pageIndexProvider.notifier).state = 0;
                                ref.read(menuToptabIndexProvider.notifier).state = 0;
                                if(context.mounted){
                                  Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CommonScaffold()),
                                  (Route<dynamic> route) => false, // 条件を false にしてすべて削除
                                );
                                }
                              }else{
                                showMessage(ref.read(errorMessageProvider));
                              }},),
                          ),
                          

                        const SizedBox(height: 40),
                        //const Text(" ※データを保存するにはログインしてください。")
                        const Text(" 現在、ゲストとしてアプリ使用中",
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),),
                        Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16.0),
                              child:SizedBox(
                              
                                child: Text("＊・ゲストのデータ保存は各10個に制限されます。\n　・アプリを閉じて開いた場合、\n　　別のゲストとなり前のデータを参照できなくなることがあります。\n　・アカウント登録すると、保存件数の制限が解除され、\n　　ログインすればいつでもデータ参照できます。\n　・お問い合わせする場合、以下のuidを記載ください。\n　　uid:${user?.uid ?? ''}",
                                style: const TextStyle(color: Colors.black, fontSize: 10),
                              ))),
                        
                        ])
                      ),

                        //新規登録タブ================================================
                         SingleChildScrollView(//スクロール可能とする
                        child:
                        Column(
                          children:[

                          textField(
                            hintText: 'メールアドレス',
                            controller: textControllers.emailController,
                            keyboardType: TextInputType.emailAddress,
                            setWidth: 300,
                            setHeight: 40
                          ),
                          textField(
                            hintText: 'パスワード',
                            controller: textControllers.passwordController,
                            keyboardType: TextInputType.text,
                            setWidth: 300,
                            setHeight: 40,
                            obscureText:true,//非表示
                          ),
                          const SizedBox(height: 50),

                          customButton(
                            text: '新規登録', 
                            fixedSize: const Size(220, 35),
                            onPressed: ()async{  
                              bool result = await viewModel.singUpEmailAndPassword(); 
                              if(result){
                                //print("新規登録しました");
                                //print("userId:${ref.read(userIdProvider)}");
                                showMessage("新規登録しました");

                                //メニュー一覧にページ遷移
                                ref.read(pageIndexProvider.notifier).state = 0;
                                ref.read(menuToptabIndexProvider.notifier).state = 0;

                                if(context.mounted){
                                  Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CommonScaffold()),
                                  (Route<dynamic> route) => false, // 条件を false にしてすべて削除
                                );
                                }
                                }else{
                                  //print("新規登録失敗しました");
                                  showMessage(ref.read(errorMessageProvider));
                            }}),  
                        ])
                         ),
                ]))
               // )
                ]),
        
              // ローディングインジケーター==========================================
              Positioned(
                bottom: MediaQuery.of(context).size.height / 2 , // 高さの中央
                left: MediaQuery.of(context).size.width / 2 - 20, // 幅の中央
                child: loadingFlg
                ? const Center(
                  child: CircularProgressIndicator(),
                )
                : const SizedBox.shrink()
            )])
            
            //)
            //)
            );



        }else{
          
          //ユーザー画面**************************************************************
          return Stack( //お気に入りボタンを右上に配置するため、stack使用。
            children: [
              SingleChildScrollView(//スクロール可能とする
               child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,//上下方向に中央よせ
                  children:[
                    const SizedBox(height: 100,),

                    //アイコン--------------------------------
                    user.photoURL != null
                      ? CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(user.photoURL!),
                          radius: 32,
                        )
                      : const Icon(Icons.account_circle, size: 64),
                    const SizedBox(height: 20),

                    //こんにちはのテキスト---------------------
                    //const Text('こんにちは'),
                    Text("${user.providerData[0].providerId}でログイン中"), //アドレス表示
                    Text("${user.email}"), //アドレス表示
                    const SizedBox(height: 20),

                    //familyId---------------------
                    //Text("familyId:${ref.read(familyIdProvider)}"), //アドレス表示
                    //Text("uid:${ref.read(userIdProvider)}"), //アドレス表示
                    //const SizedBox(height: 20),
                    //TextButton(//枠線なしボタン。リンクっぽい？
                      //onPressed: () { 
                        
                        //print("${user.uid}");
                        //showMessage("${user.uid}");
                        //User? user = auth
                       //},
                     // child: const Text('uid'),
                    //),
                    
                    

                    //ユーザー連携

                          customButton(
                            text: 'アプリ共有機能', 
                            fixedSize: const Size(220, 35),
                            onPressed: ()async{  

                              final data = await viewModel.fetchRequests();
                              final familyData =  await viewModel.fetchFamilies();
                              ref.read(familyDataProvider.notifier).state = familyData;
                              
                              if(data==null || data['status']=='no' || data['status']=='owner'){
                                //print("リクエストはありません。");
                                //print('');
                                //ref.read(pageIndexProvider.notifier).state = 5;
                                if(context.mounted){
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LinkUserView()),
                                );
                                }
                                

                              }else{
                                if(data['status']=='pending'){
                                  //print("リクエストが来ています。");
                               // print('');
                               if(context.mounted){
                                  final bool? result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => ConfirmDialog2(
                                    //context: context,
                                    message: "${dispMaskEmail(data['ownerEmail'])}さんから\nアプリ連携の招待が来ています。\n連携の招待を許可すると今までの貴方のデータは見えなくなります。\n許可しますか？",
                                  ),
                                );

                                if (result == true ) {
                                  await viewModel.acceptRequest(familyId: data['ownerId']);
                                  showMessage("アプリ連携しました。");

                                   //メニュー一覧にページ遷移
                                ref.read(pageIndexProvider.notifier).state = 0;
                                ref.read(menuToptabIndexProvider.notifier).state = 0;
                                if(context.mounted){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CommonScaffold()),
                                    (Route<dynamic> route) => false, // 条件を false にしてすべて削除
                                  );
                                }
                                
                                }else{

                                  await viewModel.noRequest(familyId: data['ownerId']);
                                  showMessage("アプリ連携はしませんでした。");
                                }
                               }

                               
                              }else{//accepted
                              //print("リクエストを承諾してます。");
                                //print('');
                                if (!context.mounted) return; // contextが無効なら何もしない
                              final bool? result = await showDialog<bool>(

                                context: context,
                                builder: (context) => ConfirmDialog1(
                                  //context: context,
                                  message: "アプリ連携の招待はオーナーの\n${dispMaskEmail(data['ownerEmail'])}\nに依頼してください。",
                                ),

                              );
                              if (result == true) {
                                
                              }

                              }
                        
                              }

                              
                              
                            }),  


                    //ログアウトボタン=============================
                    IconButton(
                      onPressed: () async {
                        await viewModel.signOut();
                        showMessage("ログアウトしました");

                      },
                      icon: const Icon(Icons.logout),
                    ),
                    const SizedBox(height: 40),

                    //アカウント削除ーーーーーーーーーーーーーーー
                    customButton(
                      text: 'アカウント削除', 
                      fixedSize: const Size(220, 35),
                      //backgroundColor: Colors.red,
                      onPressed: ()async{  
                        bool resultReLogin;

                        final bool? result = await showDialog<bool>(
                          context: context,
                          builder: (context) => const ConfirmDialog2(
                            message: 'アカウントを削除するとすべてのデータが消去されます。データは元には戻せません。削除しますか？',
                          ),
                        );
                        if (result == true) {
                          

                          //再認証
                        //if(!result){
                          if(user.providerData.first.providerId== 'password' && context.mounted){

                            //パスワード入力ダイアログ表示
                            showDialog(
                              context: context,
                              builder: (context) {

                                return Dialog(
                                  child: Container(
                                    constraints: const BoxConstraints.expand(width: 400, height: 300),//ダイアログウィンドウのサイズ
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        //題名************************************
                                        const Text("パスワードを入力してください",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                        const SizedBox(height:20),

                                        //メールアドレスの表示
                                        Text("${user.email}",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold )),
                                        const SizedBox(height:10),

                                        //パスワード入力フィールド
                                      textField(
                                        hintText: 'パスワード',
                                        controller: textControllers.passwordController,
                                        keyboardType: TextInputType.text,
                                        setWidth: 300,
                                        setHeight: 40,
                                        obscureText:true,//非表示
                                      ),
                                        //決定ボタン************************************
                                        const SizedBox(height: 16),
                                          customButton(
                                            text: '決定',
                                            onPressed: () async {
                                              resultReLogin = await viewModel.reLogin();
                                              if (resultReLogin){
                                                //ref.read(loadingFlgProvider.notifier).state = true;
                                                if(context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                                showMessage("アカウントを削除しました。");
                                                // キャッシュ破棄は UI のビルド後に行う（例：onPressed などで）
                                                Future.microtask(() {
                                                  //print("アカウント削除：メニューリポを初期化しました。");
                                                  ref.invalidate(menuRepositoryProvider);
                                                  ref.invalidate(ingRepositoryProvider);
                                                  ref.invalidate(dinnerRepositoryProvider);
                                                  
                                                });
                                                //削除処理
                                                //print("削除処理");
                                                await viewModel.deleteAllData(user);
                                                //print("削除終わり:$result");
                                                
                                                //ref.read(loadingFlgProvider.notifier).state = false;
                                                
                                              }else{

                                                if(context.mounted) {
                                                final bool? result = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => const ConfirmDialog1(
                                                    message: '再認証に失敗したため、まだアカウント削除できていません。正しいパスワードを入力してください。',
                                                  ),
                                                );
                                                if (result == true) {
                                                  //showMessage("よろしくです。");
                                                }
                                                }

                                              }
                                            },
                                          ),

                                          //やめる
                                          TextButton(//枠線なしボタン。リンクっぽい？
                                            onPressed: () { 
                                              if(context.mounted){
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text('やめる'),
                                          ),

                                      ])));
                                      });
                                      
                                      //外部アカウント認証
                                      }else{
                                        //print("google再認証");
                                        resultReLogin = await viewModel.reLogin();
                                        if (resultReLogin){
                                          showMessage("アカウントを削除しました。");
                                          //ref.read(loadingFlgProvider.notifier).state = true;
                                          // キャッシュ破棄は UI のビルド後に行う（例：onPressed などで）
                                          Future.microtask(() {
                                            //print("アカウント削除：メニューリポを初期化しました。");
                                            ref.invalidate(menuRepositoryProvider);
                                            ref.invalidate(ingRepositoryProvider);
                                            ref.invalidate(dinnerRepositoryProvider);
                                            
                                          });
                                          //削除処理
                                          //print("削除処理");
                                          await viewModel.deleteAllData(user);
                                          //print("削除終わり:$result");
                                          //ref.read(loadingFlgProvider.notifier).state = false;
                                          
                                          //if(context.mounted) {
                                            //Navigator.of(context).pop();
                                          //}
                                        }else{
                                          if(context.mounted) {
                                          final bool? result = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => const ConfirmDialog1(
                                              message: '再認証に失敗したため、まだアカウント削除できていません。再度アカウント削除ボタンを押してください。',
                                            ),
                                          );
                                          if (result == true) {
                                            //showMessage("よろしくです。");
                                          }
                                          }

                                        }
                                        

                                      }
                     
                        

                        
                        

                        

                          //再認証不要
                          //}else{
                            //showMessage("アカウントを削除しました。");
                            //print("アカウント削除しました。");
                          //}
          
                        }

                       


                    }),  



  ])),)]
    );}},
    loading: () => const SizedBox.shrink(),//const CircularProgressIndicator(),
    error: (error, stackTrace) => const Text('error'),
  ),

  //bottomNavigationBar: const CustomBottomBar(),
);}}