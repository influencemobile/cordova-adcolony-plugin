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
#import <Cordova/CDV.h>
#import <AdColony/AdColony.h>
// #import "AppDelegate.h"

 #pragma mark - Constants

#define kCurrencyBalance @"CurrencyBalance"
#define kCurrencyBalanceChange @"CurrencyBalanceChange"

#define kZoneLoading @"ZoneLoading"
#define kZoneReady @"ZoneReady"
#define kZoneOff @"ZoneOff"

@interface AdColonyPlugin: CDVPlugin <AdColonyDelegate, AdColonyAdDelegate>

- (void)initialize:(CDVInvokedUrlCommand *)command;
- (void)showVideoAd:(CDVInvokedUrlCommand *)command;
- (void)showV4VCVideoAd:(CDVInvokedUrlCommand *)command;
- (void)cancelAd:(CDVInvokedUrlCommand *)command;

// TODO: Native ads

@property (nonatomic, copy) NSString *videoAdCallbackId;           /*!< The callback ID for video ads */
@property (nonatomic, copy) NSString *nativeAdCallbackId;          /*!< The callback ID for native ads */
@property (nonatomic) BOOL hasInitialized;

// @interface AppDelegate (CDVParsePlugin)
@end
