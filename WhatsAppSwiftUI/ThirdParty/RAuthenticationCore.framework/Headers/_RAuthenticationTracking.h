/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, _RAuthenticationLoginMethod)
{
    _RAuthenticationLoginMethodUnknown = 0,
    _RAuthenticationLoginMethodManualPassword,
    _RAuthenticationLoginMethodOneTapSSO,
};

typedef NS_ENUM(NSInteger, _RAuthenticationTrackingVerificationResult)
{
    _RAuthenticationTrackingVerificationResultFingerprint = 0,
    _RAuthenticationTrackingVerificationResultFailed,
    _RAuthenticationTrackingVerificationResultPassword,
    _RAuthenticationTrackingVerificationResultCanceled,
};

RAUTH_EXPORT @interface _RAuthenticationTracking : NSObject

+ (void)broadcastUnknownLoginEventWithAccount:(RAuthenticationAccount *)account;
+ (void)broadcastManualPasswordLoginEventWithAccount:(RAuthenticationAccount *)account;
+ (void)broadcastOneTapSSOLoginEventWithAccount:(RAuthenticationAccount *)account;

+ (void)setLoginMethod:(_RAuthenticationLoginMethod)loginMethod;
+ (void)broadcastLoginEventWithAccount:(RAuthenticationAccount *)account;

+ (void)broadcastLoginFailureWithError:(NSError *)error;

+ (void)broadcastLocalLogoutEventWithAccount:(RAuthenticationAccount *)account;
+ (void)broadcastGlobalLogoutEventWithAccount:(RAuthenticationAccount *)account;

+ (void)broadcastStandardVerificationEvent;
+ (void)broadcastStartVerificationEvent;
+ (void)broadcastEndVerificationEventWithResult:(_RAuthenticationTrackingVerificationResult)result;

+ (void)broadcastHelpTappedWithClass:(Class)aClass;
+ (void)broadcastPrivacyPolicyTappedWithClass:(Class)aClass;
+ (void)broadcastForgotPasswordTappedWithClass:(Class)aClass;
+ (void)broadcastCreateAccountTappedWithClass:(Class)aClass;

+ (void)broadcastSSOCredentialFound:(NSString*)source;
+ (void)broadcastLoginCredentialFound:(NSString*)source;

@end

NS_ASSUME_NONNULL_END
