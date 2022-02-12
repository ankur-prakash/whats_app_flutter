/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Authentication settings.
 *
 * @class RAuthenticationSettings RAuthenticationSettings.h <RAuthentication/RAuthenticationSettings.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticationSettings : NSObject <NSCopying, NSSecureCoding>

/**
 * OAuth client identifier.
 */
@property (copy, nonatomic) NSString *clientId;

/**
 * OAuth client secret.
 */
@property (copy, nonatomic) NSString *clientSecret;

/**
 * Base URL for authentication requests.
 */
@property (copy, nonatomic) NSURL *baseURL;

/**
 * Idle timeout interval for RAE requests. Defaults to 60 seconds.
 */
@property (nonatomic) NSTimeInterval requestTimeoutInterval;

/**
 * Checks whether the receiver is valid or not.
 *
 * For the settings to be valid, #clientId, #clientSecret and #baseURL must be
 * provided, and #requestTimeoutInterval must be a positive value.
 */
- (BOOL)isValid RAUTH_NO_DISCARD;


/**
 * Check whether another instance is equal to the receiver.
 *
 * @param other Another instance.
 * @return Whether the two instances are equal.
 */
- (BOOL)isEqualToSettings:(RAuthenticationSettings *)other RAUTH_NO_DISCARD;

@end

NS_ASSUME_NONNULL_END
