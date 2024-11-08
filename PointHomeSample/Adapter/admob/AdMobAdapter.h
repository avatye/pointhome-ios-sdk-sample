//
//  AdMobAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2017. 8. 2..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface AdMobAdapter : AdPopcornSSPAdapter
{
    GADBannerView *_adBannerView;
    GADInterstitialAd *_interstitial, *_interstitialVideo;
    GADRewardedAd *_rewardedAd;
    GADAdLoader *_adLoader;
}

@end

@interface APAdMobNativeAdRenderer: NSObject
@property (strong, nonatomic) GADNativeAdView *admobNativeAdView;
@end
