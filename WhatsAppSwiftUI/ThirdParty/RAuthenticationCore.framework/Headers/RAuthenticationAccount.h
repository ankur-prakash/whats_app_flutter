/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>
@class RAuthenticationAccount, RAuthenticationSettings, RAuthenticationAccountPersistenceInformation, RAuthenticationAccountUserInformation, RAuthenticationToken;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Defines a completion block for asynchronous methods that emit @ref RAuthenticationAccount "accounts".
 *
 *  @param account   An @ref RAuthenticationAccount "account".
 *  @param error     An `NSError` instance if any error occured, `nil` otherwise.
 *
 *  @ingroup CoreTypes
 */
typedef void (^rauthentication_account_completion_block_t)(RAuthenticationAccount * __nullable account, NSError * __nullable error);

/**
 *  @enum RAuthenticationLogoutOptions
 *  @ingroup CoreConstants
 */
typedef NS_OPTIONS(NSUInteger, RAuthenticationLogoutOptions)
{
    /**
     *  Invalidate the access token. This is the default when no option is passed.
     */
    RAuthenticationLogoutInvalidateAccessToken = 0,

    /**
     *  Delete the account from the keychain.
     */
    RAuthenticationLogoutDeleteAccount = 1UL << 0,

    /**
     *  Ask the server to revoke the access token.
     */
    RAuthenticationLogoutRevokeAccessToken = 1UL << 1,

    /**
     *  Combine all the options.
     */
    RAuthenticationLogoutCompletely = -1UL,
};

/**
 * Account, as stored in the keychain.
 *
 * @note This class is intended as a bridge between the application
 *       and the keychain, and thus does not conform to `NSCoding`. Please
 *       use either #persistWithError: or #unpersistWithError: for storing/deleting instances.
 *
 * @attention Most of the methods below manipulate the keychain in some way. Because we're using
 *            the `AccessibleWhenUnlockedThisDeviceOnly` security policy, they will fail if the
 *            device is currently locked. Additionally, [an Apple bug may also cause random falures when memory is too low for the security services to function properly](https://forums.developer.apple.com/message/9225).
 *
 * @class RAuthenticationAccount RAuthenticationAccount.h <RAuthentication/RAuthenticationAccount.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticationAccount : NSObject<NSCopying>

/**
 * Persistence information, if available.
 *
 * If the account was persisted into the keychain using #persistWithError:,
 * this contains keychain-related information. For accounts that have not been persisted
 * yet, this is either `nil` or used to specify an @ref RAuthenticationAccountPersistenceInformation::accessGroup "access group".
 */
@property (nonatomic, copy, nullable) RAuthenticationAccountPersistenceInformation *persistenceInformation;

/**
 * User information, if available.
 *
 * This is normally filled upon login by the @ref RAuthenticator "authenticator"
 * being used to generate the account, if it maps to a user (i.e.\ it is not
 * an @ref RAnonymousAuthenticator "anonymous authenticator").
 */
@property (nonatomic, copy, nullable) RAuthenticationAccountUserInformation *userInformation;

/**
 * Token, if available.
 *
 * This is normally filled upon login by the @ref RAuthenticator "authenticator"
 * being used to generate the account.
 */
@property (nonatomic, copy, nullable) RAuthenticationToken *token;

/**
 * Keychain service identifier used for persising the account.
 * This property **must** be set for #persistWithError: to succeed.
 *
 * @note An @ref RAuthenticator "authenticators" may set this to a default value. For
 *       instance, @ref RJapanIchibaUserAuthenticator
 *       sets this to the service identifier used for Single Sign-On by default.
 */
@property (nonatomic, copy, nullable) NSString *serviceIdentifier;

/**
 * Account name. This property **must** be set for #persistWithError: to succeed.
 *
 * This is normally filled upon login by the @ref RAuthenticator "authenticator"
 * being used to generate the account, if it maps to a user (i.e.\ it is not
 * an @ref RAnonymousAuthenticator "anonymous authenticator").
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 * Password for the account, if one was provided.
 *
 * This is normally filled upon login by the @ref RAuthenticator "authenticator"
 * being used to generate the account, if it maps to a user (i.e.\ it is not
 * an @ref RAnonymousAuthenticator "anonymous authenticator").
 */
@property (nonatomic, copy, nullable) NSString *password;

/**
 * Tracking identifier, if available.
 *
 * This is normally filled upon login by the @ref RAuthenticator "authenticator"
 * being used to generate the account, if it maps to a user (i.e.\ it is not
 * an @ref RAnonymousAuthenticator "anonymous authenticator").
 *
 * @attention For RAE authenticators, the application must have the `idinfo_read_encrypted_easyid`
 * scope for this to be filled automatically during login.
 */
