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
 #import "AdColonyPlugin.h"

 #import <Cordova/CDV.h>
 #import <objc/runtime.h>
 #import <objc/message.h>

 @implementation AdColonyPlugin

#pragma mark - Public Cordova API

/**
 * Configure AdColony only once, on initial launch.
 */
- (void)initialize:(CDVInvokedUrlCommand *)command
{
    if (self.hasInitialized) return;

    [self.commandDelegate runInBackground:^{
        NSString *appId = [command.arguments objectAtIndex:0];
        NSArray *zoneIds = [command.arguments objectAtIndex:1];
        NSDictionary *options = [command.arguments objectAtIndex:2];

        BOOL debug = NO;
        if (options && [options isKindOfClass:[NSDictionary class]]) {
            [AdColony setOptions:options];
            [AdColony setCustomID:[options objectForKey:@"customId"]];
            debug = [self toBool:[options objectForKey:@"debug"]];
        }
        [AdColony configureWithAppID:appId zoneIDs:zoneIds delegate:self logging:debug];

        [self setupObservers];
        self.hasInitialized = YES;

        [self sendPluginOKToCallbackId:command.callbackId];
    }];
}

/**
 * Attempt to play an ad from an interstitial zone.
 */
- (void)showVideoAd:(CDVInvokedUrlCommand *)command
{
    if ([AdColony videoAdCurrentlyRunning]) {
        [self sendPluginErrorToCallbackId:command.callbackId message:@"Ad currently playing"];
    } else {
        NSString *zoneId = [command.arguments objectAtIndex:0];
        [AdColony playVideoAdForZone:zoneId withDelegate:self];
        self.videoAdCallbackId = command.callbackId;
    }
}

/**
 * Attempt to play an ad from a V4VC zone, using the same delegate and both
 * of the default popups.
 */
- (void)showV4VCVideoAd:(CDVInvokedUrlCommand *)command
{
    if ([AdColony videoAdCurrentlyRunning]) {
        [self sendPluginErrorToCallbackId:command.callbackId message:@"Ad currently playing"];
    } else {
        NSString *zoneId = [command.arguments objectAtIndex:0];
        [AdColony playVideoAdForZone:zoneId withDelegate:self withV4VCPrePopup:YES andV4VCPostPopup:YES];
        self.videoAdCallbackId = command.callbackId;
    }
}

/**
 * Cancels any full-screen ad that is currently playing and returns control to the app.
 * No earnings or V4VC rewards will occur if an ad is canceled programmatically by the app.
 * This should only be used by apps that must immediately respond to non-standard incoming events,
 * like a VoIP phone call. This should not be used for standard app interruptions such as
 * multitasking or regular phone calls.
 */
- (void)cancelAd:(CDVInvokedUrlCommand *)command
{
    [AdColony cancelAd];
    // TODO: Find out if normal callbacks still fire
    // self.videoAdCallbackId = nil;

    [self sendPluginOKToCallbackId:command.callbackId];
}


#pragma mark - Private Methods

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrencyBalance) name:kCurrencyBalanceChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneReady) name:kZoneReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneOff) name:kZoneOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoneLoading) name:kZoneLoading object:nil];
}

- (void)tearDownObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCurrencyBalanceChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneReady object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneOff object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kZoneLoading object:nil];
}


#pragma mark - Notifications

- (void)updateCurrencyBalance
{
    // Get currency balance from persistent storage and display it
    // NSNumber *wrappedBalance = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrencyBalance];
    // NSUInteger balance = wrappedBalance && [wrappedBalance isKindOfClass:[NSNumber class]] ? [wrappedBalance unsignedIntValue] : 0;
}

- (void)zoneReady
{
    // The zone is ready to display ads
}

- (void)zoneOff
{
    // The zone has been turned off in the control panel
}

- (void)zoneLoading
{
    // The zone is preparing ad(s) for display
}


#pragma mark - Cordova Helpers

/**
 * Convert object to boolean value.
 */
- (BOOL)toBool:(id)object
{
    return (object != (id)[NSNull null]) ? [object boolValue] : NO;
}

/**
 * Does input consist only of the digits 0 through 9?
 */
