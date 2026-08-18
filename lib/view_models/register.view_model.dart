import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/alert.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:fuodz/widgets/bottomsheets/account_verification_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class RegisterViewModel extends MyBaseViewModel {
  //
  AuthRequest _authRequest = AuthRequest();
  // FirebaseAuth auth = FirebaseAuth.instance;
  //the textediting controllers
  TextEditingController nameTEC = new TextEditingController(
    text: !kReleaseMode ? "John Doe" : "",
  );
  TextEditingController emailTEC = new TextEditingController(
    text: !kReleaseMode ? "john@mail.com" : "",
  );
  TextEditingController phoneTEC = new TextEditingController(
    text: !kReleaseMode ? "557484181" : "",
  );
  TextEditingController passwordTEC = new TextEditingController(
    text: !kReleaseMode ? "password" : "",
  );
  TextEditingController referralCodeTEC = new TextEditingController();
  Country? selectedCountry;
  String? accountPhoneNumber;
  bool agreed = false;
  bool otpLogin = AppStrings.enableOTPLogin;

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    String countryCode = PhoneUtilService.countryCode ?? "us";
    this.selectedCountry = Country.parse(countryCode);
  }

  //
  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void processRegister() async {
    //
    accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
    //
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate() && agreed) {
      //
      if (AppStrings.isFirebaseOtp) {
        processFirebaseOTPVerification();
      } else if (AppStrings.isCustomOtp) {
        processCustomOTPVerification();
      } else {
        finishAccountRegistration();
      }
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusy(true);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        finishAccountRegistration();
      },
      verificationFailed: (FirebaseAuthException e) {
        setBusy(false);
        String msg = "Failed".tr();
        if (e.code == 'invalid-phone-number') {
          msg = "Invalid Phone Number".tr();
        } else {
          msg = e.message ?? "Failed".tr();
        }
        //
        AlertService.error(title: "Error".tr(), text: msg);
      },
      codeSent: (String verificationId, int? resendToken) async {
        setBusy(false);
        firebaseVerificationId = verificationId;
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setBusy(false);
        print("codeAutoRetrievalTimeout called");
      },
    );
  }

  processCustomOTPVerification() async {
    setBusy(true);
    try {
      await _authRequest.sendOTP(accountPhoneNumber!);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //
  void showVerificationEntry() async {
    //
    setBusy(false);
    //
    await viewContext.push(
      (context) => AccountVerificationEntry(
        vm: this,
        phone: accountPhoneNumber!,
        onSubmit: (smsCode) {
          //
          if (AppStrings.isFirebaseOtp) {
            verifyFirebaseOTP(smsCode);
          } else if (AppStrings.isCustomOtp) {
            verifyCustomOTP(smsCode);
          }

          viewContext.pop();
        },
        onResendCode:
            AppStrings.isCustomOtp
                ? () async {
                  try {
                    final response = await _authRequest.sendOTP(
                      accountPhoneNumber!,
                    );
                    toastSuccessful("${response.message}");
                  } catch (error) {
                    viewContext.showToast(msg: "$error", bgColor: Colors.red);
                  }
                }
                : () {},
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      await finishAccountRegistration();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);
    // Sign the user in (or link) with the credential
    try {
      await _authRequest.verifyOTP(accountPhoneNumber!, smsCode);
      await finishAccountRegistration();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  ///////
  ///
  Future<void> finishAccountRegistration() async {
    setBusy(true);

    final apiResponse = await _authRequest.registerRequest(
      name: nameTEC.text,
      email: emailTEC.text,
      phone: accountPhoneNumber!,
      countryCode: selectedCountry!.countryCode,
      password: passwordTEC.text,
      code: referralCodeTEC.text,
    );

    setBusy(false);

    try {
      if (apiResponse.hasError()) {
        //there was an error
        AlertService.error(
          title: "Registration Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        //everything works well
        //firebase auth
        final fbToken = apiResponse.body["fb_token"];
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        Navigator.of(
          viewContext,
        ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (_) => false);
      }
    } on FirebaseAuthException catch (error) {
      AlertService.error(title: "Login Failed".tr(), text: "${error.message}");
    } catch (error) {
      AlertService.error(
        title: "Login Failed".tr(),
        text: error is Map ? "${error['message'] ?? error}" : "$error",
      );
    }
  }

  void openLogin() async {
    viewContext.pop();
  }

  verifyRegistrationOTP(String text) {}
}
