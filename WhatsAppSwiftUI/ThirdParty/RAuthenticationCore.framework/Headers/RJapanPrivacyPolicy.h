/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @deprecated Do not use.
 *
 * Provides easy access to the current version of the [Rakuten Japan privacy policy](https://privacy.rakuten.co.jp/).
 *
 * This class is responsible for maintaining the @ref #latestVersion "latest version" of the policy, used
 * in other parts of the library (unless a different @ref #activeVersion "active version" is set).
 *
 * Whenever the version of the privacy policy is updated, a @ref #RJapanPrivacyPolicyUpdateNotification is
 * sent. For convenience, the `object` property of the `NSNotification` instance is the value of #latestVersion.
 *
 * @class RJapanPrivacyPolicy RJapanPrivacyPolicy.h <RAuthentication/RJapanPrivacyPolicy.h>
 * @ingroup RAuthenticationCore
 */
DEPRECATED_MSG_ATTRIBUTE("Do not use.")
RAUTH_EXPORT @interface RJapanPrivacyPolicy : NSObject

/**
 * @deprecated Do not use.
 *
 * Latest version of the [Rakuten Japan privacy policy](https://privacy.rakuten.co.jp/).
 *
 * This value is kept in sync with the value at https://privacy.rakuten.co.jp/date/generic.txt
 */
@property (class, nonatomic, copy, readonly) NSString *latestVersion DEPRECATED_MSG_ATTRIBUTE("Do not use.");

/**
 * @deprecated Do not use.
 *
 * Active version of the privacy policy to report when authenticating.
 *
 * A `nil` value resets it to #latestVersion.
 */
@property (class, nonatomic, copy, null_resettable) NSString *activeVersion DEPRECATED_MSG_ATTRIBUTE("Do not use.");
@end

/**
 * @deprecated Do not use.
 *
 * Name of the notification sent whenever the privacy policy version has changed.
 * The `object` property of the `NSNotification` instance is the value of RJapanPrivacyPolicy.latestVersion
 * @ingroup CoreConstants
 */
RAUTH_EXPORT NSString *const RJapanPrivacyPolicyUpdateNotification DEPRECATED_MSG_ATTRIBUTE("Do not use.");

NS_ASSUME_NONNULL_END
