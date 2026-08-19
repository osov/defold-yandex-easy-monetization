#if defined(DM_PLATFORM_IOS)

#include "extension_private.h"
#include "extension_callback_private.h"

using namespace dmYandexAds;

#import <YandexMobileAds/YandexMobileAds.h>

namespace dmYandexAds {
	void SendSimpleMessage(MessageId type, MessageEvent event) {
		char buffer[32];
		uint32_t len = dmSnPrintf(buffer, sizeof(buffer), "{\"event\": %d}", (int)event);
		AddToQueueCallback(type, buffer);
	}

	void SendRewardedMessage(int amount, const char *type) {
		char buffer[2048];
		uint32_t len = dmSnPrintf(buffer, sizeof(buffer), "{\"event\": %d, \"amount\": %d, \"type\": \"%s\"}", (int)EVENT_REWARDED, amount, type);
		AddToQueueCallback(MSG_REWARDED, buffer);
	}

	void SendImpressionMessage(MessageId type, const char *impressionData) {
		if (impressionData != nullptr) {
			char buffer[64 + strlen(impressionData)];
			uint32_t len = dmSnPrintf(buffer, sizeof(buffer), "{\"event\": %d, \"impression\": %s}", (int)EVENT_IMPRESSION, impressionData);
			AddToQueueCallback(type, buffer);
		} else {
			SendSimpleMessage(type, EVENT_IMPRESSION);
		}
	}
}

#define ExtensionInterface Extension_yandexads_Interface

@interface ExtensionInterface : NSObject <
	YMABannerAdViewDelegate,
	YMAInterstitialAdDelegate,
	YMARewardedAdDelegate
>
@property(strong) YMABannerAdView *adView;
@property(strong) YMAInterstitialAd *interstitialAd;
@property(strong) YMARewardedAd *rewardedAd;
@property(strong) YMAInterstitialAdLoader *interstitialAdLoader;
@property(strong) YMARewardedAdLoader *rewardedAdLoader;
@end

@implementation ExtensionInterface {
	UIViewController *rootViewController;
	bool isBannerLoadedBool;
	bool isInterstitialLoadedBool;
	bool isRewardedLoadedBool;
}

-(id)init {
	UIWindow* window = dmGraphics::GetNativeiOSUIWindow();
	rootViewController = window.rootViewController;
	isBannerLoadedBool = false;
	isInterstitialLoadedBool = false;
	isRewardedLoadedBool = false;
	self.adView = nil;
	self.interstitialAd = nil;
	self.rewardedAd = nil;
	self.interstitialAdLoader = nil;
	self.rewardedAdLoader = nil;

	[YMAYandexAds initializeSDKWithCompletionHandler: ^{
		self.interstitialAdLoader = [YMAInterstitialAdLoader new];
		self.rewardedAdLoader = [YMARewardedAdLoader new];
		SendSimpleMessage(MSG_ADS_INITED, EVENT_LOADED);
	}];

	return self;
}

-(void)enableLogging {
	[YMAYandexAds enableLogging];
}

-(void)setUserConsent:(bool)consent {
	[YMAYandexAds setUserConsent:(consent ? YES : NO)];
}

// SDK 8: adUnitId is passed with every load via YMAAdRequest;
// the only ObjC initializer is the full designated one.
static YMAAdRequest *MakeAdRequest(const char *unitId) {
	return [[YMAAdRequest alloc] initWithAdUnitID:@(unitId)
	                                    targeting:nil
	                                      adTheme:YMAAdThemeUnspecified
	                                  biddingData:nil
	                            headerBiddingData:nil
	                                   parameters:nil];
}

/* #region Banner methods */

-(void)loadBanner:(const char *)unitId width:(int)width height:(int)height {
	isBannerLoadedBool = false;
	if (self.adView != nil) {
		[self.adView removeFromSuperview];
	}

	YMABannerAdSize *adSize = [YMABannerAdSize inlineWithWidth:320 maxHeight:50];
	if (width > 0 && height > 0) {
		adSize = [YMABannerAdSize inlineWithWidth:width maxHeight:height];
	} else if (width > 0) {
		adSize = [YMABannerAdSize stickyWithContainerWidth:width];
	}
	self.adView = [[YMABannerAdView alloc] initWithAdSize:adSize];
	self.adView.delegate = self;
	self.adView.translatesAutoresizingMaskIntoConstraints = false;

	[self.adView loadAdWithRequest:MakeAdRequest(unitId)];
}

