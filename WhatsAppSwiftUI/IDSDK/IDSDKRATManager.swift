import Foundation


class IDSDKRATManager
{
	internal init() {}

	private var _telemetry: TelemetryProtocol = AppDelegate.telemetry

	// This method is only for testing purposes
	convenience init(telemetry: TelemetryProtocol)
	{
		self.init()
		_telemetry = telemetry
	}

	func trackViewOSPermissionSignIn()
	{
		_telemetry.trackView(section: .activation, page: .signInRakutenIOS, etype: .view)
	}

	func trackActionClickOSPermissionSignIn(target: String)
	{
		_telemetry.trackAction(section: .activation, page: .signInRakutenIOS, etype: .action, targetString: target, params: nil, accountInfo: nil)
	}

	func trackWalletSessionExpired()
	{
		_telemetry.trackView(section: .wallet, page: .sessionExpiredWallet, etype: .view)
	}

	func trackWalletSessionExpiredLoginClicked()
	{
		_telemetry.trackAction(section: .wallet, page: .sessionExpiredWallet, etype: .action, targetString: Telemetry.IDSDKTarget.sessionExpiredLoginBtn.rawValue, params: nil, accountInfo: nil)
	}

	func trackDiscoverySessionExpired()
	{
		_telemetry.trackView(section: .discovery, page: .sessionExpiredDiscovery, etype: .view)
	}

	func trackDiscoverySessionExpiredLoginClicked()
	{
		_telemetry.trackAction(section: .discovery, page: .sessionExpiredDiscovery, etype: .action, targetString: Telemetry.IDSDKTarget.sessionExpiredLoginBtn.rawValue, params: nil, accountInfo: nil)
	}

	func trackMissionSessionExpired()
	{
		_telemetry.trackView(section: .mission, page: .sessionExpiredMission, etype: .view)
	}

	func trackMissionSessionExpiredLoginClicked()
	{
		_telemetry.trackAction(section: .mission, page: .sessionExpiredMission, etype: .action, targetString: Telemetry.IDSDKTarget.sessionExpiredLoginBtn.rawValue, params: nil, accountInfo: nil)
	}

	func trackCommonSessionExpired()
	{
		_telemetry.trackView(section: .common, page: .sessionExpiredCommon, etype: .view)
	}

	func trackCommonSessionExpiredClick(target: String)
	{
		_telemetry.trackAction(section: .common, page: .sessionExpiredCommon, etype: .action, targetString: target, params: nil, accountInfo: nil)
	}
}
