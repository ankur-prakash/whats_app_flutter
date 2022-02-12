/*
 * © Rakuten, Inc.
 */
#import <RAuthenticationCore/RAuthenticationDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Keychain persistence information for an @ref RAuthenticationAccount "account".
 *
 * @see RAuthenticationAccount::persistenceInformation
 * @class RAuthenticationAccountPersistenceInformation RAuthenticationAccountPersistenceInformation.h <RAuthentication/RAuthenticationAccountPersistenceInformation.h>
 * @ingroup RAuthenticationCore
 */
RAUTH_EXPORT @interface RAuthenticationAccountPersistenceInformation : NSObject<NSCopying>

/**
 * Keychain access group. If `nil`, the application's private
 * access group `<bundle seed id>.<main bundle identifier>` is used.
 */
@property (nonatomic, copy, nullable) NSString *accessGroup;

/**
 * Creation date, as set on the first time the account was saved.
 */
@property (nonatomic, copy, readonly, nullable) NSDate *creationDate;

/**
 * Last modification date, i.e.\ most recent date at which the account was updated.
 *
 * This information is provided so it can be presented to the user in an
 * @ref RAccountSelectionDialog "account selection dialog".
 */
@property (nonatomic, copy, readonly, nullable) NSDate *lastModificationDate;

/**
 * Bundle identifier of the application that updated this account last.
 */
@property (nonatomic, copy, readonly, nullable) NSString *bundleIdentifierOfLastApplication;

/**
 * Display name of the application that updated this account last.
 *
 * This information is provided so it can be presented to the user in an
 * @ref RAccountSelectionDialog "account selection dialog".
 */
@property (nonatomic, copy, readonly, nullable) NSString *displayNameOfLastApplication;
@end

NS_ASSUME_NONNULL_END
