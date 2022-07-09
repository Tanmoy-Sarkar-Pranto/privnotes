// import 'package:test/test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:privnotes/services/auth/auth_exception.dart';
import 'package:privnotes/services/auth/auth_provider.dart';
import 'package:privnotes/services/auth/auth_user.dart';

void main() {
  group('Mock Authorization', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with',
        () => {expect(provider.isInitialized, false)});
    test("Can't logout if not initialized", () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(
        Duration(seconds: 2),
      ),
    );

    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(
        email: 'p@gmail.com',
        password: 'anypass',
      );
      expect(
        badEmailUser,
        throwsA(
          const TypeMatcher<UserNotFoundAuthException>(),
        ),
      );
      final badPass = provider.createUser(
        email: 'ptanmoysarkar@gmail.com',
        password: '1234',
      );
      expect(
        badPass,
        throwsA(
          const TypeMatcher<WrongPasswordAuthException>(),
        ),
      );
      final user = await provider.createUser(
        email: 'ptanmoy@gmail.com',
        password: 'asdf',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Looged in user should be able to verify', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log in and logout again', () {
      provider.logout();
      provider.login(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'p@gmail.com') throw UserNotFoundAuthException();
    if (password == '1234') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
