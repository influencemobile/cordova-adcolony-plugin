/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Affinity Influencing Systems
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.affinity.cordova.adcolony;

import com.jirbo.adcolony.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.LinearLayoutSoftKeyboardDetect;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.util.Log;
import android.view.View;
import java.util.Iterator;

/**
 * This class defines the native implementation of the AdColony Cordova plugin.
 */
public class AdColonyPlugin extends CordovaPlugin implements AdColonyAdListener, AdColonyAdAvailabilityListener, AdColonyV4VCListener {

	private static final String TAG = "AdColonyPlugin";
	/** Cordova Actions */
	private static final String ACTION_INITIALIZE = "initialize";
	private static final String ACTION_SHOW_VIDEO_AD = "showVideoAd";
	private static final String ACTION_SHOW_V4VC_VIDEO_AD = "showV4VCVideoAd";
	private static final String ACTION_CANCEL_AD = "cancelAd";
	// TODO: Native Ads
	// private static final String ACTION_CREATE_NATIVE_AD = "createNativeAd";
	// private static final String ACTION_REMOVE_NATIVE_AD = "removeNativeAd";
	// private static final String ACTION_SET_CLICK_AREA = "setNativeAdClickArea";

	private CallbackContext _videoAdCallbackContext;
	private CallbackContext _nativeAdCallbackContext;
	private boolean _isPreparingVideoAd;
	private boolean _hasInitialized;

	@Override
	public boolean execute(String action, JSONArray inputs, CallbackContext callbackContext) throws JSONException
	{
		try {
			if (action.equals(ACTION_INITIALIZE)) {
				if (_hasInitialized) return false;
				execInitialize(inputs, callbackContext);
				return true;
			} else if (action.equals(ACTION_SHOW_VIDEO_AD)) {
				execShowVideoAd(inputs, callbackContext);
				return true;
			} else if (action.equals(ACTION_SHOW_V4VC_VIDEO_AD)) {
				execShowV4VCVideoAd(inputs, callbackContext);
				return true;
			} else if (action.equals(ACTION_CANCEL_AD)) {
				execCancelAd(inputs, callbackContext);
				return true;
			} else {
				return false;
			}
		} catch (JSONException e) {
			callbackContext.error(e.getMessage());
			return false;
		}
	}

	@Override
	public void onPause(boolean multitasking) {
		if (_hasInitialized) {
			AdColony.pause();
		}
	}

	@Override
	public void onResume(boolean multitasking) {
		if (_hasInitialized) {
			AdColony.resume(this.cordova.getActivity());
		}
	}


	/** Cordova Helpers */

	public void fireEvent(String eventName, JSONObject json) throws JSONException {
		String namespace = "adcolony";
		String event  = "cordova.fireWindowEvent('"+ namespace +"."+ eventName +"', "+ json.toString() +");";
		String js = "setTimeout(function() { "+ event +" }, 0)";
		if (webView != null) {
			webView.sendJavascript(js);
		} else {
			Log.v(TAG + ":fireEvent", "webView is null!");
		}
	}

	private static String[] toStringArray(JSONArray jsonArray) throws JSONException {
		String[] result = new String[jsonArray.length()];
		for (int i = 0; i < jsonArray.length(); i++) {
			result[i] = jsonArray.getString(i);
		}
		return result;
	}


	/** Private Methods */

	private void execInitialize(JSONArray inputs, CallbackContext callbackContext) throws JSONException {
		String optionString = "";
		// try {
		JSONObject options = inputs.getJSONObject(2);
		String deviceId = options.getString("deviceId");
		String customId = options.getString("customId");
		if (deviceId != null) AdColony.setDeviceID( deviceId );
		if (customId != null) AdColony.setCustomID( customId );
		optionString = options.getString("optionString");
		// }
		// catch (JSONException exception) {
			// Do nothing
		// }
		String appId = inputs.getString(0);
		String[] zoneIds = toStringArray(inputs.getJSONArray(1));
		AdColony.configure( this.cordova.getActivity(), optionString, appId, zoneIds );
		AdColony.addAdAvailabilityListener(this);
		AdColony.addV4VCListener(this);

		_hasInitialized = true;
		Log.d(TAG, "Initialized with "+ appId);
		callbackContext.success();
	}

