import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu2/ingredient/data/model/ingredient.dart';
import 'package:menu2/menu/data/model/menu.dart';
import 'package:menu2/menu/data/repository/menu_repository.dart';
import 'package:menu2/user/data/repository/user_repository.dart';

//ユーザーリポジトリのプロバイダー
final userRepoProvider = Provider<UserRepository>((ref){
  return UserRepository();
});

//ユーザーIDの非同期取得
final userIdFutureProvider = FutureProvider<String?>((ref) async {
  final userRepo = ref.read(userRepoProvider);
  return userRepo.fetchUserId('uid0');
});

//ユーザーID
final userIdProvider = StateProvider<String?>((ref)=>null);


