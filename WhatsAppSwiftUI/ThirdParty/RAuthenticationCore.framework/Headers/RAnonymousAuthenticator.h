/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticator.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An anonymous authenticator, i.e.\ an authenticator with no associated user.
 *
 * Anonymous authenticators are to be used when an access token is required that
 * authenticates the application using its client id and client secret.
 *
 * @class RAnonymousAuthenticator RAnonymousAuthenticator.h <RAuthentication/RAnonymousAuthenticator.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAnonymousAuthenticator : RAuthenticator
@end

NS_ASSUME_NONNULL_END
