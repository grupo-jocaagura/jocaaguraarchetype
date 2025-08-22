import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'pages/counter_page.dart';
import 'pages/home_guest_page.dart';
import 'pages/home_session_page.dart';
import 'pages/login_page.dart';
import 'pages/not_found_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/settings_page.dart';

PageRegistry buildExampleRegistry() {
  return PageRegistry.fromDefs(
    <PageDef>[
      PageDef(
        model: const PageModel(
          name: 'onboarding',
          segments: <String>['/onboarding'],
        ),
        builder: (BuildContext ctx, PageModel args) => const OnboardingPage(),
      ),
      PageDef(
        model: const PageModel(name: 'home', segments: <String>['/home']),
        builder: (BuildContext ctx, PageModel args) => const HomeGuestPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'homeSession',
          segments: <String>['/home-session'],
        ),
        builder: (BuildContext ctx, PageModel args) => const HomeSessionPage(),
      ),
      PageDef(
        model: const PageModel(name: 'counter', segments: <String>['/counter']),
        builder: (BuildContext ctx, PageModel args) => const CounterPage(),
      ),
      PageDef(
        model: const PageModel(name: 'login', segments: <String>['/login']),
        builder: (BuildContext ctx, PageModel args) => const LoginPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'settings',
          segments: <String>['/settings'],
        ),
        builder: (BuildContext ctx, PageModel args) => const SettingsPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'notFound',
          segments: <String>['/not-found'],
        ),
        builder: (BuildContext ctx, PageModel args) => const NotFoundPage(),
      ),
    ],
    notFoundBuilder: (BuildContext ctx, PageModel args) => const NotFoundPage(),
    defaultPage: const PageModel(
      name: 'notFound',
      segments: <String>['/not-found'],
    ),
  );
}
