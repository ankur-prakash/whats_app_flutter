/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticator.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An authenticator class for Japan Ichiba users.
 *
 * This @ref RAuthenticator "authenticator" class can be used to authenticate a user
 * on the Japanese mall (Japan Ichiba). For Global ID, you need to create a custom authenticator.
 *
 * @class RJapanIchibaUserAuthenticator RJapanIchibaUserAuthenticator.h <RAuthentication/RJapanIchibaUserAuthenticator.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RJapanIchibaUserAuthenticator : RUserPasswordAuthenticator

/**
 * The value to use when requesting a token using RAE.
 * This is serialized as `service_id` when making the request.
 */
@property (copy, nonatomic, nullable) NSString *raeServiceIdentifier;
@end

NS_ASSUME_NONNULL_END