	private void execShowVideoAd(JSONArray inputs, CallbackContext callbackContext) throws JSONException {
		final String zoneId = inputs.getString(0);

		Runnable runnable = new Runnable() {
			public void run() {
				AdColonyVideoAd ad = new AdColonyVideoAd( zoneId );
				ad.withListener( AdColonyPlugin.this );
				ad.show();
			}
		};
		_isPreparingVideoAd = true;
		_videoAdCallbackContext = callbackContext;
		this.cordova.getActivity().runOnUiThread(runnable);
	}

	private void execShowV4VCVideoAd(JSONArray inputs, CallbackContext callbackContext) throws JSONException {
		final String zoneId = inputs.getString(0);

		Runnable runnable = new Runnable() {
			public void run() {
				AdColonyV4VCAd ad = new AdColonyV4VCAd( zoneId );
				ad.withListener( AdColonyPlugin.this );
				ad.show();
			}
		};
		_isPreparingVideoAd = true;
		_videoAdCallbackContext = callbackContext;
		this.cordova.getActivity().runOnUiThread(runnable);
	}

	private void execCancelAd(JSONArray inputs, CallbackContext callbackContext) {
		AdColony.cancelVideo();
		callbackContext.success();
	}


	// AdColonyAdListener

	// You can ping the AdColonyAd object here for more information:
	// ad.shown() - returns true if the ad was successfully shown.
	// ad.notShown() - returns true if the ad was not shown at all (i.e. if onAdColonyAdStarted was never triggered)
	// ad.skipped() - returns true if the ad was skipped due to an interval play setting
	// ad.canceled() - returns true if the ad was cancelled (either programmatically or by the user)
	// ad.noFill() - returns true if the ad was not shown due to no ad fill.
	public void onAdColonyAdAttemptFinished( AdColonyAd ad )
	{
		_isPreparingVideoAd = false;
		try {
			Log.i(TAG, "onAdColonyAdAttemptFinished");
			JSONObject json = new JSONObject();
			// json.put("zoneId", ad.zoneId);

			if (ad.shown()) {
				// TODO: Should return the zone ID here
				this.fireEvent("adcompleted", json);
			} else if (ad.notShown()) {
				_videoAdCallbackContext.error("Video ad not shown");
			} else if (ad.noFill()) {
				_videoAdCallbackContext.error("Video ad not filled");
			} else if (ad.canceled()) {
				_videoAdCallbackContext.error("Video ad canceled");
			} else {
				_videoAdCallbackContext.error("Video ad skipped");
			}
		}
		catch (JSONException e) {
			_videoAdCallbackContext.error(e.getMessage());
			System.out.println("Error: "+ e.getMessage());
		}
	}

	// Ad Started Callback, called only when an ad successfully starts playing.
	public void onAdColonyAdStarted( AdColonyAd ad )
	{
		try {
			JSONObject json = new JSONObject();
			// json.put("zoneId", ad.zoneId);

			// TODO: Should return the zone ID here
			_videoAdCallbackContext.success();

			// TODO: Should return the zone ID here
			Log.i(TAG, "onAdColonyAdStarted");
			this.fireEvent("adstarted", json);
		}
		catch (JSONException e) {
			_videoAdCallbackContext.error(e.getMessage());
			System.out.println("Error: "+ e.getMessage());
		}
	}


	// AdColonyAdAvailabilityListener

	/**
	 * This method is called when a zone's ad availability state changes
	 * (when ads become available, or become unavailable).
	 *
	 * window.addEventListener('adcolony.availabilitychange', function(payload));
	 */
	public void onAdColonyAdAvailabilityChange(boolean available, String zoneId)
	{
		try {
			JSONObject json = new JSONObject();
			json.put("available", available);
			json.put("zoneId", zoneId);

			Log.i(TAG, "onAdColonyAdAvailabilityChange");
			this.fireEvent("availabilitychange", json);
		}
		catch (Exception e) {
			System.out.println("Error: "+ e.getMessage());
		}
	}


	// AdColonyV4VCListener

	/**
	 * Notifies your app when a virtual currency transaction has completed
	 * as a result of displaying an ad.
	 *
	 * window.addEventListener('adcolony.v4vcreward', function(payload));
	 */
	public void onAdColonyV4VCReward( AdColonyV4VCReward reward )
	{
		// TODO: Respond with reward of zero?
		if (!reward.success()) return;

		try {
			JSONObject json = new JSONObject();
			json.put("currencyName", reward.name());
			json.put("amount", reward.amount());

			Log.i(TAG, "onAdColonyV4VCReward");
			this.fireEvent("v4vcreward", json);
		}
		catch (Exception e) {
			System.out.println("Error: "+ e.getMessage());
		}
	}

}
