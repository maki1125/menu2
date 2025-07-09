import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menu2/common/common_providers.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';


//データ登録制限チェック
bool limitCheck(Ref ref, List datalist){
  ref.read(errorMessageProvider.notifier).state = "";
  final user = ref.read(currentUserProvider);
  
  //匿名ログインの場合
  if(user!.isAnonymous && datalist.length>=10){
    ref.read(errorMessageProvider.notifier).state='ゲストユーザーの場合、10個までの保存です。ユーザー登録すると制限が解除されます。';
    return false;//保存の限界。
  }else{
    return true;//まだ保存できる。
  }
}

//マスクしたメールアドレスの表示
String dispMaskEmail(String email) {
  final parts = email.split('@');
  if (parts.isEmpty || parts[0].length < 5) return '***';
  return '${parts[0].substring(0, 5)}***';
  //return '${parts[0]}';
}