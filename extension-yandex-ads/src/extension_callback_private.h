#if defined(DM_PLATFORM_ANDROID) || defined(DM_PLATFORM_IOS)

#pragma once

#include "extension_private.h"

#include <dmsdk/sdk.h>

namespace dmYandexAds {
	enum MessageId {
		MSG_ADS_INITED,
		MSG_INTERSTITIAL,
		MSG_REWARDED,
		MSG_BANNER,
	};

	enum MessageEvent {
		EVENT_LOADED,
		EVENT_ERROR_LOAD,
		EVENT_SHOWN,
		EVENT_DISMISSED,
		EVENT_CLICKED,
		EVENT_IMPRESSION,
		EVENT_NOT_LOADED,
		EVENT_REWARDED,
		EVENT_DESTROYED,
	};

	struct CallbackData {
		MessageId msg;
		char *json;
	};

	void SetLuaCallback(lua_State *L, int pos);
	void UpdateCallback();
	void InitializeCallback();
	void FinalizeCallback();

	void AddToQueueCallback(MessageId type, const char *json);
}

#endif
