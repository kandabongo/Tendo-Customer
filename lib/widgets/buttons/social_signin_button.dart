import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

enum SocialSignInProvider { google, facebook, apple }

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.provider,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final SocialSignInProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.white30,
        highlightColor: Colors.white30,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(8), child: _icon),
              Flexible(
                child: Text(
                  _text.tr(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _textColor, fontSize: 14),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (provider) {
      case SocialSignInProvider.google:
        return Colors.white;
      case SocialSignInProvider.facebook:
        return const Color(0xFF1877F2);
      case SocialSignInProvider.apple:
        return Colors.black;
    }
  }

  Color get _textColor {
    switch (provider) {
      case SocialSignInProvider.google:
        return const Color.fromRGBO(0, 0, 0, 0.54);
      case SocialSignInProvider.facebook:
      case SocialSignInProvider.apple:
        return Colors.white;
    }
  }

  String get _text {
    switch (provider) {
      case SocialSignInProvider.google:
        return "Sign in with Google";
      case SocialSignInProvider.facebook:
        return "Sign in with Facebook";
      case SocialSignInProvider.apple:
        return "Sign in with Apple";
    }
  }

  Widget get _icon {
    switch (provider) {
      case SocialSignInProvider.google:
        return Image.asset(
          "assets/images/logos/google.png",
          height: 24,
          width: 24,
        );
      case SocialSignInProvider.facebook:
        return Image.asset(
          "assets/images/logos/facebook.png",
          height: 24,
          width: 24,
        );
      case SocialSignInProvider.apple:
        return const Icon(Icons.apple, color: Colors.white, size: 24);
    }
  }
}