-(bool)isBannerLoaded {
	return isBannerLoadedBool;
}

-(void)showBanner:(BannerPosition)bannerPos {
	if (isBannerLoadedBool && self.adView != nil) {
		switch (bannerPos) {
			case POS_TOP_CENTER:
				[self.adView displayAtTopInView:rootViewController.view];
				break;
			case POS_BOTTOM_CENTER:
			default:
				[self.adView displayAtBottomInView:rootViewController.view];
		}
	}
}

-(void)hideBanner {
	if (self.adView != nil) {
		[self.adView removeFromSuperview];
	}
}

-(void)destroyBanner {
	[self hideBanner];
	self.adView = nil;
	isBannerLoadedBool = false;
}

/* #endregion */

/* #region Interstitial methods */

-(void)loadInterstitial:(const char *)unitId {
	isInterstitialLoadedBool = false;
	if (self.interstitialAdLoader != nil) {
		[self.interstitialAdLoader loadAdWith:MakeAdRequest(unitId)
		                    completionHandler:^(YMAInterstitialAd * _Nullable ad, NSError * _Nullable error) {
			if (ad != nil) {
				self.interstitialAd = ad;
				self.interstitialAd.delegate = self;
				self->isInterstitialLoadedBool = true;
				SendSimpleMessage(MSG_INTERSTITIAL, EVENT_LOADED);
			} else {
				SendSimpleMessage(MSG_INTERSTITIAL, EVENT_ERROR_LOAD);
			}
		}];
	}
}

-(bool)isInterstitialLoaded {
	return isInterstitialLoadedBool;
}

-(void)showInterstitial {
	if (isInterstitialLoadedBool && self.interstitialAd != nil) {
		[self.interstitialAd showFromViewController:rootViewController];
	}
}

/* #endregion */

/* #region Rewarded methods */

-(void)loadRewarded:(const char *)unitId {
	isRewardedLoadedBool = false;
	if (self.rewardedAdLoader != nil) {
		[self.rewardedAdLoader loadAdWith:MakeAdRequest(unitId)
		                completionHandler:^(YMARewardedAd * _Nullable ad, NSError * _Nullable error) {
			if (ad != nil) {
				self.rewardedAd = ad;
				self.rewardedAd.delegate = self;
				self->isRewardedLoadedBool = true;
				SendSimpleMessage(MSG_REWARDED, EVENT_LOADED);
			} else {
				SendSimpleMessage(MSG_REWARDED, EVENT_ERROR_LOAD);
			}
		}];
	}
}

-(bool)isRewardedLoaded {
	return isRewardedLoadedBool;
}

-(void)showRewarded {
	if (isRewardedLoadedBool && self.rewardedAd != nil) {
		[self.rewardedAd showFromViewController:rootViewController];
	}
}

/* #endregion */

/* #region YMABannerAdViewDelegate */
-(void)bannerAdViewDidLoad:(nonnull YMABannerAdView *)bannerAdView {
	isBannerLoadedBool = true;
	SendSimpleMessage(MSG_BANNER, EVENT_LOADED);
}

-(void)bannerAdViewDidFailLoading:(nonnull YMABannerAdView *)bannerAdView error:(nonnull NSError *)error {
	SendSimpleMessage(MSG_BANNER, EVENT_ERROR_LOAD);
}

-(void)bannerAdViewDidClick:(nonnull YMABannerAdView *)bannerAdView {
	SendSimpleMessage(MSG_BANNER, EVENT_CLICKED);
}

-(void)bannerAdView:(nonnull YMABannerAdView *)bannerAdView didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData {
	SendImpressionMessage(MSG_BANNER, impressionData.rawData.UTF8String);
}
/* #endregion */

/* #region YMAInterstitialAdDelegate */

