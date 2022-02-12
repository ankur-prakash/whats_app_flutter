import Foundation


///
/// Provides all unique tracking identifiers for IDSDK logging
///
enum IDSDKLoggingEnum: String
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAccessTokenProvider Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case fetchedTokenFromCache					=	"FetchedTokenFromCache"
	case tokenExpired							=	"TokenExpired"
	case tokenStoredInCache						=	"TokenStoredInCache"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case loadSessionSuccess						=	"LoadSessionSuccess"
	case loadSessionError						=	"LoadSessionError"
	case serviceConfigurationLoadSuccess		=	"ServiceConfigurationLoadSuccess"
	case serviceConfigurationLoadError			=	"ServiceConfigurationLoadError"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession Login Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case loginStarted							=	"LoginStarted"
	case loginErrorNoClient						=	"LoginErrorNoClient"
	case loginSessionRequestBuilder				=	"LoginSessionRequestBuilder"
	case loginMediationOptionsBuilder			=	"LoginMediationOptionsBuilder"
	case loginAboutToPresentWebUsrnmPasswdScrn	=	"LoginAboutToPresentWebUsernamePasswordScreen"
	case loginSessionCreatedSuccessfully		=	"LoginSessionCreatedSuccessfully"
	case configurationBuilderError				=	"ConfigurationBuilderError"
	case failedToCreateLoginSession				=	"FailedToCreateLoginSession"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession Migration Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case migrationSessionRequestBuilder			=	"MigrationSessionRequestBuilder"
	case migrationMediationOptionsBuilder		=	"MigrationMediationOptionsBuilder"
	case migrationAboutToPresentWebUnmPwdScn	=	"MigrationAboutToPresentWebUsernamePasswordScreen"
	case migrationSessionCreatedSuccessfully	=	"MigrationSessionCreatedSuccessfully"
	case migrationUsername						=	"MigrationUsername"
	case migrationConfigurationBuilder			=	"MigrationConfigurationBuilder"
	case failedToCreateMigrationSession			=	"FailedToCreateMigrationSession"
	case migrationLegacyCredentialBuilderError	=	"MigrationLegacyCredentialBuilderError"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession RAE Token Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case fetchRAEToken							=	"FetchRAEToken"
	case fetchRAETokenSuccess					=	"FetchRAETokenSuccess"
	case fetchRAETokenError						=	"FetchRAETokenError"
	case fetchAndConvertRAEToken				=	"FetchAndConvertRAEToken"
	case fetchAndConvertRAETokenSuccess			=	"FetchAndConvertRAETokenSuccess"
	case fetchAndConvertRAETokenError			=	"FetchAndConvertRAETokenError"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession RaRz Cookies Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case requestRaRzCookies						=	"RequestRaRzCookies"
	case RaRzArtifactRequestBuilder				=	"RaRzArtifactRequestBuilder"
	case RaRzArtifactRequestBuilderError		=	"RaRzArtifactRequestBuilderError"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession Logout Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case alreadyLoggedOut						=	"AlreadyLoggedOut"
	case startingLogOut							=	"StartingLogOut"
	case logOutSuccess							=	"LogOutSuccess"
	case logOutFailed							=	"LogOutFailed"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case viewDidLoad 							= 	"ViewDidLoad"
	case proceedToLoginBtnTapped 				= 	"ProceedToLoginBtnTapped"
	case windowNotFound							=	"WindowNotFound"
	case clientReady 							= 	"ClientReady"
	case authenticationCompletionNotfound 		= 	"AuthenticationCompletionNotfound"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController start functionality Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case isTalkLoggedIn							= 	"isTalkLoggedIn"
	case localSessionExists						= 	"LocalSessionExists"
	case reloginWithLocalSession				= 	"ReloginWithLocalSession"
	case localSessionExistsLoginError			=	"LocalSessionExistsLoginError"
	case localSessionDoesNotExists				=	"LocalSessionDoesNotExists"
	case localSessionExpired					=	"LocalSessionExpired"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController loginIDSDKAndTalk Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case startLoginIDSDKAndTalk					=	"StartLoginIDSDKAndTalk"
	case startLoginIDSDKAndTalkFailure			=	"StartLoginIDSDKAndTalkFailure"
	case loginIDSDKSuccess

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController loginTalk Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case rootVCNotFound							=	"RootVCNotFound"
	case startTalkLogin							=	"StartTalkLogin"
	case talkLoginSuccess						=	"TalkLoginSuccess"
	case talkLoginFailure						=	"TalkLoginFailure"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController logoutIDSDKAndStartFresh Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case logoutIDSDKAndStartFreshLogin			=	"LogoutIDSDKAndStartFreshLogin"
	case logoutIDSDKWithTalkAndStartFreshLogin	=	"LogoutIDSDKWithTalkAndStartFreshLogin"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController Migration Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case startMigrating							=	"startMigrating"
	case migrationWithTalkReloginUsername		=	"MigrationWithTalkReloginUsername"
	case failedToMigrate						=	"FailedToMigrate"
	case migrationSuccess						=	"MigrationSuccess"
	case migrationFailedToReadUsrNameAndPsswd	=	"MigrationFailedToReadUsernameAndPassword"
	case forceLogout							=	"ForceLogout"
	case logoutTalkAndSSOSuccessfull			=	"LogoutTalkAndSSOSuccessfull"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController User Permissions Logging Keys
	// ----------------------------------------------------------------------------------------------------

	case notificationPermissionStatus			=	"NotificationPermissionStatus"
	case microPhonePermissionRequested			=	"MicroPhonePermissionRequested"
	case microPhonePermissionStatus				=	"MicroPhonePermissionStatus"
	case contactsPermissionRequested			=	"ContactsPermissionRequested"
	case contactsPermissionFailed				=	"ContactsPermissionFailed"
	case contactsPermissionGranted				=	"ContactsPermissionGranted"
}

