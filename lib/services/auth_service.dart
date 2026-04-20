import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/enums/perfil_usuario_enum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _loading = false;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // 🔹 GETTERS
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;

  // 🔹 PERFIL
  PerfilUsuarioEnum get perfil {
    try {
      final perfilString = _userData?['perfil'];

      if (perfilString == null) {
        return PerfilUsuarioEnum.MASTER;
      }

      return PerfilUsuarioEnum.values.byName(perfilString);
    } catch (e) {
      return PerfilUsuarioEnum.MASTER;
    }
  }

  bool get isAdmin => perfil == PerfilUsuarioEnum.MASTER;
  bool get isGerente =>
      perfil == PerfilUsuarioEnum.PLENO || isAdmin;

  // 🔥 CONTROLE DE PLANO (NOVO)
  bool get planoAtivo {
    final data = _userData?['dataExpiracao'];

    if (data == null) return false;

    final dataExp = DateTime.tryParse(data);
    if (dataExp == null) return false;

    return dataExp.isAfter(DateTime.now());
  }

  // 🔄 AUTH STATE
  Future<void> _onAuthStateChanged(User? user) async {
    _loading = true;
    notifyListeners();

    _user = user;

    if (user != null) {
      try {
        final doc = await _firestore
            .collection('tab_usuario')
            .doc(user.uid)
            .get();

        _userData = doc.data();
      } catch (e) {
        _userData = null;
      }
    } else {
      _userData = null;
    }

    _loading = false;
    notifyListeners();
  }

  // 🔐 LOGIN
  Future<void> login(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔑 PASSWORD RECOVERY
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }

  // 📱 PHONE AUTH (Note: This is more complex and usually requires a full verification flow)
  // For now, we'll implement a stub or a placeholder if the project uses a specific SMS provider.
  // Standard Firebase Phone Auth requires a verification ID and SMS code.
  Future<void> sendPasswordResetSms(String phone) async {
    // Placeholder for custom backend logic or Firebase Phone Auth
    // Firebase doesn't have a direct "reset password via SMS" like email.
    // Usually, you'd use Phone Auth to sign in and then let them change the password.
    throw UnimplementedError("Recuperação por SMS requer integração com Firebase Phone Auth ou Gateway de SMS.");
  }
}
