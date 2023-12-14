# Yandex Mobile Ads SDK for Defold
_“This plugin is not endorsed or sponsored by Yandex LLC. This is an independent, unofficial plugin. “_

Defold [native extension](https://www.defold.com/manuals/extensions/) which provides access to Yandex Mobile Ads SDK functionality on Android and iOS.

# Setup

## How do I use this extension?

You can use the Yandex Mobile Ads SDK for Defold extension in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/).
Open your game.project file and in the dependencies field under project add:

>https://github.com/osov/defold-yandex-easy-monetization/archive/main.zip
or point to the ZIP file of a [specific release](https://github.com/osov/defold-yandex-easy-monetization/releases).

Please, read [Android API docs](https://yandex.ru/support2/mobile-ads/en/dev/android/quick-start) and [iOS API docs](https://yandex.ru/support2/mobile-ads/en/dev/ios/quick-start)

This repository also acts as a sample app. See `main/main.gui_script`.

# Lua API

## Methods

	yandexads.set_callback(listener) -- listener: function
	yandexads.initialize()
	yandexads.enable_logging()
	yandexads.set_user_consent(consent) -- consent: boolean

	yandexads.load_banner(adUnitId, width, height) -- adUnitId: string, width: int, height: int
	yandexads.is_banner_loaded() -- return: boolean
	yandexads.show_banner(position) -- position: int
	yandexads.hide_banner()
	yandexads.destroy_banner()

	yandexads.load_interstitial(adUnitId) -- adUnitId: string
	yandexads.is_interstitial_loaded() -- return: boolean
	yandexads.show_interstitial()

	yandexads.load_rewarded(adUnitId) -- adUnitId: string
	yandexads.is_rewarded_loaded() -- return: boolean
	yandexads.show_rewarded()

## Constants

	yandexads.MSG_ADS_INITED
	yandexads.MSG_INTERSTITIAL
	yandexads.MSG_REWARDED
	yandexads.MSG_BANNER

	yandexads.EVENT_LOADED
	yandexads.EVENT_ERROR_LOAD
	yandexads.EVENT_SHOWN
	yandexads.EVENT_DISMISSED
	yandexads.EVENT_CLICKED
	yandexads.EVENT_IMPRESSION
	yandexads.EVENT_NOT_LOADED
	yandexads.EVENT_REWARDED
	yandexads.EVENT_DESTROYED
	yandexads.EVENT_COMPLETED

	yandexads.POS_NONE
	yandexads.POS_TOP_LEFT
	yandexads.POS_TOP_CENTER
	yandexads.POS_TOP_RIGHT
	yandexads.POS_BOTTOM_LEFT
	yandexads.POS_BOTTOM_CENTER
	yandexads.POS_BOTTOM_RIGHT
	yandexads.POS_CENTER

# How to use ?

1. Set an event handling callback
2. Run initialization
3. Load desired ad format
```lua
local function listener(self, message_id, message)
	if message_id == yandexads.MSG_ADS_INITED then
		-- Extension is ready to load ads
	end
end

yandexads.set_callback(listener) -- (1)
yandexads.initialize() -- (2)
yandexads.set_user_consent(true) -- Call if user has given consent
```

`yandexads.enable_logging()` provides additional debug logging to the console from the SDK itself.

## BANNER

```lua
local function listener(self, message_id, message)
	if message_id == yandexads.MSG_ADS_INITED then
		yandexads.load_banner('demo-banner-yandex')
	end

	if message_id == yandexads.MSG_BANNER then
		if event == yandexads.EVENT_LOADED then
			yandexads.show_banner(yandexads.BOTTOM_CENTER) -- optional position(default BOTTOM_CENTER)
		end
	end
end
```

The default position is bottom center.

When loading a banner if you provide width only, the actual banner size is calculated as ["adaptive sticky banner"](https://yandex.ru/support2/mobile-ads/en/dev/android/adaptive-sticky-banner):

	Adaptive sticky banners provide maximum efficiency by optimizing the size of the ad on each device. This ad type lets developers set a maximum allowable ad width, though the optimal ad size is still determined automatically. The height of the adaptive sticky banner shouldn't exceed 15% of the screen height.

If you provide both width and height, the actual banner size is calculated as ["adaptive inline banner"](https://yandex.ru/support2/mobile-ads/en/dev/android/adaptive-inline-banner):

	This type of advertising allows developers to specify the maximum allowable width and height of the ad, while the most optimal ad size is determined automatically. To select the best ad size, built-in adaptive banners use the maximum height rather than the fixed height. This leads to potential performance improvement.

On iOS only `yandexads.POS_TOP_CENTER` and `yandexads.POS_BOTTOM_CENTER` are supported.

## INTERSTITIAL

```lua
local function listener(self, message_id, message)
	if message_id == yandexads.MSG_ADS_INITED then
		yandexads.load_interstitial('demo-interstitial-yandex')
	end

	if message_id == yandexads.MSG_INTERSTITIAL then
		if event == yandexads.EVENT_LOADED then
			yandexads.show_interstitial()
		end
	end
end
```


## REWARDED

```lua
local function listener(self, message_id, message)
	if message_id == yandexads.MSG_ADS_INITED then
	   yandexads.load_rewarded('demo-rewarded-yandex')
	end

	if message_id == yandexads.MSG_REWARDED then
		if event == yandexads.EVENT_LOADED then
			yandexads.show_rewarded()
		elseif event == yandexads.EVENT_REWARDED then
			print('Reward type: ' .. message.type)
			print('Reward amount: ' .. message.amount)
		end
	end
end
```
