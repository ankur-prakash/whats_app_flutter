/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Encapsulates an OAuth token.
 *
 * @class RAuthenticationToken RAuthenticationToken.h <RAuthentication/RAuthenticationToken.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticationToken : NSObject <NSCopying, NSSecureCoding>

/**
 * Access token.
 */
@property (copy, nonatomic) NSString *accessToken;

/**
 * Refresh token.
 */
@property (copy, nonatomic, nullable) NSString *refreshToken;

/**
 * Expiration date.
 */
@property (copy, nonatomic) NSDate *expirationDate;

/**
 * Scopes.
 */
@property (copy, nonatomic) NSSet<NSString *> *scopes;

/**
 * Token type. In most cases it is `BEARER`.
 */
@property (copy, nonatomic) NSString *tokenType;

/**
 *  Check whether the receiver is valid or not, i.e.\ if it has an
 *  #accessToken and has not expired.
 */
- (BOOL)isValid RAUTH_NO_DISCARD;

/**
 * Check whether another instance is equal to the receiver.
 *
 * @param other Another instance.
 * @return Whether the two instances are equal.
 */
- (BOOL)isEqualToToken:(RAuthenticationToken *)other RAUTH_NO_DISCARD;

/**
 *  @deprecated This method always returns `nil`
 *
 *  @return `nil`
 */
+ (nullable RAuthenticationToken *)legacyStoredToken RAUTH_NO_DISCARD DEPRECATED_MSG_ATTRIBUTE("This method always returns `nil`");
@end

NS_ASSUME_NONNULL_END
