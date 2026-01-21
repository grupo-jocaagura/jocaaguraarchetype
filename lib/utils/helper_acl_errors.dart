part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Factory helpers to build standardized ACL-related errors.
///
/// This class produces local (non-network) [ErrorItem] instances that can be
/// rendered by the UI in a consistent way.
class HelperAclErrors {
  static ErrorItem unauthorized({
    required String policyId,
    required String appName,
    String description = 'You are not authorized to perform this action.',
  }) {
    /// Builds an ACL "unauthorized" error for a given [policyId] and [appName].
    ///
    /// The returned error is deterministic and includes metadata:
    /// - `appName`
    /// - `policyId`
    return ErrorItem(
      title: 'Unauthorized',
      code: 'ACL.UNAUTHORIZED',
      description: description,
      meta: <String, dynamic>{
        'appName': appName,
        'policyId': policyId,
      },
      errorLevel: ErrorLevelEnum.severe,
    );
  }
}
