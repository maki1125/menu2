
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'package:menu2/login/viewmodel/login_provider.dart';
import 'package:menu2/menu/view_model/menu_provider.dart';
import 'package:menu2/ingredient/view_model/ingredient_provider.dart';
import 'package:menu2/plan/viewmodel/dinner_provider.dart';

// 認証サービス
class AuthRepository {

  final Ref ref;
  AuthRepository(this.ref);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  String errorMessage = ''; // エラーメッセージ
  AuthCredential? credential; //認証情報
  
  
  //ログイン関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  // 匿名ログイン=======================================
  Future<void> signInAnony() async {
    try {
      await _auth.signInAnonymously();
      await _auth.currentUser?.reload();

    } on FirebaseAuthException catch (_) {
      rethrow; //上位に例外をスロー
    }
  }

   //apple認証情報の取得=================================
  Future<void> signInWithApple() async {
    try {

      // セキュリティ強化のためのrawNonceを生成
      final rawNonce = generateNonce(); //ランダムな文字列の生成
      final hashedNonce = sha256ofString(rawNonce); //Appleに送る用のハッシュ値に変換

      //appleログイン画面表示。キャンセルしたら例外。
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce, // 🔐 nonceをApple側に渡す
      ); 

      // Firebase認証用のcredential作成（rawNonceも渡す）
      credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      //showMessage("credentialOK");

      //1回目ログイン
      if(appleCredential.email!=null){
        //showMessage("メールアドレスあるのでリンクします。");
        await _auth.currentUser!.linkWithCredential(credential!);
        //ユーザーデータの更新（1回目ログイン時必要）
        User? user = getCurrentUser();
        final userData = await fetchUser(user!.uid);
        userData!['role'] = 'owner';
        userData['email']=user.email;
        await updateUsers(user.uid, userData);

      //2回目ログイン
      }else{
        //showMessage("2回目のログインです。"); 

        try{
        await _auth.signInWithCredential(credential!);
        //showMessage("2回目ログインOK");
        //ユーザーデータ取得。ownerの状態で1回目（初回:）か2回目（一度アカウント削除後）か判断。
        final user = getCurrentUser(); //匿名からuidが変わる
        final data = await fetchUser(user!.uid);
        ref.read(familyIdProvider.notifier).state = data!['familyId'];//userIdを設定
        
        //サイン前にバッファをクリアしておく
        ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
        ref.invalidate(ingRepositoryProvider); //buffをクリアするためにキャッシュクリアする
        ref.invalidate(customMenuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
        ref.invalidate(dinnerRepositoryProvider); //buffをクリアするためにキャッシュクリアする
        
        //一度アカウント削除した場合。
        } catch(e){
         
          //ユーザーデータの更新（1回目ログイン時必要）
          addUsers();
          User? user = getCurrentUser();
          final userData = await fetchUser(user!.uid);
          final familyId = ref.read(familyIdProvider);
          userData!['role'] = 'owner';
          userData['email']=user.email;
          userData['familyId'] = familyId;
          await updateUsers(user.uid, userData);

          final familyData =  await fetchFamily();
          familyData!['ownerId']=user.uid;
          updateFamilies(familyId!, familyData);

          
        }

      }
    } catch (e) {
      //showMessage("credentialNG");
      throw 'キャンセル';//アカウント選択後にキャンセルした時

    }
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //google認証情報の取得=================================
  Future<void> signInWithGoogle() async{//viewmodelで認証結果によって処理をけるため結果を渡す
    try{
      // googleログイン画面表示。途中キャンセルしても例外は出力されない。credential=nullが返される。
      final GoogleSignInAccount? googleCredential = await GoogleSignIn().signIn();
      
      //キャンセルした場合
      if (googleCredential == null) {
        credential = null; 
        throw 'キャンセル';

      }else{

        //認証情報(credential)作成
        final GoogleSignInAuthentication googleAuth = await googleCredential.authentication;
        credential = GoogleAuthProvider.credential(// Firebase認証用のCredentialを作成
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {

          //1回目ログイン。リンク済みの時は例外になる。
          await _auth.currentUser!.linkWithCredential(credential!);

          //ユーザーデータの更新（1回目ログイン時必要）
          User? user = getCurrentUser();
          final userData = await fetchUser(user!.uid);
          userData!['role'] = 'owner';
          userData['email']=user.email;
          await updateUsers(user.uid, userData);

        } on FirebaseAuthException catch (_) {

          //2回目ログイン。
          try{
            //ログイン処理
            await _auth.signInWithCredential(credential!);

            //familyIDのセット（2回目以降ログイン時必要）
            final user = getCurrentUser();
            final data = await fetchUser(user!.uid);
            ref.read(familyIdProvider.notifier).state = data!['familyId'];//userIdを設定
            
            //サイン前にバッファをクリアしておく
            ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
            ref.invalidate(ingRepositoryProvider); //buffをクリアするためにキャッシュクリアする
            ref.invalidate(customMenuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
            ref.invalidate(dinnerRepositoryProvider); //buffをクリアするためにキャッシュクリアする
          
          }on FirebaseAuthException catch (_){
            rethrow; //上位に例外をスロー
          }
        }
      }
  }catch (e){
    throw 'キャンセル';//アカウント選択後にキャンセルした時
  }}

/*
  //外部の認証情報でログイン処理==========================================
  Future<void> signInCredential() async {
    showMessage("signInCredential開始");
    if(credential != null){
      showMessage("credentialは存在する");
      //if (credential?.providerId == 'google.com') {
        try {
        //匿名アカウントとのリンク処理。とりあえずリンクしておく。
        await _auth.currentUser!.linkWithCredential(credential!);
        showMessage("リンク");
      } on FirebaseAuthException catch (_) {
        //ログイン処理。すでにリンク済みである時,Googleアカウント情報でログインする
        await _auth.signInWithCredential(credential!);
        showMessage("リンク済み");
        print("リンク済み");
        rethrow;
      }finally{
        //await _auth.currentUser?.reload();
        //print('userリロードしました');

      }
      //}else if(credential?.providerId == 'apple.com'){
        
       // }
      }
      
    }
 */ 

  // サインアップ(新規登録　アドレス＋パスワード)============================
  Future<void> singUpEmailAndPassword() async {
    try {
      final textControls = ref.read(loginTextControllersProvider);

      // 匿名ログイン時に認証情報(credential)を作成
      AuthCredential credential = EmailAuthProvider.credential(
          email: textControls.emailController.text, 
          password: textControls.passwordController.text
      );

      // メール認証情報を匿名ユーザーにリンク
      await _auth.currentUser!.linkWithCredential(credential);

      //ユーザーデータの更新
      final user = getCurrentUser();
      final userData = await fetchUser(user!.uid);
      userData!['role'] = 'owner';
      userData['email']=user.email;
      await updateUsers(user.uid, userData);

    }on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  // サインイン（アドレス＋パスワード）======================================
  Future<void> signInEmailAndPassword() async {
    try {
      final textControls = ref.read(loginTextControllersProvider);
      await _auth.signInWithEmailAndPassword(
        email: textControls.emailController.text, 
        password: textControls.passwordController.text
      ); 

      //familyIDのセット（2回目以降ログイン時必要）
      final user = getCurrentUser();
      final data = await fetchUser(user!.uid);
      ref.read(familyIdProvider.notifier).state = data!['familyId'];//userIdを設定

       //サイン前にバッファをクリアしておく
      ref.invalidate(menuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(ingRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(customMenuRepositoryProvider); //buffをクリアするためにキャッシュクリアする
      ref.invalidate(dinnerRepositoryProvider); //buffをクリアするためにキャッシュクリアする

    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  // サインアウト=========================================================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // パスワードリセット===================================================
  Future<void> sendPasswordResetEmail() async {
    try {
      final textControls = ref.read(loginTextControllersProvider);
      await _auth.sendPasswordResetEmail(
        email: textControls.emailController.text, 
        ); 
    } on FirebaseAuthException catch (_) {
        rethrow;
    }
  }

//ユーザー状態関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //ユーザー状態
  Stream<User?> authStateChanges() => _auth.idTokenChanges();//_auth.authStateChanges();//ログアウトしたらnull。authStateChanges()はログインとログアウトだけを検知。匿名からの変化は検知しない。

  //現在ユーザーの取得
  User? getCurrentUser(){
    return _auth.currentUser;//サーバーアクセスはしていない。キャッシュされた情報。
  }

  //再取得
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();//サーバーアクセスしてユーザー情報を再取得。
    //print("reload:${_auth.currentUser}");
  }

//ユーザーデータ関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
    //usersコレクションにデータ追加
  //このメソッドは匿名ログインの状態で実行される
  Future<void> addUsers() async{
    final user = _auth.currentUser; 
    await db.collection('users').doc(user!.uid).set({
    'email': user.email,
    'role':'guest', //guest /owner /member
    'familyId': user.uid,
    'createAt':Timestamp.now()
  });
  }

    //usersコレクションのデータ更新
  //このメソッドはユーザー登録した時 or ユーザー連携した時に実行される
  Future<void> updateUsers(String uid, Map<String, dynamic> data) async{
    //final user = _auth.currentUser; 
    await db.collection('users').doc(uid).update(data);
  }

  //usersコレクションのチェック
  //ログインした時にfamilyIDを取得するためにusers情報を確認するためusers情報を取得
  /*使い方=========================================================================
  final data = await authRepo.fetchUser();
        if(data!=null){
          ref.read(familyIdProvider.notifier).state = data!['familyId'];//userIdを設定
        }
  ==================================================================================*/ 
   Future<Map<String, dynamic>?> fetchUser(String uid) async{
    //final user = _auth.currentUser; 
    //print("fetchUser:${user?.uid}");
    DocumentSnapshot doc = await db.collection('users').doc(uid).get();

    if(doc.exists){
      final data = doc.data() as Map<String, dynamic>;
      //print("users存在します:${data['role']}");
      return data;
    }else{
      return null;
      //print('users存在しない');


    }
    }

    

  //ユーザー削除
  Future<void> deleteUsers() async {
    try{
    final user = _auth.currentUser; 
    
    //アカウント削除
    
    //print("アカウント削除しました。");
    //userデータの削除（アカウント削除失敗の時は残る）
    await db
        .collection('users').doc(user!.uid)
        .delete();
    await user.delete();
    //print("ユーザーデータ削除しました");
    //print("(5)deleteUsers:${user.uid}");     
     }on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

//Families関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
//familiesコレクションにデータ追加
  //このメソッドは匿名ログインの状態で実行される
  Future<void> addFamilies() async{
    final user = _auth.currentUser; 
    await db.collection('families').doc(user!.uid).set({
    'ownerId': user.uid,
    'createAt':Timestamp.now()
  });
  }

Future<Map<String, dynamic>?> fetchFamily() async{
    //final user = _auth.currentUser; 
    final familyId = ref.read(familyIdProvider);
    //print("fetchFamily:${familyId}");
    DocumentSnapshot doc = await db.collection('families').doc(familyId).get();

    if(doc.exists){
      final data = doc.data() as Map<String, dynamic>;
      //print("family存在します");
      return data;
    }else{
      return null;
      //print('family存在しない');
      
    }
    }

            //familiesコレクションに加わる
  //オーナーからの招待を許可した時に実行するメソッド
     Future<void> updateFamilies(String familyId, Map<String, dynamic> data) async{
    //final user = _auth.currentUser; 
    await db.collection('families').doc(familyId).update(data); // 既存データを保持して更新
    }

    //families削除
  Future<void> deleteFamilies(String familyId) async {
    //final user = _auth.currentUser; 
    //print("(2)deleteFamilies:${user!.uid}");
    await db
        .collection('families').doc(familyId)
        .delete();
  }
  
    //familiesコレクションに加わる
  //オーナーからの招待を許可した時に実行するメソッド
     Future<void> joinFamilies({required String familyId}) async{
    final user = _auth.currentUser; 
    await db.collection('families').doc(familyId).update({
     'members': FieldValue.arrayUnion([user!.uid]), // email を追加します（重複は追加されません）。
     'membersEmail':FieldValue.arrayUnion([user.email]),// email を追加します（重複は追加されません）。
     
  }); // 既存データを保持して更新
    }

    //familiesコレクションの更新（自分のデータを削除）
  //アカウント削除時に実行するメソッド    
   Future<void> leaveFamilies(String uid, String email, String familyId) async{
    //final familyId = ref.read(familyIdProvider);
    //final user = _auth.currentUser; 
    //print("(3)leaveFamilies:${familyId}");
    await db.collection('families').doc(familyId).update({
      'members': FieldValue.arrayRemove([uid]),
      'membersEmail': FieldValue.arrayRemove([email]),
     
  }); // 既存データを保持して更新
    }

  
//Request関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
  //連携リクエスト
  //オーナーが連携リクエストを出すときに実行するメソッド
   Future<void> addRequests({required String targetEmail}) async{
    final user = _auth.currentUser; 
    final userData = await fetchUser(user!.uid);
    
    await db.collection('familyRequests').doc(targetEmail).set({
    'ownerId': userData!['familyId'] ,
    'ownerEmail': user.email,
    'targetEmail': targetEmail,
    'status': 'pending', //pending(許可)、accepted(共有受理)、no(共有却下)
    'createAt':Timestamp.now(),
    'familyId':ref.read(familyIdProvider)
  });
  //連携リクエストを出すownerも登録して、他の人から連携リクエストできないようにする
  await db.collection('familyRequests').doc(user.email).set({
    'ownerId': userData['familyId'] ,
    'ownerEmail': user.email,
    'targetEmail': user.email,
    'status': 'owner', //pending(許可)、accepted(共有受理)、no(共有却下),owner（所有者）
    'createAt':Timestamp.now(),
    'familyId':ref.read(familyIdProvider)
  });
  }

  //連携リクエストのチェック
  //オーナーが連携リクエストを出すときに実行するメソッド
   Future<Map<String, dynamic>?> fetchRequests(String email) async{
    //final user = _auth.currentUser; 
    DocumentSnapshot doc = await db.collection('familyRequests').doc(email).get();

    if(doc.exists){
      final data = doc.data() as Map<String, dynamic>;
      //("存在します:${data['status']}");
      return data;
    }else{
      return null;
      //print('存在しない');
    }
  }

  //連携リクエストの更新
  //オーナーからの招待を許可or却下した時に実行するメソッド
   Future<void> updateStatusRequests({required String status}) async{
    final user = _auth.currentUser; 
    await db.collection('familyRequests').doc(user!.email).update({
      'status':status
    });
  }

    //連携リクエストの更新
   Future<void> updateRequests(Map<String, dynamic> data) async{

    await db.collection('familyRequests').doc(data['targetEmail']).update(data);
  }


  //リクエスト削除
  Future<void> deleteRequests(String email) async {
    try {
    //final user = _auth.currentUser; 
    //print("(1)deleteRequests:${user!.email}");
    await db
        .collection('familyRequests').doc(email)
        .delete();
    }on FirebaseAuthException catch (_) {
      rethrow;
    }
  }



//アカウント削除関係＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊
   //再認証（メールアドレス or google)
  Future<void> reauthenticateUser() async {
  final user = _auth.currentUser; 

  if (user == null) throw Exception('ユーザーがログインしていません');

  final providerId = user.providerData.first.providerId;

  AuthCredential credential;

  if (providerId == 'password') {
    
    String password = ref.read(loginTextControllersProvider).passwordController.text;
    if(password==""){
      //print("パスワードが空欄");
      throw Exception('パスワードが空欄です。');
    }
    credential = EmailAuthProvider.credential(email: user.email!, password: password);
    //print("再認証しました。");
  } else if (providerId == 'google.com') {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Googleサインインに失敗しました');

    final googleAuth = await googleUser.authentication;

    credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }else if (providerId == 'apple.com') {
  // 🔐 再認証用に nonce を生成してハッシュ化
  final rawNonce = generateNonce();
  final hashedNonce = sha256ofString(rawNonce);

  // 🧑‍💻 Apple認証をリクエスト
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  // 🔑 Firebase用のOAuthCredentialを作成
  credential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
    accessToken: appleCredential.authorizationCode,
  );
  } else {
    throw Exception('未対応のプロバイダー: $providerId');
  }

  await user.reauthenticateWithCredential(credential);
  }


  // サブコレクションを削除する関数
  Future<void> deleteSubCollection(DocumentReference docRef, String subCollectionName) async {
    try{
    // サブコレクション内のドキュメントを取得
    CollectionReference subCollectionRef = docRef.collection(subCollectionName);
    QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();

    for (DocumentSnapshot subDoc in subCollectionSnapshot.docs) {
      await subDoc.reference.delete(); // サブコレクション内のドキュメントを削除
    }
    }catch(_){
    }
  }

  //アカウント削除に伴う画像の全削除
  Future<void> deleteAllImagesInFolder(String familyId) async {
    //final user = _auth.currentUser; 
    //print("画像削除familyId:${familyId}");
    try {
      final storageRef = FirebaseStorage.instance.ref("families/$familyId/images");

      //フォルダ内のすべてのファイルを取得
      final ListResult result = await storageRef.listAll();
      //print("result.items:${result.items.length}");
      //すべてのファイルを削除
      for (Reference fileRef in result.items) {
        //print("Deleted: ${fileRef.fullPath}");
        await fileRef.delete();
      }
      //print("画像削除しました");

    } 
    catch (_) {
      //print("画像削除例外発生");
    }
  }

  //アカウント削除＋データ全削除
  Future<void> deleteAllDate(String uid) async {
    //final user = _auth.currentUser; 

    // ユーザーIDに基づいてユーザーのドキュメントを取得
    DocumentReference familiesDocRef =
        FirebaseFirestore.instance.collection('families').doc(uid);
    //print("(4)deleteAllDate:${user.uid}");
    // サブコレクションがあれば、それを削除
    // 例: サブコレクション "posts" がある場合
    await deleteSubCollection(familiesDocRef, 'dinners'); // サブコレクションを削除
    await deleteSubCollection(familiesDocRef, 'ingredients'); // サブコレクションを削除
    await deleteSubCollection(familiesDocRef, 'menus'); // サブコレクションを削除
    await familiesDocRef.delete(); // ファミリーのドキュメントを削除
    await deleteAllImagesInFolder(uid);
    //firestorageの画像削除
    //await deleteAllImagesInFolder("users/${user.uid}/images");

  }




}