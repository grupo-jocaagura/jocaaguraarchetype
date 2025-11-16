part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class SessionPages {
  const SessionPages({
    required this.splash,
    required this.homePublic,
    required this.login,
    required this.homeAuthenticated,
    required this.sessionClosed,
    required this.authenticating,
    required this.sessionError,
  });
  final PageModel splash;
  final PageModel homePublic;
  final PageModel login;
  final PageModel homeAuthenticated;
  final PageModel sessionClosed;
  final PageModel authenticating;
  final PageModel sessionError;
}
