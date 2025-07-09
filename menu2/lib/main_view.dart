
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';


//共通のボトムバー設定のため
class CommonScaffold extends ConsumerStatefulWidget {
  const CommonScaffold({super.key});
  @override
  CommonScaffoldState createState() => CommonScaffoldState();
}

class CommonScaffoldState extends ConsumerState<CommonScaffold> {
  
  //familyIdのセット
  @override
  void didChangeDependencies() {//ref.readが使用できる。

    super.didChangeDependencies();

    // 非同期処理をビルド後に実行する
    Future.microtask(() async {
      //print("main_view_build後の処理");
      if(ref.read(familyIdProvider)==null){
        //familyIdの取得
        final viewmodel = ref.read(loginViewModelProvider);
        await viewmodel.setFamilyId();
      }
      //print("main familyId:${ref.read(familyIdProvider)}");
      //print("");
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("main_view_build");
    final viewmodel = ref.read(loginViewModelProvider);
    final userAsync = ref.watch(authStateProvider);
    final pageIndex = ref.watch(pageIndexProvider);
    

return userAsync.when(
  data: (user) {
    if (user == null) {
          //print("userはnullです。build後に匿名ログインします。");
          Future.microtask(() {//ビルド途中にプロバイダーの状態変更が起きないように。
        viewmodel.signInAnony();
      });
      //print("userがnullです。匿名ログインします。");
      //viewmodel.signInAnony();
      return const Scaffold(
      body: Center(
        child: Text(
          'ログアウト中...',//ログアウトから匿名ログイン中の表示
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ),
    );
    } else {
      //print("userはnullではないです。:${user.uid}_${user.isAnonymous}");
      
      return Scaffold(
appBar:CustomAppBar(title: appBarTitle[pageIndex]),
      body:
      //Expanded(
            //child:
      pages[pageIndex],//Navigator.pushでページ遷移すると右にスライドするような動きになるので、indexで素早い切り替えをしている。
      //),
  bottomNavigationBar: const CustomBottomBar(),
    );
    }
  },
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('エラー: $e'),
);
  }
}
/*
    final pageIndex = ref.watch(pageIndexProvider);
    final currentUser = ref.watch(currentUserProvider);//非同期のため、ログイン直後にcurrentUserがnullの状態で、匿名ログイン処理を実行してしまうため不可。streamを使用して処理する。
    final viewmodel = ref.read(loginViewModelProvider);
    

    if (currentUser == null) {
      print("userがnullです");
      viewmodel.signInAnony();
      print("匿名ログインしました");
  } else {
      print("ログイン状態:${currentUser.uid}_${currentUser.isAnonymous}");
  }
  
    return Scaffold(
appBar:CustomAppBar(title: appBarTitle[pageIndex]),
      body:
      //Expanded(
            //child:
      pages[pageIndex],
      //),
  bottomNavigationBar: const CustomBottomBar(),
    );


}
}
*/