- (BOOL)isInt:(NSString *)commandArg
{
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [commandArg rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

/**
 * Check for null|empty|false command args.
 */
- (BOOL)isEmpty:(NSString *)commandArg
{
    return !commandArg || commandArg == (id)[NSNull null] || commandArg.length == 0;
}

/**
 * Shorthand to run a command's status_ok callback.
 */
- (void)sendPluginOKToCallbackId:(NSString *)callbackId
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/**
 * Run the command's status_error callback.
 */
- (void)sendPluginErrorToCallbackId:(NSString *)callbackId message:(NSString *)message
{
    NSString *error = [NSString stringWithFormat:@"Plugin error: %@", message];
    NSLog(@"%@", error);

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

/**
 * Fire a JavaScript DOM event.
 * @param event The event name
 * @param data The event data payload
 */
- (void)fireEvent:(NSString *)event data:(NSDictionary *)data
{
    NSString *json = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

    if (!jsonData) {
        NSLog(@"JSON serialization error: %@", error);
    } else {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *jsFormat = @"setTimeout(function(){ cordova.fireWindowEvent('adcolony.%@', %@); }, 0);";
    [self.commandDelegate evalJs:[NSString stringWithFormat:jsFormat, event, json]];
}


#pragma mark - AdColonyDelegate

/**
 * This method is called when a zone's ad availability state changes
 * (when ads become available, or become unavailable).
 *
 * window.addEventListener('adcolony.availabilitychange', function(payload));
 */
- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneId
{
    [self fireEvent:@"availabilitychange" data:@{
        @"available": @(available),
        @"zoneId": zoneId
    }];
}

/**
 * Notifies your app when a virtual currency transaction has completed
 * as a result of displaying an ad.
 *
 * window.addEventListener('adcolony.v4vcreward', function(payload));
 */
- (void)onAdColonyV4VCReward:(BOOL)success currencyName:(NSString *)currencyName currencyAmount:(int)amount inZone:(NSString *)zoneId
{
    if (success) {
        [self fireEvent:@"v4vcreward" data:@{
            @"currencyName": currencyName,
            @"amount": @(amount),
            @"zoneId": zoneId
        }];
    } else {
        NSLog(@"AdColony V4VCReward not successful with amound %d for zone %@", amount, zoneId);
    }
}


#pragma mark - AdColonyAdDelegate

/**
 * Called when AdColony has taken control of the device screen and is about
 * to begin showing an ad.
 */
- (void)onAdColonyAdStartedInZone:(NSString *)zoneId
{
    [self sendPluginOKToCallbackId:self.videoAdCallbackId];
    self.videoAdCallbackId = nil;
}

/**
 * Called when AdColony has finished trying to show an ad, either successfully
 * or unsuccessfully. If shown, app should implement code such as unpausing a
 * game and restarting app music.
 *
 * window.addEventListener('adcolony.adcompleted', function(payload));
 */
- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneId
{
    if (shown) {
        [self fireEvent:@"adcompleted" data:@{@"zoneId": zoneId}];
    } else {
        [self sendPluginErrorToCallbackId:self.videoAdCallbackId message:@"Video ad not shown"];
        self.videoAdCallbackId = nil;
    }
}


#pragma mark - AdColonyNativeAdDelegate

/**
 * Notifies your app that a native ad has begun displaying its video content in response to being displayed on screen.
 * @param ad The affected native ad view
 */
- (void)onAdColonyNativeAdStarted:(AdColonyNativeAdView *)ad
{

}

/**
 * Notifies your app that a native ad has been interacted with by a user and is expanding to full-screen playback.
 * Within the callback, apps should implement app-specific code such as turning off app music.
 * @param ad The affected native ad view
 */
- (void)onAdColonyNativeAdExpanded:(AdColonyNativeAdView *)ad
{

}

/**
 * Notifies your app that a native ad finished displaying its video content.
 * If the native ad was expanded to full-screen, this indicates that the full-screen mode has been exited.
 * Within the callback, apps should implement app-specific code such as resuming app music if it was turned off.
 * @param ad The affected native ad view
 * @param expanded Whether or not the native ad had been expanded to full-screen by the user.
 */
- (void)onAdColonyNativeAdFinished:(AdColonyNativeAdView *)ad expanded:(BOOL)expanded
{

}


#pragma mark - Cleanup

- (void)dealloc
{
    [self tearDownObservers];
}

@end
