/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * User information for an @ref RAuthenticationAccount "account".
 *
 * @see RAuthenticationAccount::userInformation
 *
 * @class RAuthenticationAccountUserInformation RAuthenticationAccountUserInformation.h <RAuthentication/RAuthenticationAccountUserInformation.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticationAccountUserInformation : NSObject<NSCopying, NSSecureCoding>
/**
 * First name of the user.
 */
@property (nonatomic, copy, nullable) NSString *firstName;

/**
 * Middle name of the user.
 */
@property (nonatomic, copy, nullable) NSString *middleName;

/**
 * Last name of the user.
 */
@property (nonatomic, copy, nullable) NSString *lastName;

/**
 * Whether the user will first have to agree to some terms and conditions before the account is allowed
 * to be persisted. If set, RAuthenticationAccount::persist fails.
 *
 * This can be set by a custom auhenticator (e.g. Global ID, in response to the `is_first_time` JSON field),
 * so that the SDK doesn't try to automatically persist the account on a successful login.
 */
@property (nonatomic) BOOL shouldAgreeToTermsAndConditions;
@end

NS_ASSUME_NONNULL_END
