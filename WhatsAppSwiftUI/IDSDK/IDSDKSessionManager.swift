import RakutenOneAuthClaims
import RakutenOneAuthCore
import RakutenOneAuthDeviceCheckAssertions
import RakutenOneAuthRAE
import Contacts
import Network
import AVFoundation
import Photos
import RAuthenticationCore
import Combine


class IDSDKSessionManager
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Constants
	// ----------------------------------------------------------------------------------------------------

	private struct Constant
	{
		static let clientID = "rmn_app_ios"
		static let stgIssuerURL = "https://stg.login.account.rakuten.com"
		static let prodIssuerURL = "https://login.account.rakuten.com"
		static let stgBaseURL = "https://stg.gateway-api.global.rakuten.com"
		static let prodBaseURL = "https://gateway-api.global.rakuten.com"
	}

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------

	private(set) var _session: Session?
	private(set) var _client: Client?

	/// Subscribe to this publisher to listen to session expired event
	private(set) var sessionExpiredSubject = CurrentValueSubject<Bool, Never>(false)
	var isSessionExpired: Bool { sessionExpiredSubject.value }

	private var _cancelBag = Set<AnyCancellable>()
	private let _issuerURL: String
	private let _baseURL: String
	private let _openIDScopes: Set<String> = Set(["openid", "profile", "email"])

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------

	init()
	{
		_issuerURL = App.isStagingBuild ? Constant.stgIssuerURL : Constant.prodIssuerURL
		_baseURL = App.isStagingBuild ? Constant.stgBaseURL : Constant.prodBaseURL

		NotificationCenter
			.Publisher(center: .default, name: UIApplication.didBecomeActiveNotification, object: nil)
			.receive(on: DispatchQueue.global())
			.debounce(for: .milliseconds(100), scheduler: DispatchQueue.global())
			.dropFirst()
			.sink
			{
				[weak self] _ in

				Log.info(category: LogCategory.IDSDK, "Validate session validity by fetching raeToken on didBecomeActiveNotification.")
				self?.getRAEToken(scopes: []) { _ in }	// Already in background thread
			}.store(in: &_cancelBag)

		sessionExpiredSubject
			.filter { $0 }
			.receive(on: DispatchQueue.main)
			.debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
			.sink
			{
				_ in

				Log.info(category: LogCategory.IDSDK, "Session Expired: User State Changed to sessionExpired")
				mainStore.dispatch(RakutenServiceUserStateAction(rakutenServiceUserState: .sessionExpired))
			}.store(in: &_cancelBag)
	}

	convenience init(session: Session? = nil, client: Client? = nil)
	{
		self.init()
		self._session = session
		self._client = client
	}

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Public Methods
	// ----------------------------------------------------------------------------------------------------

	func prepareClient(completion: @escaping () -> Void)
	{
		print(IDSDKCrashlyticsEnum.prepareClient.rawValue)
		guard let issuerURL = URL(string: _issuerURL) else { return }
		ServiceConfiguration.from(issuer: issuerURL)
		{
			[weak self] result in

			guard let self = self else { return }
			let serviceConfig: ServiceConfiguration
			switch result
			{
			case let .success(config):
				serviceConfig = config
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.serviceConfigurationLoadSuccess.rawValue)
				print(IDSDKCrashlyticsEnum.serviceConfigurationLoadSuccess.rawValue)
			case let .failure(error):
				Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.serviceConfigurationLoadError.rawValue) \(error)")
				print(IDSDKCrashlyticsEnum.serviceConfigurationLoadError.rawValue)
				self.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.serviceConfigurationLoadError.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)
				completion()
				return
			}

			if let client = try? DefaultClientBuilder()
				.set(clientId: Constant.clientID)
				.set(serviceConfiguration: serviceConfig)
				.set(securityPolicy: SecurityPolicyBuilder().disableUserPresence().build())
				.build()
			{
				self._client = client
				self.loadSession(completion: completion)
			}
		}
	}


	func login(on window: UIWindow, completion: @escaping (Error?) -> Void)
	{
		Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginStarted.rawValue)
		guard let client = _client else
		{
			Log.error(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginErrorNoClient.rawValue)
			completion(IDSDKError.idsdkClientNotFound)
			return
		}

		Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginSessionRequestBuilder.rawValue)
		let requestBuilder = SessionRequestBuilder()
			.set(scopes: _openIDScopes)
			.useDeviceCheckClientAssertions()

		Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginMediationOptionsBuilder.rawValue)
		let mediationOptionsBuilder = MediationOptionsBuilder()
			.set(presentationAnchorProvider: { window })

		Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginAboutToPresentWebUsrnmPasswdScrn.rawValue)
		print(IDSDKCrashlyticsEnum.loginStarted.rawValue)
		AppDelegate.idSDKRATManager.trackViewOSPermissionSignIn()
		client.session(request: requestBuilder.build(),
					   mediationOptions: mediationOptionsBuilder.build() // without mediationOptions causes error: The operation couldn’t be completed. (RakutenOneAuthCore.MediationRequiredError error 1.)
					   )
		{
			[weak self] result in

			guard let self = self else { return }
			switch result
			{
			case .success(let session):
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.loginSessionCreatedSuccessfully.rawValue)
				print(IDSDKCrashlyticsEnum.loginSessionCreatedSuccessfully.rawValue)
				self._session = session
				completion(nil)
			case .failure(let error):
				Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.failedToCreateLoginSession.rawValue) \(error.localizedDescription)")
				print(IDSDKCrashlyticsEnum.failedToCreateLoginSession.rawValue)
				self.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.failedToCreateLoginSession.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)
				completion(error)
			}
		}
	}


	func migration(username: String, password: String, completion: @escaping (Error?) -> Void)
	{
		guard mainStore.state.networkState.isInternetConnected else
		{
			completion(IDSDKError.noNetwork)
			return
		}
		guard let client = _client else
		{
			completion(IDSDKError.idsdkClientNotFound)
			return
		}

		do
		{
			Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.migrationSessionRequestBuilder.rawValue)
			let request = SessionRequestBuilder()
				.set(scopes: _openIDScopes)
				.set(legacyCredential: try LegacyCredentialBuilder()
						.set(userId: username)
						.set(password: password)
					.build())
				.build()

			Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.migrationMediationOptionsBuilder.rawValue)
			let mediationOptionsBuilder = MediationOptionsBuilder().set(requiredPrompts: [.none])
			Log.debug(category: LogCategory.IDSDK, IDSDKLoggingEnum.migrationAboutToPresentWebUnmPwdScn.rawValue)
			print(IDSDKCrashlyticsEnum.migrationStarted.rawValue)

			client.session(request: request,
						   mediationOptions: mediationOptionsBuilder.build())
			{
				[weak self] result in

				guard let self = self else { return }
				switch result
				{
				case .success(let session):
					self._session = session
					Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.migrationSessionCreatedSuccessfully.rawValue)
					print(IDSDKCrashlyticsEnum.migrationSessionCreatedSuccessfully.rawValue)
					completion(nil)
				case .failure(let error):
					Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.failedToCreateMigrationSession.rawValue) \(error.localizedDescription)")
					print(IDSDKCrashlyticsEnum.failedToCreateMigrationSession.rawValue)
					self.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.failedToCreateMigrationSession.rawValue, error: error)
					//Crashlytics.crashlytics().record(error: error)
					completion(error)
				}
			}
		}
		catch
		{
			Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.migrationLegacyCredentialBuilderError.rawValue) : \(error.localizedDescription)")
			completion(error)
		}
	}


	func logout(completion: @escaping () -> Void)
	{
		guard let session = _session else
		{
			Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.alreadyLoggedOut.rawValue)
			completion()
			return
		}

		Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.startingLogOut.rawValue)
		session.logout
		{
			[weak self] result in

			guard let self = self else { return }
			switch result
			{
			case .success:
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.logOutSuccess.rawValue)
				print(IDSDKCrashlyticsEnum.logOutSuccess.rawValue)
				self._session = nil
				UserDefaultsManager.hasEverLoggedInIDSDK = false
				// Session Expired? Reset session expiry
				self.sessionExpiredSubject.send(false)
			case .failure(let error):
				Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.logOutFailed.rawValue) \(error.fullErrorDescription)")
				print(IDSDKCrashlyticsEnum.logOutFailed.rawValue)
				self.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.logOutFailed.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)
			}

			completion()
		}
	}

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Tokens
	// ----------------------------------------------------------------------------------------------------

	func getRAEToken(scopes: Set<String>, completion: @escaping (Result<OneApp.Token, Error>) -> Void)
	{
		guard mainStore.state.networkState.isInternetConnected else
		{
			completion(.failure(IDSDKError.noNetwork))
			return
		}
		guard let session = _session else
		{
			// Session Expired?
			sessionExpiredSubject.send(true)
			completion(.failure(IDSDKError.noSession))
			return
		}
		do
		{
			let config = try RakutenOneAuthRAE.ConfigurationBuilder()
				.set(baseUrl: _baseURL)
				.set(service: Global.Auth.serviceID)
				.set(scope: scopes)
				.build()
			fetchAndConvertRAEAccessToken(session: session, config: config, scopes: scopes, completion: completion)
		}
		catch
		{
			Log.error("\(IDSDKLoggingEnum.fetchRAETokenError.rawValue) \(error.localizedDescription)")
			trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.fetchRAETokenError.rawValue, error: error)
			//Crashlytics.crashlytics().record(error: error)
			completion(.failure(error))
		}
	}


	func fetchRAEAccessToken(session: Session, config: Configuration, completion: @escaping (Result<String, Error>) -> Void)
	{
		Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.fetchRAEToken.rawValue)
		session.rae.accessToken(configuration: config)
		{
			[weak self] result in

			switch result
			{
			case .success(let token):
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.fetchRAETokenSuccess.rawValue)
				print(IDSDKCrashlyticsEnum.fetchRAETokenSuccess.rawValue)
				completion(.success(token.value))
			case .failure(let error):
				Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.fetchRAETokenError.rawValue) \(error.localizedDescription)")
				print(IDSDKCrashlyticsEnum.fetchRAETokenError.rawValue)
				self?.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.fetchRAETokenError.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)

				// Session Expired?
				if error is InvalidSessionError
				{
					self?.sessionExpiredSubject.send(true)
				}

				completion(.failure(error))
			}
		}
	}


	func fetchAndConvertRAEAccessToken(session: Session, config: Configuration, scopes: Set<String>, completion: @escaping (Result<OneApp.Token, Error>) -> Void)
	{
		Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.fetchAndConvertRAEToken.rawValue)
		session.rae.accessToken(configuration: config)
		{
			result in

			switch result
			{
			case .success(let token):
				let convertedToken = Token(token: token.value, expiry: token.validUntil, scopes: Set(scopes.compactMap({ AccessScope(rawValue: $0) })))
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.fetchAndConvertRAETokenSuccess.rawValue)
				print(IDSDKCrashlyticsEnum.fetchAndConvertRAETokenSuccess.rawValue)

				// Session Expired? Reset session expiry
				self.sessionExpiredSubject.send(false)

				completion(.success(convertedToken))
			case .failure(let error):
				Log.error("\(IDSDKLoggingEnum.fetchAndConvertRAETokenError.rawValue) : \(error.localizedDescription)")
				print(IDSDKCrashlyticsEnum.fetchAndConvertRAETokenError.rawValue)
				self.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.fetchAndConvertRAETokenError.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)

				// Session Expired?
				if error is InvalidSessionError
				{
					self.sessionExpiredSubject.send(true)
				}

				completion(.failure(error))
			}
		}
	}

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Utility
	// ----------------------------------------------------------------------------------------------------

	func isLoggedIn() -> Bool
	{
		return _session != nil
	}


	func loadSession(completion: @escaping () -> Void)
	{
		guard let client = _client else
		{
			completion()
			return
		}

		let sessionRequest = SessionRequestBuilder()
			.set(scopes: _openIDScopes)
			.build()

		client.session(request: sessionRequest, allowUserPresenceUI: false)
		{
			[weak self] result in

			switch result
			{
			case .success(let session):
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.loadSessionSuccess.rawValue)
				print(IDSDKCrashlyticsEnum.loadSessionSuccess.rawValue)
				self?._session = session
			case .failure(let error):
				Log.error(category: LogCategory.IDSDK, "\(IDSDKLoggingEnum.loadSessionError.rawValue) error: \(error)")
				print(IDSDKCrashlyticsEnum.loadSessionError.rawValue)
				self?.trackIDSDKSessionAnalytics(event: IDSDKCrashlyticsEnum.loadSessionError.rawValue, error: error)
				//Crashlytics.crashlytics().record(error: error)
				self?._session = nil
			}
			completion()
		}
	}


	func requestRaRzCookies(service: String, completion: @escaping (Result<ArtifactResponse, Error>) -> Void)
	{
		Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.requestRaRzCookies.rawValue)
		guard let session = _session else { return }

		Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.RaRzArtifactRequestBuilder.rawValue)
		if let request = try? ArtifactRequestBuilder()
			.set(specifications: RzCookieConfigurationBuilder().build(), RaCookieConfigurationBuilder().set(service: service).build())
			.build()
		{
			session.artifacts(request: request)
			{
				result in

				completion(result)
			}
		}
		else
		{
			Log.error(category: LogCategory.IDSDK, IDSDKLoggingEnum.RaRzArtifactRequestBuilderError.rawValue)
		}
	}
}


// MARK: - Service Logs
/// Uses Firebase Analytics to give better insights
extension IDSDKSessionManager
{
	func trackIDSDKSessionAnalytics(event: String, error: Error? = nil)
	{
		let analyticsParams = [
			"device_type": Device.version.rawValue,
			"app_version": UIApplication.appVersion,
			"ios_version": Device.iosVersion,
			"error": error?.localizedDescription ?? .Empty
		]
		Analytics.logEvent(event, parameters: analyticsParams)
	}
}