@property (nonatomic, copy, nullable) NSString *trackingIdentifier;

/**
 * Class used to acquire the account in the first place, if an RAuthenticator was used.
 *
 * @note If not set, RAuthenticationAccount::refreshTokenWithSettings:requestedScopes:completion: will
 *       fail with an `RakutenAPIInvalidParameterError`.
 */
@property (nonatomic, nullable) Class authenticatorClass;

/**
 * Try to persist the account into the keychain.
 *
 * @param[out] error Pointer where the error should be stored.
 * @return Whether the call succeeded or not.
 */
- (BOOL)persistWithError:(out NSError**)error;

/**
 * Try to remove the account from the keychain. The account can still be used
 * for as long as you are holding a reference to it.
 *
 * @param[out] error Pointer where the error should be stored.
 * @return Whether the call succeeded or not.
 */
- (BOOL)unpersistWithError:(out NSError**)error;

/**
 *  Log the account out, optionally deleting it and revoking its token on the issuing server.
 *
 *  @note If #authenticatorClass is not set, this method will silently ignore the `RAuthenticationLogoutRevokeAccessToken`
 *        option.
 *
 *  @attention Deleting an account that was shared across applications deletes it in
 *             every applications. This effectively logs the associated user out of
 *             every application. For logging a user out of the current application only,
 *             developers only need to revoke the account's access token.
 *
 *  @param settings   The @ref RAuthenticationSettings "settings" to use.
 *  @param options    Logout options. Defaults to `RAuthenticationLogoutInvalidateAccessToken`.
 *  @param completion Block to be called upon completion.
 *
 *  @return An operation, or `nil` if `completion` was `nil` and assertions were disabled at build time.
 */
- (NSOperation *)logoutWithSettings:(RAuthenticationSettings *)settings
                            options:(RAuthenticationLogoutOptions)options
                         completion:(void (^)(NSError *))completion;

/**
 *  Refresh the account's token.
 *
 *  @param settings        The @ref RAuthenticationSettings "settings" to use.
 *  @param requestedScopes Developers can optionally pass a new set of scopes here, to replace
 *                         the current token's scopes with.
 *  @param completion      Block to be called upon completion.
 *
 *  @return An operation, or `nil` if `completion` was `nil` and assertions were disabled at build time.
 *
 *  @attention Requesting scopes that were not granted to the current token (i.e. extending the token scopes)
 *             may require the current token to have been granted special scopes. See RAuthenticator::scopesForPromotion
 *             for more information.
 */
- (NSOperation *)refreshTokenWithSettings:(RAuthenticationSettings *)settings
                          requestedScopes:(nullable NSSet<NSString *> *)requestedScopes
                               completion:(rauthentication_account_completion_block_t)completion;

/**
 * Try to delete a specific account.
 *
 * @note This does not revoke the account's token. For doing so, please refer
 *       to RAuthenticationAccount::logoutWithSettings:options:completion:.
 *
 * @param[in]  name        Account name.
 * @param[in]  service     Service identifier.
 * @param[in]  accessGroup If provided, will remove the account from a specific access group only.
 * @param[out] error       Pointer where the error should be stored.
 *
 * @return Whether the call succeeded or not.
 */
+ (BOOL)unpersistWithName:(NSString *)name
                  service:(NSString *)service
              accessGroup:(nullable NSString *)accessGroup
                    error:(out NSError **)error;

/**
 * Try to find a specific account.
 *
 * @param[in]  name     Account name.
 * @param[in]  service  Service identifier.
 * @param[out] error    Pointer where the error should be stored.
 *
 * @return Matching identity, or `nil` if none was found or an error occurred.
 */
+ (nullable instancetype)loadAccountWithName:(NSString *)name service:(NSString *)service error:(out NSError **)error RAUTH_NO_DISCARD RAUTH_SWIFT_NOTHROW;

/**
 * Retrieve accounts for the provided service.
 *
 * @param[in]  service  Service identifier.
 * @param[out] error    Pointer where the error should be stored.
 *
 * @return Accounts for the service, sorted from the most-recently to the least-recently updated, or `nil` if none was found or an error occurred.
 */
+ (nullable NSArray<RAuthenticationAccount *> *)loadAccountsWithService:(NSString *)service error:(out NSError **)error RAUTH_NO_DISCARD RAUTH_SWIFT_NOTHROW;

/**
 * Equality check.
 *
 * @param other  Other instance.
 *
 * @return Whether the receiver considers itself to be equal to the `other` instance.
 */
- (BOOL)isEqualToAccount:(RAuthenticationAccount *)other RAUTH_NO_DISCARD;

@end

NS_ASSUME_NONNULL_END
