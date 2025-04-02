import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_widget.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/common/common_constant.dart';
import 'package:menu2/user/view_model/user_view_model.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(child: MyApp()), //providerの範囲
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '節約レシピ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CommonScaffold(), //アプリ起動時に表示する最初の画面
    );
  }
}

//共通のボトムバー設定のため
class CommonScaffold extends ConsumerStatefulWidget {
  @override
  CommonScaffoldState createState() => CommonScaffoldState();
}

class CommonScaffoldState extends ConsumerState<CommonScaffold> {
  
  //userIdのセット
  @override
  void didChangeDependencies() {//ref.readが使用できる。

    super.didChangeDependencies();

    // 非同期処理をビルド後に実行する
    Future.microtask(() async {
      final fetchedUserId = await ref.read(userIdFutureProvider.future);
      ref.read(userIdProvider.notifier).state = fetchedUserId;
      print("main:$fetchedUserId");
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      appBar:AppBar(title: const Text("appbar")),
      body:pages[pageIndex],
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}



