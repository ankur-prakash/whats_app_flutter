/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticator.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An @ref RAuthenticator "authenticator" base class for user accounts.
 *
 * This base class provides a #username and a #password. For a concrete subclass,
 * see @ref RJapanIchibaUserAuthenticator.
 *
 * @class RUserPasswordAuthenticator RUserPasswordAuthenticator.h <RAuthentication/RUserPasswordAuthenticator.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RUserPasswordAuthenticator : RAuthenticator
/**
 * A user's username.
 */
@property (copy, nonatomic, nullable) NSString *username;

/**
 * A user's password.
 */
@property (copy, nonatomic, nullable) NSString *password;
@end

NS_ASSUME_NONNULL_END
