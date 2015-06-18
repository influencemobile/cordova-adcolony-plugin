# Cordova Plugin for AdColony #

Present AdColony Ads in Mobile App/Games natively from JavaScript.

Compatible with:

* Cordova CLI, v3.5+

## NOTE: ##

This particular fork has support for the AdColony 2.5.1 iOS SDK. It also has support for an issue whereby if you are
using Web Audio, and this is at a different audio sample rate to the video that is played, when the advert completes,
the audio in the app is all broken up. We capture the audio sample rate prior to launching the advert,
and on completion, request this sample rate once again.

The repo location has changed.  Future-proof by updating your remote:
```
git remote set-url origin git@github.com:affinityis/cordova-adcolony-plugin.git
```

## How to use? ##

If using with Cordova CLI:
```
cordova plugin add https://github.com/affinityis/cordova-adcolony-plugin
```

## Quick Start Example Code ##

Step 1: Prepare your AdColony App Id for your app on [AdColony's client site](https://clients.adcolony.com/login).

```javascript
var config = {
	ios : {
		app_id:"ios_app_id",
		zone_ids: ["ios_zone_id"]
	},
	android : {
		app_id:"android_app_id",
		zone_ids: ["android_zone_id"]
	}
};

// select the right Ad Id according to platform
var setup = (/(android)/i.test(navigator.userAgent)) ? config.android : config.ios;

// Pass in an object with additional configuration
AdColony.initialize(setup.app_id, setup.zone_ids, {
	debug: true, // iOS only
	optionString: "version:1.0,store:google", // Android only
});
```

Step 2: Create a video ad with single line of javascript

```javascript
AdColony.showVideoAd( zoneId );
AdColony.showV4VCVideoAd( zoneId );
```

## Javascript API Overview ##

Methods:
```javascript
// Call before using API
initialize(appId, zoneIds, options, success, fail);
// Video ads
showVideoAd(zoneId);
showV4VCVideoAd(zoneId);
// Cancel all ads
cancelAd();
// For native ad (coming)
createNativeAd(adId, success, fail);
removeNativeAd(adId);
setNativeAdClickArea(adId, x, y, w, h);
```

## Detailed Documentation ##

The APIs, Events and Options are detailed documented.

Read the detailed API Reference Documentation [English](https://github.com/affinityis/cordova-adcolony-plugin/wiki).

## FAQ ##

If encounter problem when using the plugin, please read the [FAQ](https://github.com/affinityis/cordova-adcolony-plugin/wiki/FAQ) first.
