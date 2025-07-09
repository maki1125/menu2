
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/login/data/repository/auth_repository.dart';
import 'package:menu2/login/viewmodel/login_viewmodel.dart';
import 'package:menu2/login/data/model/login.dart';

//authリポジトリのプロバイダー======================================
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref));

//現在ユーザーの情報===============================================
final currentUserProvider = Provider<User?>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  User? currentUser = authRepo.getCurrentUser();
  return currentUser;
});


//ユーザー状態(ログインはUserインスタンス、ログアウトはnull)===============
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.authStateChanges();
});


// viewmodelの管理============================
final loginViewModelProvider = Provider((ref) => LoginViewModel(ref));


//テキストフィールド
final loginTextControllersProvider = Provider<LoginTextControllers>((ref) {
  final controllers = LoginTextControllers();
  ref.onDispose(() {
    controllers.dispose();
  });
  return controllers;
});


//ユーザーIDの非同期取得
//final userIdFutureProvider = FutureProvider<String?>((ref) async {
  //final authRepo = ref.read(authRepositoryProvider);
  //return authRepo.fetchUserId('uid0');
//});

//ユーザーID
//final userIdProvider = StateProvider<String?>((ref)=>null);

//linkuser状態
final linkFlgProvider = StateProvider<bool>((ref)=>false);

//ファミリーID
final familyIdProvider = StateProvider<String?>((ref)=>null);

//ファミリーデータ
final familyDataProvider = StateProvider<Map<String, dynamic>?>((ref)=>{});
