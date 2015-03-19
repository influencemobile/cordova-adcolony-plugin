# Cordova Plugin for AdColony #

Present AdColony Ads in Mobile App/Games natively from JavaScript.

Compatible with:

* Cordova CLI, v3.5+

## NOTE: ##

The repo location has changed.  Set your remote to git@github.com:affinityis/cordova-adcolony-plugin.git

## How to use? ##

If using with Cordova CLI:
```
cordova plugin add https://github.com/gabecoyne/cordova-adcolony-plugin
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
setNativeAdClickArea(adId,x,y,w,h);
```

## Detailed Documentation ##

The APIs, Events and Options are detailed documented.

Read the detailed API Reference Documentation [English](https://github.com/gabecoyne/cordova-adcolony-plugin/wiki).

## FAQ ##

If encounter problem when using the plugin, please read the [FAQ](https://github.com/gabecoyne/cordova-adcolony-plugin/wiki/FAQ) first.
