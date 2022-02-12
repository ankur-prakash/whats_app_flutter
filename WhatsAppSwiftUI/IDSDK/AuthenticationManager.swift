import Foundation
import Combine


// --------------------------------------------------
// MARK: Enums
// --------------------------------------------------

enum RAuthenticationError: Error
{
	case accountNotFound
	case refreshTokenFailed
	case requestTokenFailed
	case accountPersistFailed
	case protectedDataNotAvailable
	case authenticationManagerNotAvailable
	case notLoggedIn
}


enum ClearPersonalDataStatus
{
	case cpdNotPossible
	case cpdSuccess
	case cpdFailed
}


/// This class will be taking care of login and logout flow.
/// Currently, it handles only logout flow.
class AuthenticationManager
{
	// --------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------

	private lazy var _cleanupDiscoveryDB: DiscoveryActions.CleanupDiscoveryDB = AppDelegate.resolver.resolve(DiscoveryActions.CleanupDiscoveryDB.self)!
	private let _idSDKSession: IDSDKSessionManager

	/// Subscribers can listen to didLogout event
	let didLogoutSubject = PassthroughSubject<Void, Never>()

	init(idSDKSession: IDSDKSessionManager = AppDelegate.idSDKSession)
	{
		_idSDKSession = idSDKSession
	}

	// --------------------------------------------------
	// MARK: Logics
	// --------------------------------------------------

	func logoutTalkAndIDSDK(_ completion: @escaping () -> Void)
	{
		DispatchQueue.main.async
		{
			print("AuthMng:logout")
			Log.debug(category: LogCategory.UserSDK, "Start logging out from Talk and SSO. Thread: \(Thread.current)")
			MavLoginManager.sharedInstance().checkLinkLogInStatus
			{
				[weak self] isTalkLoggedIn in

				guard let self = self else
				{
					print("AuthMng:logout:X")
					Log.debug(category: LogCategory.UserSDK, "logout failed - authenticationManagerNotAvailable. Thread: \(Thread.current)")
					DispatchQueue.main.async
					{
						completion()
					}
					return
				}
				print("AuthMng:talk:isLoggedin: \(isTalkLoggedIn)")
				Log.debug(category: LogCategory.UserSDK, "talk isLoggedin: \(isTalkLoggedIn). Thread: \(Thread.current)")
				if isTalkLoggedIn
				{
					print("AuthMng:talk:logout")
					Log.debug(category: LogCategory.UserSDK, "start talk logout. Thread: \(Thread.current)")
					MavLoginManager.sharedInstance().logout
					{
						print("AuthVC:sso:logout")
						Log.debug(category: LogCategory.UserSDK, "talk logged out, start sso logout. Thread: \(Thread.current)")
						self.unregisterPNPAndLogoutIDSDK
						{
							_ in

							print("AuthMng:logout:OK")
							Log.debug(category: LogCategory.UserSDK, "sso logged out. Thread: \(Thread.current)")
							completion()
						}
					}
				}
				else
				{
					print("AuthVC:sso:logout")
					Log.debug(category: LogCategory.UserSDK, "user is not logging in Talk, start sso logout. Thread: \(Thread.current)")
					self.unregisterPNPAndLogoutIDSDK
					{
						_ in

						print("AuthMng:logout:OK")
						Log.debug(category: LogCategory.UserSDK, "sso logged out. Thread: \(Thread.current)")
						completion()
					}
				}
			}
		}
	}


	func unregisterPNPAndLogoutIDSDK(_ completion: @escaping (Bool) -> Void)
	{
		let pushNotificationManager = AppDelegate.resolver.resolve(PushNotificationManager.self)!
		pushNotificationManager.unregisterFromRPush()
		{
			DispatchQueue.main.async
			{
				self._idSDKSession.logout
				{
					[weak self] in

					DispatchQueue.main.async
					{
						// clean session and db when logout
						print("AuthMng:ssoLogout:clean")
						Log.debug(category: LogCategory.UserSDK, "clean data")
						if let self = self
						{
							// Publish logout event to subscribers
							self.didLogoutSubject.send()
							mainStore.dispatch(self._cleanupDiscoveryDB.execute())
							//TODO: move this method out of this class
							// clean Braze notifications in Realm db
							let telemetry = AppDelegate.resolver.resolve(TelemetryProtocol.self)!
							telemetry.deleteAllBrazeNotifications()
						}
						mainStore.dispatch(UserStateProfileAction(isIDLiteUser: nil, userName: nil))
						HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
						mainStore.dispatch(RakutenServiceUserStateAction(rakutenServiceUserState: .loggedOut))
						let shared = AppDelegate.container.synchronize().resolve(AppDelegate.self)
						shared?.resetFlagsAfterLogout()
						completion(true)
					}
				}
			}
		}
	}


	func clearPersonalData(_ completion: @escaping (ClearPersonalDataStatus) -> Void)
	{
		DispatchQueue.main.async
		{
			MavLoginManager.sharedInstance().checkLinkLogInStatus
			{
				isTalkLoggedIn in

				print("AuthMng:CPD:isTalkLoggedIn \(isTalkLoggedIn)")
				if isTalkLoggedIn
				{
					Log.debug("Clear Personal Data: Starting")
					print("AuthMng:CPD:Starting")
					let authInteractor = OneLinkAssembler.getAuthInteractor()
					authInteractor.clearPersonalData(config: (false, false))
					{
						statusCode, error in

						Log.debug("Clear Personal Data Response: \(statusCode) - \(error?.localizedDescription ?? .Empty)")

						// Error
						if let error = error
						{
							print("AuthMng:CPD:Fail \(statusCode) - \(error.localizedDescription)")
							completion(.cpdFailed)
							return
						}

						// Success
						if statusCode == 200
						{
							print("AuthMng:CPD:Success")
							OneLinkAssembler.resetToDefault()
							completion(.cpdSuccess)
							return
						}

						// No response & error
						print("AuthMng:CPD:Unknown")
						completion(.cpdFailed)
					}
				}
				else
				{
					Log.warning("Can't clear personal data because talk isn't logged in.")
					print("AuthVC:CPD:NotAllow")
					completion(.cpdNotPossible)
				}
			}
		}
	}
}
