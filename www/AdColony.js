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

var cordova = require('cordova'),
	argscheck = require('cordova/argscheck'),
	utils = require('cordova/utils'),
	exec = require('cordova/exec');

var AdColony = {

	pluginName: 'AdColony',

	ZONE_STATUS: {
		NO_ZONE: 0,
		OFF: 1,
		LOADING: 2,
		ACTIVE: 3,
		UNKNOWN: 4
	},

	/**
	 * @param  appID       AdColony app id
	 * @param  zoneIds     Active zone id or ids
	 * @param  options     Object with configuration values:
	 *                     debug           Show debug output on iOS
	 *                     optionString    Android option string
	 *                     customId        User ID passed to all v4vc callbacks
	 *                     deviceId        Allows setting cusotm device IDs
	 */
	initialize: function (appID, zoneIds, options, completionCallback) {
		zoneIds = (zoneIds instanceof Array) ? zoneIds : [zoneIds];
		cordova.exec(
			completionCallback,
			completionCallback,
			this.pluginName,
			'initialize',
			[appID, zoneIds, options]
		);
	},

	showVideoAd: function (zoneId, successCallback, failureCallback) {
		cordova.exec(
			successCallback,
			failureCallback,
			this.pluginName,
			'showVideoAd',
			[zoneId]
		);
	},

	showV4VCVideoAd: function (zoneId, successCallback, failureCallback) {
		cordova.exec(
			successCallback,
			failureCallback,
			this.pluginName,
			'showV4VCVideoAd',
			[zoneId]
		);
	},

	/**
	 * This should only be used by apps that must immediately respond to non-standard
	 * incoming events, like a VoIP phone call. This should not be used for standard
	 * app interruptions such as multitasking or regular phone calls.
	 */
	cancelAd: function (completionCallback) {
		cordova.exec(
			completionCallback,
			completionCallback,
			this.pluginName,
			'cancelAd',
			[]
		);
	}

};

// Exports
module.exports = AdColony;
