
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:menu2/common/common_constant.dart';
import 'package:menu2/common/common_providers.dart';
import 'package:menu2/login/data/repository/auth_repository.dart';
import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';


//各種処理
class LoginViewModel {

  final Ref ref;
  final AuthRepository authRepo;
  String errorMessage = ''; // エラーメッセージ

  LoginViewModel(this.ref)
  : authRepo = ref.read(authRepositoryProvider);
   
   //ログイン関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //匿名ログイン===============================================
  Future<void> signInAnony()async{
    //ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    ref.read(errorMessageProvider.notifier).state = '';
    try{

      //匿名ログイン処理
      //print("匿名ログインします。");
      await authRepo.signInAnony();
      await authRepo.reloadUser();
      await authRepo.addUsers();
      await authRepo.addFamilies();

      final user = authRepo.getCurrentUser();
      ref.read(familyIdProvider.notifier).state = user!.uid;//userIdを設定

    } on FirebaseAuthException catch (e){
      switch (e.code) {
        default:
          errorMessage = AuthErrorMessages.unknownError;
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage; 
    }
  }

  //googleログイン===================================================
  Future<bool> signInGoogle()async{
    ref.read(errorMessageProvider.notifier).state = '';
    ref.read(loadingFlgProvider.notifier).state = true;

    try{
      await authRepo.signInWithGoogle();
      return true;

    //例外時の処理
    } on FirebaseAuthException catch (e){
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = '無効な認証情報です';
        case 'requires-recent-login':
          errorMessage = '再度ログインしてください';
        default:
          errorMessage = 'エラーが発生しました';
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage; 
      return false;  

    //firebase以外の例外  
    }catch(e){
      switch (e) {
        case 'キャンセル':
          errorMessage = 'googleログインはキャンセルされました';
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage; 
      return false; 

    }finally{
      ref.read(loadingFlgProvider.notifier).state = false;
    }
  }

  //appleログイン===================================================
  Future<bool> signInApple()async{
    ref.read(errorMessageProvider.notifier).state = '';
    ref.read(loadingFlgProvider.notifier).state = true;

    try{
      //apple認証情報取得
      await authRepo.signInWithApple();
      return true;
    }on FirebaseAuthException catch (e){
     
        
          errorMessage = e.code;

      
      ref.read(errorMessageProvider.notifier).state = errorMessage; 
      return false; 
    
    //例外時の処理
    }catch(e){
      switch (e) {
        case 'キャンセル':
          errorMessage = 'Appleログインはキャンセルされました';
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage; 
      return false; 

    }finally{
      ref.read(loadingFlgProvider.notifier).state = false;
    }
  }
  

  //新規登録=============================================================
  Future<bool> singUpEmailAndPassword() async {
    ref.read(loadingFlgProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = '';
    try{
      await authRepo.singUpEmailAndPassword();
      return true;

    //firebaseの例外時の処理   
    } on FirebaseAuthException catch (e){
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'メールアドレスとして正しくない形式です';
        case 'email-already-in-use':
          errorMessage = 'そのアドレスは既に使用されています';
        case 'weak-password':
          errorMessage = 'パスワードは6文字以上で入力してください';
        default:
          errorMessage = 'エラーが発生しました';
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage;
      return false;
    }finally{
      ref.read(loadingFlgProvider.notifier).state = false;
    }
  }

   // サインイン（アドレス＋パスワード）===========================================
  Future<bool> signInEmailAndPassword() async {
    ref.read(loadingFlgProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = '';
    try{
      //サインイン処理
      await authRepo.signInEmailAndPassword();

      //サイン前にバッファをクリアしておく
      ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(ingRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(customMenuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(dinnerRepositoryProvider); //buffをクリアするためにキャッシュクリアする

      return true;

    }on FirebaseAuthException catch (e) {
      switch (e.code) {
        default:
          errorMessage = "メールアドレスかパスワードに\n間違いがあります";
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage;
      return false;
    }finally{
      ref.read(loadingFlgProvider.notifier).state = false;
    }
  }


  //サインアウト==========================================================
  Future<void> signOut()async{

    //ref.invalidate(userIdProvider);
    //ref.invalidate(familyIdProvider);
    //ref.invalidate(menusProvider); // 
    ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    ref.invalidate(ingRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    ref.invalidate(customMenuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    ref.invalidate(dinnerRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    await authRepo.signOut();
    
    
    //print("サインアウトしました。");
    //print('');
    //await signInAnony(); //サインアウト後したらmain画面でusernullの時匿名ログインの処理がある。
    //await setUserId();
  }

  // パスワードリセット======================================================
  Future<void> resetPassword() async {
    ref.read(loadingFlgProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = '';
    try{
      //パスワードリセット処理
      await authRepo.sendPasswordResetEmail();

      }on FirebaseAuthException catch (e) {
        switch (e.code) {
        case 'invalid-email':
          errorMessage = AuthErrorMessages.invalidEmail;
        case 'user-not-found':
          errorMessage = AuthErrorMessages.userNotFound;
        default:
          errorMessage = AuthErrorMessages.unknownError;
        }
        ref.read(errorMessageProvider.notifier).state = errorMessage;
      }finally{
        ref.read(loadingFlgProvider.notifier).state = false;
      }
  }
//Families関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //userIdの設定
  Future<void> setFamilyId()async{
    User? user = authRepo.getCurrentUser();
    if(user == null){
      await signInAnony();
      user = authRepo.getCurrentUser();
    }
    
    final data = await authRepo.fetchUser(user!.uid);
    if(data!=null){
      ref.read(familyIdProvider.notifier).state = data['familyId'];//userIdを設定
  }
  }

  //リクエストチェック
  Future<Map<String, dynamic>?> fetchFamilies() async{
    final data = await authRepo.fetchFamily();
    return data;
  }

//Requests関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //リクエスト追加
  Future<void> addRequests({required String targetEmail}) async{
    await authRepo.addRequests(targetEmail: targetEmail);

  }

  //リクエストチェック
  Future<Map<String, dynamic>?> fetchRequests() async{
    final user = authRepo.getCurrentUser();
    //final userData = await authRepo.fetchUser(user!.uid);
    final data = await authRepo.fetchRequests(user!.email!);
    //if(userData!['role']=='member'&& data!=null){
      //await authRepo.deleteRequests(userData['email']);//リクエストの削除
      //return null;
    //}
    return data;
  }

  //リクエスト提出前チェック※メンバーやファミリーのいる人にはリクエスト出せないようにする
  Future<bool> checkRequests(String email) async{
    //final user = authRepo.getCurrentUser();
    //final userData = await authRepo.fetchUser(user!.uid);
    final data = await authRepo.fetchRequests(email);
    if(data!=null){
      return false;
    }
    return true;
    
  }

  //リクエスト受諾
  Future<void> acceptRequest({required String familyId })async{

    ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
    final user = authRepo.getCurrentUser();
    final userData = await authRepo.fetchUser(user!.uid);
    await authRepo.updateStatusRequests(status: 'accepted');
    userData!['role']='member';
    userData['familyId']=familyId;
    await authRepo.updateUsers(user.uid, userData);
    await authRepo.joinFamilies(familyId: familyId,);
    ref.read(familyIdProvider.notifier).state = familyId;
    //print("招待を許可しました。");
    //print("uid:${ref.read(userIdProvider)}");
    //print("familyId:${ref.read(familyIdProvider)}");
    //print('');
    
  }
  
  //リクエスト拒否
  Future<void> noRequest({required String familyId })async{
    //ref.read(familyIdProvider.notifier).state = familyId;
    final user = authRepo.getCurrentUser();

    await authRepo.deleteRequests(user!.email!);//リクエスト削除して、次連携招待もらえるようにする。
    //await authRepo.updateStatusRequests(status: 'no');
    //await authRepo.updateFamilies(familyId: familyId);
    //print("招待を拒否しました。");
   // print("uid:${ref.read(userIdProvider)}");
    //print("familyId:${ref.read(familyIdProvider)}");
    //print('');
  }

//アカウント削除関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //全データ+アカウント削除削除処理。
  Future<bool> deleteAllData(User user)async{
    try{
      //final user = authRepo.getCurrentUser();
      final userData = await authRepo.fetchUser(user.uid);
      final familyData = await authRepo.fetchFamily();
      final familyId = userData!['familyId'];

      //print("familyDate:${familyData!['members']}");

      //まずユーザーアカウント削除。エラーが出た場合はそれ以降の処理を未実行で現状維持するため。
      //await authRepo.reauthenticateUser();//ログイン失敗の時は例外出力
      
      //print("user削除しました");
      //メンバーの場合の処理_=============================================
      if(userData['role']=="member"){
       //print("メンバーです");
        if(familyData!=null){
          //print("ファミリーデータあります");
          //メンバーが自分1人の場合、オーナーのリクエストデータを削除する。オーナーが他の人からリクエストもらえるようにするため。
          if(familyData['members'].length==1){
            //print("メンバーは1人です");
            final requestData = await authRepo.fetchRequests(user.email!);
            await authRepo.deleteRequests(requestData!['ownerEmail']);//ownerのリクエストの削除

          }
        }
        await authRepo.deleteRequests(userData['email']);//リクエストの削除
        await authRepo.deleteFamilies(user.uid);//ファミリーの削除
        await authRepo.leaveFamilies(user.uid, userData['email'], familyId);//所属ファミリーから抜ける
        await authRepo.deleteAllDate(user.uid);
        //await authRepo.deleteUsers();//ユーザーの削除とアカウントの削除
        return true;

      //ownerの場合の処理
      }else{
        //print("role:owner");
        //print("familyId:${userData['familyId']}");
        await authRepo.deleteRequests(user.email!);//自分のリクエストの削除
        
        
        //メンバーいない場合_============================================
        if(familyData!['members']==null || familyData['members'].isEmpty){
          //print("メンバーいない場合。");
          //await authRepo.deleteFamilies(familyId);//ファミリーの削除
          //print("deleteAllDate uid");
          await authRepo.deleteAllDate(user.uid);
          //print("deleteAllDate familyId");
          await authRepo.deleteAllDate(familyId);
          //await authRepo.deleteUsers();//ユーザーの削除とアカウントの削除
          return true;


        //メンバーがいる場合_===========================================
        }else{
          //familiesの更新
          //print("メンバーいる場合:${familyData['members']}");
          String newOwnerId = familyData['members'][0];
          String newOwnerEmail = familyData['membersEmail'][0];
          familyData['ownerId'] = newOwnerId;
          familyData['members'] = familyData['members'].sublist(1);
          familyData['membersEmail'] = familyData['membersEmail'].sublist(1);
          //print("メンバーいる場合:${familyData['membersEmail']}");
          await authRepo.updateFamilies(familyId, familyData);

          //newOwnerのfamilyRequestsの削除
           //メンバーが自分1人の場合、オーナーのリクエストデータを削除する。オーナーが他の人からリクエストもらえるようにするため。
          //print("members:${familyData['members'].length}");
          if(familyData['members'].length==0){
            //print("メンバーは1人です。");
            await authRepo.deleteRequests(newOwnerEmail);//リクエストの削除
          }else{
            //print("メンバーは複数です。");
            final familyRequestsData = await authRepo.fetchRequests(newOwnerEmail);
            //print("リクエストをフェッチしました");
            familyRequestsData!['ownerEmail']=newOwnerEmail;
            familyRequestsData['ownerId']=newOwnerId;
            familyRequestsData['status']='owner';
            familyRequestsData['targetEmail']=newOwnerEmail;
            await authRepo.updateRequests(familyRequestsData);
            //print("オーナーのリクエストを更新しました。");
          }
          

          //menberのfamilyRequestsの更新
          for (var email in familyData['membersEmail']) {
            final familyRequestsData = await authRepo.fetchRequests(email);
            //print("familyRequests:${familyRequestsData!['ownerEmail']}");
            //print("familyRequests:${familyRequestsData['targetEmail']}");
            familyRequestsData!['ownerEmail']=newOwnerEmail;
            familyRequestsData['ownerId']=newOwnerId;
            await authRepo.updateRequests(familyRequestsData);
            
          }

          //新しいオーナーのusersデータ更新
          //print("users更新：${newOwnerId}");
          final updateUserData = await authRepo.fetchUser(newOwnerId);
          //print("users更新：${updateUserData!['email']}");
          updateUserData!['role']='owner';
          await authRepo.updateUsers(newOwnerId, updateUserData);
          //print("updateserData:${updateUserData!['role']}");

          //不要なfamilyデータの削除
          if(user.uid != familyId){
            //print("ファミリーデータを削除します");
            authRepo.deleteAllDate(user.uid);
            //print("ファミリーデータ削除できました。");
          }

          //アカウントの削除
          //await authRepo.deleteUsers();//ユーザーの削除とアカウントの削除
          return true;
        } 
      }
    
    }catch (_) {
      return false;
      
    }finally{
      await authRepo.deleteUsers();//ユーザーの削除とアカウントの削除
    }
  }

  //アカウント再認証ユーザー削除
  Future<bool> reLogin()async{
    try{
    await authRepo.reauthenticateUser();//ログイン失敗の時は例外出力
    //await authRepo.deleteUsers();//ユーザーの削除とアカウントの削除
    //print("再認証でユーザーを削除しました。");
      //print('');
    return true;
    
    }catch (_) {
      return false;
      
    }
  }


}
