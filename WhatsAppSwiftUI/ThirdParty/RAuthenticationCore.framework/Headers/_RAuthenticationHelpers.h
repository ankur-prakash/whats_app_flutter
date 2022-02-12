/*
 * © Rakuten, Inc.
 */
#ifndef __cplusplus

#import <RAuthenticationCore/RAuthenticationCore.h>
#import <RakutenEngineClient/RakutenEngineClient.h>
#import <RakutenMemberInformationClient/RakutenMemberInformationClient.h>
#import <RakutenIdInformationClient/RakutenIdInformationClient.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * The access group used to share accounts between Rakuten applications.
 */
RAUTH_EXPORT NSString *const _RAuthenticationSingleSignOnAccessGroup;

/*
 * Returns the application's name
 */
RAUTH_EXPORT NSString *_RAuthenticationApplicationName(void);

#pragma mark - Networking

@interface RETokenResult (RAuthentication)
// Converting to an RAuthenticationToken
- (void)_populateExistingToken:(RAuthenticationToken *)token;
- (RAuthenticationToken *)_convertedToken;

// Used by global ID
- (BOOL)_isFirstTime;
@end

/*
 * Internal API clients
 */
@protocol _RAuthenticationNetworkingClient<NSObject>
@required
+ (instancetype)with:(RAuthenticationSettings *)settings;
@end

RAUTH_EXPORT @interface _RAuthenticationEngineClient :                  REClient   <_RAuthenticationNetworkingClient> @end
RAUTH_EXPORT @interface _RAuthenticationMemberInformationClient :       RMIClient  <_RAuthenticationNetworkingClient> @end
RAUTH_EXPORT @interface _RAuthenticationIdInformationClient :           RIIClient  <_RAuthenticationNetworkingClient> @end

#pragma mark - Misc utilities

RAUTH_EXPORT void _RAuthenticationLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) RAUTH_NO_TAIL_CALL;

NS_INLINE void _RAuthenticationLogSuccessOrFailure(NSString *subject, NSError *__nullable error) {
    if (error) _RAuthenticationLog(@"☠️ %@ failed with error: %@ (reason: %@)!", subject, error.localizedDescription, error.localizedFailureReason);
    else       _RAuthenticationLog(@"✅ %@ completed successfully!", subject);
}

NS_INLINE NSString *_RAuthenticationSelectorString(NSObject *object, SEL selector)
{
    return [NSString stringWithFormat:@"[%@ %@]", object.class, NSStringFromSelector(selector)];
}

NS_INLINE BOOL _RAuthenticationShouldProceed(NSOperation *operation, NSError *__nullable error)
{
    if (!operation || operation.cancelled) {
        _RAuthenticationLog(@"⚠️ %@ operation was canceled by caller. If unintentional, it might be because you're not holding a strong reference to the object that owns the queue.", operation.name);
        return NO;
    }

    _RAuthenticationLogSuccessOrFailure(operation.name, error);
    return YES;
}

RAUTH_EXPORT NSBlockOperation *_RAuthenticationDispatchGroupOperation(dispatch_group_t group, dispatch_block_t __nullable completion);

NS_INLINE NSComparisonResult _RAuthenticationMRUAccountComparator(RAuthenticationAccount *a, RAuthenticationAccount *b)
{
    NSDate *aDate = a.persistenceInformation.lastModificationDate ?: a.persistenceInformation.creationDate,
           *bDate = b.persistenceInformation.lastModificationDate ?: b.persistenceInformation.creationDate;

    if (!aDate)      return NSOrderedAscending;
    else if (!bDate) return NSOrderedDescending;
    else             return [aDate compare:bDate];
}

NS_INLINE BOOL _RAuthenticationObjectsEqual(id __nullable a, id __nullable b)
{
    // Two objects are equal if their pointers are either both nil or both non-nil,
    // and, if the latter, -isEqual: returns `YES`.
    return !(!a^!b) && (!a || [b isEqual:a]);
}

RAUTH_EXPORT @interface _RAuthenticationAccessGroupHelper : NSObject
@property (class, nonatomic, readonly) BOOL shouldUseAccessGroups;

+ (nullable NSString *)fullyQualifiedDefaultKeychainAccessGroupWithError:(out NSError **)error;
+ (nullable NSString *)bundleSeedIdWithError:(out NSError **)error;
+ (nullable NSString *)fullyQualifiedAccessGroupWithCanonicalAccessGroup:(nullable NSString *)canonicalAccessGroup error:(out NSError **)error;
+ (nullable NSString *)canonicalAccessGroupWithFullyQualifiedAccessGroup:(nullable NSString *)fullyQualifiedAccessGroup error:(out NSError **)error;
+ (nullable NSString *)fullyQualifiedPrivateAccessGroupWithError:(out NSError **)error;
@end

#pragma mark Misc private declarations

@interface RAuthenticationAccountPersistenceInformation ()
@property (nonatomic, copy, nullable) NSDate   *creationDate;
@property (nonatomic, copy, nullable) NSDate   *lastModificationDate;
@property (nonatomic, copy, nullable) NSString *bundleIdentifierOfLastApplication;
@property (nonatomic, copy, nullable) NSString *displayNameOfLastApplication;
@end

#define RAUTH_INVALID_METHOD [self doesNotRecognizeSelector:_cmd]; __builtin_unreachable()

NS_ASSUME_NONNULL_END
#endif

