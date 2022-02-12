import Foundation
import Combine


/// Allow you to listen to session expiry event
final class SessionExpirySubscriptionManager
{
    private(set) var _cancelBag = Set<AnyCancellable>()


    /// Call this method once in viewWillAppear to start
    func startSessionExpirySubscription(_ handler: @escaping (Bool) -> Void)
    {
        // Session Expired Subscription
        Log.info(LogCategory.SessionExpiry, "Start session expiry subscription")
        AppDelegate.idSDKSession.sessionExpiredSubject
            .receive(on: DispatchQueue.main)
            .sink
        {
            isExpired in

            Log.info(LogCategory.SessionExpiry, "Received session expiry event with isExpired: \(isExpired)")
            handler(isExpired)
        }.store(in: &_cancelBag)
    }


    /// Call this method in viewWillDisappear to cancel
    func cancelSubscription()
    {
        Log.info(LogCategory.SessionExpiry, "Cancel session expiry subscription")
        _cancelBag.removeAll()
    }
}
