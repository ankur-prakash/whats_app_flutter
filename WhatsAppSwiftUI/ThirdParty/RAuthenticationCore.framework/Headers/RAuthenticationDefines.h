/*
 * © Rakuten, Inc.
 */
#import <Foundation/Foundation.h>
#import <Availability.h>

#ifdef __cplusplus
#   define RAUTH_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#   define RAUTH_EXPORT extern __attribute__((visibility ("default")))
#endif

#define RAUTH_NO_TAIL_CALL            __attribute__((not_tail_called))
#define RAUTH_NO_DISCARD              __attribute__((warn_unused_result))
#define RAUTH_SWIFT_NOTHROW           __attribute__((swift_error(none)))
#define RAUTH_DESIGNATED_INITIALIZER  __attribute__((objc_designated_initializer)) RAUTH_NO_DISCARD

