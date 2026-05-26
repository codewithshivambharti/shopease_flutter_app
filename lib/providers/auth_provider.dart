import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  User? _user;
  UserModel? _userModel;
  bool _loading = false;
  String? _error;

  User? get firebaseUser => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() { _auth.authStateChanges().listen(_onAuth); }

  Future<void> _onAuth(User? u) async {
    _user = u;
    if (u != null) await _fetchUser(u.uid);
    else _userModel = null;
    notifyListeners();
  }

  Future<void> _fetchUser(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) _userModel = UserModel.fromFirestore(doc);
    } catch (e) { debugPrint('fetch user: $e'); }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _loading = true; _error = null; notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _msg(e.code); return false;
    } finally { _loading = false; notifyListeners(); }
  }

  Future<bool> registerWithEmail({required String name, required String email, required String password, String? phone}) async {
    try {
      _loading = true; _error = null; notifyListeners();
      final c = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await c.user!.updateDisplayName(name);
      final u = UserModel(uid: c.user!.uid, name: name, email: email.trim(), phone: phone, createdAt: DateTime.now());
      await _db.collection(AppConstants.usersCollection).doc(c.user!.uid).set(u.toFirestore());
      _userModel = u;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _msg(e.code); return false;
    } finally { _loading = false; notifyListeners(); }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _loading = true; notifyListeners();
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) { return false; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  String _msg(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Account already exists.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      default: return 'Authentication failed. Try again.';
    }
  }
}
