import Foundation
import Combine
import RakutenOneAuthCore


protocol IDTokenProvider
{
	func getToken(accessConfig: AccessConfig, completion: @escaping (Result<Token, Error>) -> Void)

	func getToken(audience: Audience, scopes: Set<AccessScope>, completion: @escaping (Result<Token, Error>) -> Void)

	// get RAE access token
	func getToken(scopes: Set<AccessScope>, completion: @escaping (Result<Token, Error>) -> Void)
}

final class IDSDKAccessTokenProvider: IDTokenProvider
{
	private struct Constant
	{
		static let evictionPolicy = 30
	}

	lazy var _idSDKSession = AppDelegate.resolver.resolve(IDSDKSessionManager.self)!
	var cache = [Audience: [Set<AccessScope>: Token]]()
	private let _tokenQueue = DispatchQueue(label: "jp.co.rakuten.link.token.queue", attributes: .concurrent)
	private var _cancelBag = Set<AnyCancellable>()


	init()
	{
		// Subscribe to logout event
		AppDelegate.authManager.didLogoutSubject.sink
		{
			[weak self] in

			self?.clearTokenCache()
		}.store(in: &_cancelBag)

		// Subscribe to session expiry event
		_idSDKSession.sessionExpiredSubject
			.filter { isExpired in isExpired }
			.debounce(for: .milliseconds(100), scheduler: _tokenQueue)
			.sink
		{
			[weak self] _ in

			self?.clearTokenCache()
		}.store(in: &_cancelBag)
	}


	func getToken(audience: Audience, scopes: Set<AccessScope>, completion: @escaping (Result<Token, Error>) -> Void)
	{
		if var tokens = cache[audience], let token = tokens[scopes]
		{
			if token.expiry > Date().addingTimeInterval(TimeInterval(Constant.evictionPolicy))
			{
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.fetchedTokenFromCache.rawValue)
				completion(.success(token))
				return
			}
			// token is expired
			self._tokenQueue.async(flags: .barrier)
			{
				Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.tokenExpired.rawValue)
				print(IDSDKCrashlyticsEnum.tokenExpired.rawValue)
				tokens[scopes] = nil
				self.cache[audience] = tokens
			}
		}
		let set = Set(scopes.map { $0.rawValue })
		if audience == .rae
		{
			_idSDKSession.getRAEToken(scopes: set)
			{
				[weak self] (result) in

				if case let .success(token) = result
				{
					self?._tokenQueue.async(flags: .barrier)
					{
						Log.info(category: LogCategory.IDSDK, IDSDKLoggingEnum.tokenStoredInCache.rawValue)
						print(IDSDKCrashlyticsEnum.tokenStoredInCache.rawValue)
						self?.cache[audience, default: [Set<AccessScope>: Token]()][scopes] = token
					}
				}
				completion(result)
			}
		}
		else
		{
			Log.error(category: LogCategory.IDSDK, "Not rae audience!")
		}
	}

	func getToken(scopes: Set<AccessScope>, completion: @escaping (Result<Token, Error>) -> Void)
	{
		getToken(audience: .rae, scopes: scopes, completion: completion)
	}

	func getToken(accessConfig: AccessConfig, completion: @escaping (Result<Token, Error>) -> Void)
	{
		let audience = accessConfig.audience
		let scopes = accessConfig.scopes
		getToken(audience: audience, scopes: scopes, completion: completion)
	}


	func clearTokenCache()
	{
		Log.info(category: LogCategory.IDSDK, "Clearing token cache")
		self._tokenQueue.async(flags: .barrier) { self.cache.removeAll() }
	}
}

// ----------------------------------------------------------------------------------------------------
// MARK: - Delegate Interface for Talk & OA
// ----------------------------------------------------------------------------------------------------

extension IDSDKAccessTokenProvider: TokenProviderAndSessionExpiryDelegate
{
	func fetchRAEToken(scopes: Set<String>, completion: @escaping (Result<String, Error>) -> Void)
	{
		let raeScopes = Set(scopes.compactMap { AccessScope(rawValue: $0) })
		getToken(scopes: raeScopes)
		{
			result in

			switch result
			{
				case .success(let token):
					completion(.success(token.token))
				case .failure(let error):
					// Session Expired?
					if error is InvalidSessionError
					{
						completion(.failure(IDSDKDelegateSessionError.invalidSession))
					}
					else if case IDSDKError.noSession = error
					{
						completion(.failure(IDSDKDelegateSessionError.invalidSession))
					}
					else
					{
						completion(.failure(error))
					}
			}
		}
	}


	func showSessionExpiryAlert()
	{
		Alert.sessionExpiredAlert()
	}
}
