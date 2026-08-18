import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/view_models/login.view_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class SocialMediaLoginService {
  //

  //Google login
  Future<void> googleLogin(LoginViewModel model) async {
    model.setBusy(true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      // Optional: force account selection like your old disconnect()
      await googleSignIn.signOut();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw "Google authentication failed".tr();
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);

      try {
        final apiResponse = await model.authRequest.socialLogin(
          googleUser.email,
          idToken,
          "google",
        );

        if (apiResponse != null) {
          await model.handleDeviceLogin(apiResponse);
        } else {
          model.openRegister(
            email: googleUser.email,
            name: googleUser.displayName,
          );
        }
      } catch (error) {
        model.toastError("$error");
      }
    } on GoogleSignInException catch (error) {
      model.toastError(error.description ?? error.code.name);
    } on FirebaseAuthException catch (error) {
      model.toastError(error.message ?? "Firebase login failed");
    } catch (error) {
      model.toastError("$error");
    } finally {
      model.setBusy(false);
    }
  }

  //Facebook login
  void facebookLogin(LoginViewModel model) async {
    //
    AlertService.showLoading();
    //
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ["email", "public_profile"],
      );
      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          throw "Facebook login failed".tr();
        }
        try {
          // Create a credential from the access token
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(accessToken.tokenString);

          // Once signed in, return the UserCredential
          UserCredential userAccount = await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential);

          //
          final apiResponse = await model.authRequest.socialLogin(
            userAccount.user!.email!,
            accessToken.tokenString,
            "facebook",
          );
          //
          if (apiResponse != null) {
            await model.handleDeviceLogin(apiResponse);
          } else {
            AlertService.stopLoading();
            model.openRegister(
              email: userAccount.user!.email!,
              name: userAccount.user!.displayName ?? "",
            );
          }
        } on FirebaseAuthException catch (error) {
          AlertService.stopLoading();
          model.toastError("${error.message}");
        } catch (error) {
          AlertService.stopLoading();
          model.toastError("$error");
        }
      } else {
        print(result.status);
        print(result.message);
        AlertService.stopLoading();
        model.toastError("${result.message}");
      }
    } catch (error) {
      AlertService.stopLoading();
      model.toastError("$error");
    }
  }

  //apple login
  void appleLogin(LoginViewModel model) async {
    //
    AlertService.showLoading();
    try {
      //
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      //
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
        accessToken: credential.authorizationCode,
      );

      //
      UserCredential userAccount = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      // Sign the user in (or link) with the credential
      try {
        //
        final apiResponse = await model.authRequest.socialLogin(
          userAccount.user!.email ?? "",
          credential.identityToken,
          "apple",
          nonce: rawNonce,
          uid: userAccount.user?.uid,
        );
        //
        if (apiResponse != null) {
          await model.handleDeviceLogin(apiResponse);
        } else {
          AlertService.stopLoading();
          model.openRegister(
            email: userAccount.user!.email,
            name: userAccount.user!.displayName,
          );
        }
      } catch (error) {
        AlertService.stopLoading();
        model.toastError("$error");
      }
      //
    } on FirebaseAuthException catch (error) {
      print("Apple login: $error");
      AlertService.stopLoading();
      model.toastError("${error.message}");
    } catch (error) {
      AlertService.stopLoading();
      model.toastError("$error");
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
