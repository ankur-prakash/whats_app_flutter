/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@class RAuthenticationSettings, RAuthenticationToken, RAuthenticationAccountUserInformation;

NS_ASSUME_NONNULL_BEGIN

/**
 * Base class for authenticators.
 *
 * @see
 *  Concrete implementations:
 *  - @ref RAnonymousAuthenticator
 *  - @ref RJapanIchibaUserAuthenticator
 *
 * @class RAuthenticator RAuthenticator.h <RAuthentication/RAuthenticator.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticator : NSObject <NSCopying, NSSecureCoding>

/**
 * The @ref RAuthenticationSettings "authentication settings" used to build this instance.
 */
@property (copy, nonatomic, readonly) RAuthenticationSettings *settings;

/**
 * @name Using authenticators
 */

/**
 * Initialize an instance.
 *
 * @param settings The @ref RAuthenticationSettings "authentication settings" to use.
 * @return The receiver, or `nil` if an initialization error occurred.
 */
- (instancetype)initWithSettings:(RAuthenticationSettings *)settings RAUTH_DESIGNATED_INITIALIZER;

/**
 * Request a new @ref RAuthenticationAccount "account" matching the credentials provided by this authenticator.
 *
 * This invokes RAuthenticator::requestTokenWithCompletion: and
 * RAuthenticator::requestUserInformationWithToken:completion:, and creates an
 * @ref RAuthenticationAccount "account" accordingly.
 *
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 */
- (NSOperation *)loginWithCompletion:(rauthentication_account_completion_block_t)completion;

/**
 * Requested scopes.
 *
 * @note If a specific expiration scope is desired (e.g. `90days@Access`), its value should be added to this set.
 */
@property (copy, nonatomic, nullable) NSSet<NSString *> *requestedScopes;

/**
 * The service identifier to use for saving the generated account into the keychain.
 *
 * Defaults to @ref RAuthenticator::defaultServiceIdentifier, which is different for each subclass and might be `nil`.
 *
 * @note Setting this to `nil` means the account will never be automatically saved. This
 * is typically what developers are expected to do when the user ask not to be
 * remembered in the application's @ref RLoginDialog "login dialog", or when a temporary
 * access token is needed and acquired in the background.
 *
 * @warning This property bears no relation with RAE's `service_id` parameter.
 */
@property (copy, nonatomic, nullable) NSString *serviceIdentifier;

/**
 * Default service identifier for this this class.
 *
 * An array of available accounts for this class can be obtained by passing
 * this value to RAuthenticationAccount::loadAccountsWithService:error:.
 *
 * @warning This property bears no relation with RAE's `service_id` parameter.
 *
 * @return Keychain service for this authenticator class.
 */
+ (nullable NSString *)defaultServiceIdentifier RAUTH_NO_DISCARD;

/**
 * Scopes required for extending tokens.
 *
 * This returns the scopes that a token should contain in order to be able to get extended with
 * additional scopes. For RAE, this is typically `Promotion@Refresh`.
 */
+ (nullable NSSet<NSString *> *)scopesForPromotion RAUTH_NO_DISCARD;

/**
 * Checks whether the receiver is valid or not.
 *
 * For an authenticator to be valid, it must have a non-empty @ref RAuthenticator::requestedScopes "set of requested scopes"
 * and valid #settings. This definition is further refined by subclasses: RUserPasswordAuthenticator
 * requires a non-empty @ref RUserPasswordAuthenticator::username "username"
 * and @ref RUserPasswordAuthenticator::password "password".
 */
- (BOOL)isValid RAUTH_NO_DISCARD;

/**
 * Check whether another instance is equal to the receiver.
 *
 * @param other Another instance.
 * @return Whether the two instances are equal.
 */
- (BOOL)isEqualToAuthenticator:(RAuthenticator *)other RAUTH_NO_DISCARD;

/**
 * @name Subclassing
 * @protectedsection
 */

/**
 * Operation queue used by this authenticator.
 */
@property (copy, nonatomic, readonly) NSOperationQueue *operationQueue;

/**
 * Request a new token matching this authenticator's properties, as part of @ref RAuthenticator::loginWithCompletion:.
 *
 * @note This method should normally not be invoked directly, and is exposed for developers writing custom authenticator classes.
 *
 * @attention This method **must** be overloaded by subclasses.
 *
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 */
- (NSOperation *)requestTokenWithCompletion:(void(^)(RAuthenticationToken * __nullable token, NSError * __nullable error))completion;

/**
 * Request more information about the user, as part of @ref RAuthenticator::loginWithCompletion:.
 *
 * @note This method should normally not be invoked directly, and is exposed for developers writing custom authenticator classes.
 *
 * @attention This method **must** be overloaded by subclasses.
 *
 * @param token      The access token obtained using RAuthenticator::requestTokenWithCompletion:.
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 * @see RAuthenticator::loginWithCompletion:
 */
- (NSOperation *)requestUserInformationWithToken:(RAuthenticationToken *)token
                                      completion:(void(^)(RAuthenticationAccountUserInformation * __nullable name, NSError * __nullable error))completion;

/**
 * Request a tracking identifier for the user, as part of @ref RAuthenticator::loginWithCompletion:.
 *
 * @note This method should normally not be invoked directly, and is exposed for developers writing custom authenticator classes.
 *
 * @attention This method **must** be overloaded by subclasses.
 *
 * @param token      The access token obtained using RAuthenticator::requestTokenWithCompletion:.
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 * @see RAuthenticator::loginWithCompletion:
 */
- (NSOperation *)requestTrackingIdentifierWithToken:(RAuthenticationToken *)token
                                         completion:(void(^)(NSString * __nullable trackingIdentifier, NSError * __nullable error))completion;

/**
 * Revoke a token.
 *
 * @note This method should normally not be invoked directly, and is exposed for developers writing custom authenticator classes.
 *       To revoke an @ref RAuthenticationAccount "account" 's token, see RAuthenticationAccount::logoutWithSettings:options:completion:.
 *
 * @attention This method **must** be overloaded by subclasses.
 *
 * @param token      The access token obtained using RAuthenticator::requestTokenWithCompletion:.
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 */
- (NSOperation *)revokeToken:(RAuthenticationToken *)token
                  completion:(void(^)(NSError * __nullable error))completion;

/**
 * Refresh a token.
 *
 * @note This method should normally not be invoked directly, and is exposed for developers writing custom authenticator classes.
 *       To refresh an @ref RAuthenticationAccount "account" 's token, see RAuthenticationAccount::refreshTokenWithSettings:requestedScopes:completion:.
 *
 * @attention This method **must** be overloaded by subclasses.
 *
 * @param token      The access token obtained using RAuthenticator::requestTokenWithCompletion:.
 * @param scopes     The new scopes requested for the token.
 * @param completion Block to be invoked upon completion.
 * @return An operation.
 */
- (NSOperation *)refreshToken:(RAuthenticationToken *)token
                       scopes:(NSSet<NSString *> *)scopes
                   completion:(void(^)(NSError * __nullable error))completion;

#ifndef DOXYGEN
- (instancetype)init NS_UNAVAILABLE;
#endif
@end

NS_ASSUME_NONNULL_END