-(void)interstitialAdDidShow:(YMAInterstitialAd *)interstitialAd {
	SendSimpleMessage(MSG_INTERSTITIAL, EVENT_SHOWN);
}

-(void)interstitialAd:(YMAInterstitialAd *)interstitialAd didFailToShowWithError:(NSError *)error {
	isInterstitialLoadedBool = false;
	self.interstitialAd = nil;
	SendSimpleMessage(MSG_INTERSTITIAL, EVENT_DISMISSED);
}

-(void)interstitialAdDidDismiss:(YMAInterstitialAd *)interstitialAd {
	isInterstitialLoadedBool = false;
	self.interstitialAd = nil;
	SendSimpleMessage(MSG_INTERSTITIAL, EVENT_DISMISSED);
}

-(void)interstitialAdDidClick:(YMAInterstitialAd *)interstitialAd {
	SendSimpleMessage(MSG_INTERSTITIAL, EVENT_CLICKED);
}

-(void)interstitialAd:(YMAInterstitialAd *)interstitialAd
didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData {
	SendImpressionMessage(MSG_INTERSTITIAL, impressionData.rawData.UTF8String);
}

/* #endregion */

/* #region YMARewardedAdDelegate */

-(void)rewardedAd:(YMARewardedAd *)rewardedAd didReward:(id<YMAReward>)reward {
	SendRewardedMessage((int)reward.amount, reward.type.UTF8String);
}

-(void)rewardedAdDidShow:(YMARewardedAd *)rewardedAd {
	SendSimpleMessage(MSG_REWARDED, EVENT_SHOWN);
}

-(void)rewardedAd:(YMARewardedAd *)rewardedAd didFailToShowWithError:(NSError *)error {
	isRewardedLoadedBool = false;
	self.rewardedAd = nil;
	SendSimpleMessage(MSG_REWARDED, EVENT_DISMISSED);
}

-(void)rewardedAdDidDismiss:(YMARewardedAd *)rewardedAd {
	isRewardedLoadedBool = false;
	self.rewardedAd = nil;
	SendSimpleMessage(MSG_REWARDED, EVENT_DISMISSED);
}

-(void)rewardedAdDidClick:(YMARewardedAd *)rewardedAd {
	SendSimpleMessage(MSG_REWARDED, EVENT_CLICKED);
}

-(void)rewardedAd:(YMARewardedAd *)rewardedAd
didTrackImpressionWithData:(nullable id<YMAImpressionData>)impressionData {
	SendImpressionMessage(MSG_REWARDED, impressionData.rawData.UTF8String);
}

/* #endregion */

@end

/* #region C++ interface */

static ExtensionInterface *extension_instance;

namespace dmYandexAds {
	void Initialize_Ext() {
		extension_instance = [ExtensionInterface alloc];
	}

	void ActivateApp() {
	}

	void Initialize() {
		[extension_instance init];
	}

	void EnableLogging() {
		[extension_instance enableLogging];
	}

	void SetUserConsent(bool consent) {
		[extension_instance setUserConsent:consent];
	}

	void LoadBanner(const char *unitId, int width, int height) {
		[extension_instance loadBanner:unitId width:width height:height];
	}

	bool IsBannerLoaded() {
		return [extension_instance isBannerLoaded];
	}

	void ShowBanner(BannerPosition bannerPos) {
		[extension_instance showBanner:bannerPos];
	}

	void HideBanner() {
		[extension_instance hideBanner];
	}

	void DestroyBanner() {
		[extension_instance destroyBanner];
	}

	void LoadInterstitial(const char *unitId) {
		[extension_instance loadInterstitial:unitId];
	}

	bool IsInterstitialLoaded() {
		return [extension_instance isInterstitialLoaded];
	}

	void ShowInterstitial() {
		[extension_instance showInterstitial];
	}

	void LoadRewarded(const char *unitId) {
		[extension_instance loadRewarded:unitId];
	}

	bool IsRewardedLoaded() {
		return [extension_instance isRewardedLoaded];
	}

	void ShowRewarded() {
		[extension_instance showRewarded];
	}
}

/* #endregion */

#endif
