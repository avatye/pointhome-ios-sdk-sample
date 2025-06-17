//
//  GAMAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2021. 9. 7..
//  Copyright (c) 2021년 igaworks All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface GAMAdapter : AdPopcornSSPAdapter
{
    GAMBannerView *_adBannerView;
    GAMInterstitialAd *_interstitial, *_interstitialVideo;
    GADRewardedAd *_rewardedAd;
    GADAdLoader *_adLoader;
}

@end

@interface APGAMNativeAdRenderer: NSObject
@property (strong, nonatomic) GADNativeAdView *gamNativeAdView;
@end

