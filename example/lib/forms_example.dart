import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Minimal example showcasing the OKANE-inspired FieldState form flow.
///
/// Run with:
/// ```sh
/// flutter run -t example/lib/forms_example.dart
/// ```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final _FormsExample bootstrap = _FormsExample();
  final AppManager manager = bootstrap.buildAppManager();

  runApp(
    JocaaguraApp(
      appManager: manager,
      registry: bootstrap.registry,
      seedInitialFromPageManager: true,
    ),
  );
}

class _FormsExample {
  _FormsExample();

  late final PageRegistry registry;
  late final PageManager _pageManager;
  late final DemoLoginFormBloc _loginBloc;

  AppManager buildAppManager() {
    _pageManager = PageManager(
      initial: NavStackModel.single(_EmailStepPage.pageModel),
    );
    _loginBloc = DemoLoginFormBloc();
    registry = _buildRegistry(_loginBloc);
    final BlocOnboarding onboarding = _buildOnboarding();

    return AppManager(
      AppConfig(
        blocTheme: _buildThemeBloc(),
        blocUserNotifications: BlocUserNotifications(),
        blocLoading: BlocLoading(),
        blocMainMenuDrawer: BlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: onboarding,
        pageManager: _pageManager,
        blocModuleList: <String, BlocModule>{
          DemoLoginFormBloc.name: _loginBloc,
        },
      ),
    );
  }

  PageRegistry _buildRegistry(DemoLoginFormBloc bloc) {
    return PageRegistry.fromDefs(
      <PageDef>[
        PageDef(
          model: _EmailStepPage.pageModel,
          builder: (_, __) => _EmailStepPage(bloc: bloc),
        ),
        PageDef(
          model: _PasswordStepPage.pageModel,
          builder: (_, __) => _PasswordStepPage(bloc: bloc),
        ),
        PageDef(
          model: _LoginOkPage.pageModel,
          builder: (_, __) => const _LoginOkPage(),
        ),
      ],
      defaultPage: _EmailStepPage.pageModel,
    );
  }

  BlocTheme _buildThemeBloc() {
    final RepositoryThemeReact repo = RepositoryThemeReactImpl(
      gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
    );
    return BlocThemeReact(
      themeUsecases: ThemeUsecases.fromRepo(repo),
      watchTheme: WatchTheme(repo),
    );
  }

  BlocOnboarding _buildOnboarding() {
    final BlocOnboarding onboarding = BlocOnboarding()
      ..configure(
        <OnboardingStep>[
          OnboardingStep(
            title: 'Init forms demo',
            description: 'Setting up reactive modules',
            onEnter: () async {
              return Right<ErrorItem, Unit>(Unit.value);
            },
            autoAdvanceAfter: const Duration(milliseconds: 200),
          ),
        ],
      );
    onboarding.start();
    return onboarding;
  }
}

class DemoLoginFormBloc extends BlocModule {
  static const String name = 'DemoLoginFormBloc';

  final BlocGeneral<ModelFieldState> _email =
      BlocGeneral<ModelFieldState>(const ModelFieldState());
  final BlocGeneral<ModelFieldState> _password =
      BlocGeneral<ModelFieldState>(const ModelFieldState());

  Stream<ModelFieldState> get emailStream => _email.stream;
  Stream<ModelFieldState> get passwordStream => _password.stream;

  ModelFieldState get email => _email.value;
  ModelFieldState get password => _password.value;

  void onEmailChangedAttempt(String raw) {
    final String trimmed = raw.trim();
    final bool looksValid = trimmed.contains('@') && trimmed.contains('.');
    _email.value = ModelFieldState(
      value: trimmed,
      isDirty: true,
      isValid: looksValid,
      errorText: looksValid ? '' : 'Ingrese un email válido',
    );
  }

  void onPasswordChangedAttempt(String raw) {
    final String value = raw;
    final bool valid = value.length >= 6;
    _password.value = ModelFieldState(
      value: value,
      isDirty: true,
      isValid: valid,
      errorText: valid ? '' : 'Mínimo 6 caracteres',
    );
  }

  bool get isValid =>
      email.isValid &&
      password.isValid &&
      !email.hasError &&
      !password.hasError;

  Future<Either<ErrorItem, Unit>> submit() async {
    onEmailChangedAttempt(email.value);
    onPasswordChangedAttempt(password.value);
    if (!isValid) {
      return Left<ErrorItem, Unit>(
        const ErrorItem(
          code: 'INVALID_FORM',
          title: 'Formulario inválido',
          description: 'Revise los campos e intente de nuevo',
        ),
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Right<ErrorItem, Unit>(Unit.value);
  }

  @override
  FutureOr<void> dispose() {
    _email.dispose();
    _password.dispose();
  }
}

class _EmailStepPage extends StatelessWidget {
  const _EmailStepPage({required this.bloc});

  final DemoLoginFormBloc bloc;

  static const PageModel pageModel = PageModel(
    name: 'forms_email',
    segments: <String>['forms_email'],
  );

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('Step 1 · Email')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<ModelFieldState>(
                stream: bloc.emailStream,
                initialData: bloc.email,
                builder: (_, __) {
                  final ModelFieldState field = bloc.email;
                  return JocaaguraAutocompleteInputWidget(
                    label: 'Email',
                    placeholder: 'person@example.com',
                    value: field.value,
                    errorText: field.errorText.isEmpty ? null : field.errorText,
                    textInputType: TextInputType.emailAddress,
                    icondata: Icons.email_outlined,
                    onChangedAttempt: bloc.onEmailChangedAttempt,
                    onSubmittedAttempt: (_) => _goNext(context),
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _goNext(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goNext(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    bloc.onEmailChangedAttempt(bloc.email.value);
    final bool validEmail = !bloc.email.hasError && bloc.email.value.isNotEmpty;
    if (!validEmail) {
      app.notifications.showToast('Completa un email válido');
      return;
    }
    app.pageManager.push(_PasswordStepPage.pageModel);
  }
}

class _PasswordStepPage extends StatelessWidget {
  const _PasswordStepPage({required this.bloc});

  final DemoLoginFormBloc bloc;

  static const PageModel pageModel = PageModel(
    name: 'forms_password',
    segments: <String>['forms_password'],
  );

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('Step 2 · Password')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<ModelFieldState>(
                stream: bloc.passwordStream,
                initialData: bloc.password,
                builder: (_, __) {
                  final ModelFieldState field = bloc.password;
                  return JocaaguraAutocompleteInputWidget(
                    label: 'Password',
                    placeholder: '******',
                    value: field.value,
                    errorText: field.errorText.isEmpty ? null : field.errorText,
                    obscureText: true,
                    icondata: Icons.lock_outline,
                    onChangedAttempt: bloc.onPasswordChangedAttempt,
                    onSubmittedAttempt: (_) => _handleSubmit(context),
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _handleSubmit(context),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final AbstractAppManager app = context.appManager;
    final Either<ErrorItem, Unit> result = await bloc.submit();
    result.fold(
      (ErrorItem error) => app.notifications.showToast(error.title),
      (_) {
        app.notifications.showToast('Login OK');
        app.pageManager.push(_LoginOkPage.pageModel);
      },
    );
  }
}

class _LoginOkPage extends StatelessWidget {
  const _LoginOkPage();

  static const PageModel pageModel = PageModel(
    name: 'forms_success',
    segments: <String>['forms_success'],
  );

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('Login Success')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text('¡Credenciales válidas!'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  context.appManager.pageManager
                      .resetTo(_EmailStepPage.pageModel);
                },
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
