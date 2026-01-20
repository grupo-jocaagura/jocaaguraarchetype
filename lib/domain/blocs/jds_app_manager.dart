part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class JdsAppManager extends AppManager {
  JdsAppManager(
    super.config, {
    required this.unauthorizedErrorBuilder,
    super.onAppLifecycleChanged,
    super.env = defaultEnv,
  }) {
    _requireJdsReady();
  }
  final ErrorItem Function() unauthorizedErrorBuilder;
  BlocAcl get blocAcl => requireModuleOfType<BlocAcl>();
  BlocDesignSystem get blocDesignSystem =>
      requireModuleOfType<BlocDesignSystem>();

  /// Optional: call to validate JDS modules exist early (strict mode).
  void _requireJdsReady() {
    blocAcl;
    blocDesignSystem;
  }

  Future<void> pushWithAcl(
    PageModel page, {
    required String policyId,
    bool allowDuplicate = true,
    PageModel? forbiddenPage,
  }) async {
    final bool allowed = await blocAcl.canNavigateWithAcl(policyId);

    if (!allowed) {
      if (forbiddenPage != null) {
        pageManager.resetTo(forbiddenPage);
      }
      return;
    }

    pageManager.push(page, allowDuplicate: allowDuplicate);
  }

  Future<Either<ErrorItem, T>> executeWithAcl<T>({
    required String policyId,
    required Future<Either<ErrorItem, T>> Function() action,
  }) {
    return blocAcl.executeWithAcl(
      policyId: policyId,
      action: action,
      unauthorizedErrorBuilder: unauthorizedErrorBuilder,
    );
  }

  @override
  void handleLifecycle(AppLifecycleState state) {
    super.handleLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(blocAcl.refresh());
    }
  }
}