enum IDSDKCrashlyticsEnum: String
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAccessTokenProvider Crashlytics Keys
	// ----------------------------------------------------------------------------------------------------

	case tokenExpired							=	"IDSDKAccessTknProvider:tknExpired"
	case tokenStoredInCache						=	"IDSDKAccessTknProvider:tknStoredCache"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKSession Crashlytics Keys
	// ----------------------------------------------------------------------------------------------------

	case prepareClient							=	"IDSDKSession:prepareClient"
	case serviceConfigurationLoadSuccess		=	"IDSDKSession:serviceConfigLoadSuccess"
	case serviceConfigurationLoadError			=	"IDSDKSession:serviceConfigLoadError"
	case loadSessionSuccess						=	"IDSDKSession:loadSessionSuccess"
	case loadSessionError						=	"IDSDKSession:loadSessionError"
	case loginStarted							=	"IDSDKSession:loginStarted"
	case loginSessionCreatedSuccessfully		=	"IDSDKSession:loginSessionCreatedSuccess"
	case failedToCreateLoginSession				=	"IDSDKSession:failedToCreateLoginSession"
	case migrationStarted						=	"IDSDKSession:migrationStarted"
	case migrationSessionCreatedSuccessfully	=	"IDSDKSession:migrationSessionCreated"
	case failedToCreateMigrationSession			=	"IDSDKSession:migrationSessionFailed"
	case fetchRAETokenSuccess					=	"IDSDKSession:fetchRAETokenSuccess"
	case fetchRAETokenError						=	"IDSDKSession:fetchRAETokenError"
	case fetchAndConvertRAETokenSuccess			=	"IDSDKSession:fetchConvertRAETknSuccess"
	case fetchAndConvertRAETokenError			=	"IDSDKSession:fetchConvertRAETknError"
	case logOutSuccess							=	"IDSDKSession:logOutSuccess"
	case logOutFailed							=	"IDSDKSession:logOutFailed"

	// ----------------------------------------------------------------------------------------------------
	// MARK: - IDSDKAuthenticationViewController Crashlytics Keys
	// ----------------------------------------------------------------------------------------------------

	case startAuth								=	"IDSDKAuth:startAuth"
	case setupLink								=	"IDSDKAuth:setupLink"
	case forcelogout							=	"IDSDKAuth:forcelogout"
	case showIntroduction						=	"IDSDKAuth:showIntroduction"
	case isTalkLoggedIn							=	"IDSDKAuth:isTalkLoggedIn"
}
