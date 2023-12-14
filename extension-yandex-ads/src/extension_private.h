#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)

#pragma once

namespace dmYandexAds {
	enum BannerPosition {
		POS_NONE,
		POS_TOP_LEFT,
		POS_TOP_CENTER,
		POS_TOP_RIGHT,
		POS_BOTTOM_LEFT,
		POS_BOTTOM_CENTER,
		POS_BOTTOM_RIGHT,
		POS_CENTER
	};

	void Initialize_Ext();
	void ActivateApp();

	void Initialize();
	void EnableLogging();

	void LoadInterstitial(const char *unitId);
	bool IsInterstitialLoaded();
	void ShowInterstitial();

	void LoadRewarded(const char *unitId);
	bool IsRewardedLoaded();
	void ShowRewarded();

	void LoadBanner(const char *unitId, int width, int height);
	bool IsBannerLoaded();
	void DestroyBanner();
	void ShowBanner(BannerPosition bannerPos);
	void HideBanner();
	void SetUserConsent(bool val);
}

#endif
