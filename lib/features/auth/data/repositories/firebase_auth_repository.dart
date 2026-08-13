import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:parosis_sulama/core/config/google_auth_config.dart';
import 'package:parosis_sulama/core/result/result.dart';
import 'package:parosis_sulama/features/auth/domain/entities/auth_user.dart';
import 'package:parosis_sulama/features/auth/domain/repositories/auth_repository.dart';

final class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // iOS'ta `clientId` kod üzerinden verilmezse (ve Info.plist'te
    // `GIDClientID` yoksa, bkz. `ios/Runner/Info.plist`) initialize
    // başarısız olur. Android/web kendi client ID'sini google-services.json
    // / Firebase konsolündeki web istemcisinden otomatik çözer.
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    await _googleSignIn.initialize(
      clientId: isIos ? googleIosClientId : null,
      serverClientId: googleWebClientId.isEmpty ? null : googleWebClientId,
    );
    _googleInitialized = true;
  }

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<AuthUser> _loadOrCreateProfile(
    fb.User user, {
    String? fullName,
    String? tcKimlik,
    String? phone,
  }) async {
    final doc = await _profileDoc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return AuthUser(
        id: user.uid,
        fullName: data['fullName'] as String? ?? user.displayName ?? '',
        email: data['email'] as String? ?? user.email ?? '',
        phone: data['phone'] as String? ?? '',
      );
    }

    final resolvedFullName = fullName ?? user.displayName ?? '';
    final resolvedEmail = user.email ?? '';
    final resolvedPhone = phone ?? '';
    await _profileDoc(user.uid).set({
      'fullName': resolvedFullName,
      'email': resolvedEmail,
      'tcKimlik': tcKimlik ?? '',
      'phone': resolvedPhone,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return AuthUser(
      id: user.uid,
      fullName: resolvedFullName,
      email: resolvedEmail,
      phone: resolvedPhone,
    );
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadOrCreateProfile(user);
  }

  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return Result.error(Exception('Giriş başarısız oldu.'));
      return Result.ok(await _loadOrCreateProfile(user));
    } on fb.FirebaseAuthException catch (e) {
      return Result.error(Exception(_authErrorMessage(e)));
    }
  }

  @override
  Future<Result<AuthUser>> register({
    required String fullName,
    required String email,
    required String tcKimlik,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return Result.error(Exception('Kayıt başarısız oldu.'));
      await user.updateDisplayName(fullName);
      final profile = await _loadOrCreateProfile(
        user,
        fullName: fullName,
        tcKimlik: tcKimlik,
        phone: phone,
      );
      return Result.ok(profile);
    } on fb.FirebaseAuthException catch (e) {
      return Result.error(Exception(_authErrorMessage(e)));
    }
  }

  @override
  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      final fb.User? user;
      if (kIsWeb) {
        final credential = await _auth.signInWithPopup(fb.GoogleAuthProvider());
        user = credential.user;
      } else {
        await _ensureGoogleInitialized();
        final account = await _googleSignIn.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          return Result.error(Exception('Google girişi başarısız oldu.'));
        }
        final credential = await _auth.signInWithCredential(
          fb.GoogleAuthProvider.credential(idToken: idToken),
        );
        user = credential.user;
      }
      if (user == null)
        return Result.error(Exception('Google girişi başarısız oldu.'));
      return Result.ok(
        await _loadOrCreateProfile(user, fullName: user.displayName),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return Result.error(Exception('Google girişi iptal edildi.'));
      }
      return Result.error(
        Exception(
          'Google girişi henüz yapılandırılmadı. Lütfen daha sonra tekrar deneyin.',
        ),
      );
    } on fb.FirebaseAuthException catch (e) {
      return Result.error(Exception(_authErrorMessage(e)));
    }
  }

  @override
  Future<Result<bool>> sendPasswordResetLink({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Result.ok(true);
    } on fb.FirebaseAuthException catch (e) {
      return Result.error(Exception(_authErrorMessage(e)));
    }
  }

  @override
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return Result.error(Exception('Oturum açılmamış.'));
    }
    try {
      await user.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        ),
      );
      await user.updatePassword(newPassword);
      return const Result.ok(true);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code.toLowerCase() case 'wrong-password' || 'invalid-credential') {
        return Result.error(Exception('Mevcut şifreniz yanlış.'));
      }
      return Result.error(Exception(_authErrorMessage(e)));
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  String _authErrorMessage(fb.FirebaseAuthException e) => switch (e.code
      .toLowerCase()) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' => 'E-posta ya da şifre yanlış.',
    'email-already-in-use' => 'Bu e-posta adresi zaten kayıtlı.',
    'invalid-email' => 'Geçersiz e-posta adresi.',
    'weak-password' => 'Şifre çok zayıf.',
    'too-many-requests' =>
      'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.',
    'network-request-failed' => 'İnternet bağlantınızı kontrol edin.',
    'operation-not-allowed' =>
      'E-posta ile giriş şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
    _ => 'Bir hata oluştu. Lütfen tekrar deneyin.',
  };
}
