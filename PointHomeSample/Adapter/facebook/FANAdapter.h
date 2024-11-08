//
//  FANAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2017. 8. 2..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface FANAdapter : AdPopcornSSPAdapter
{
    FBAdView *_adView;
    FBInterstitialAd *_interstitialAd, *_interstitialVideoAd;
    FBNativeAd *_nativeAd;
    FBRewardedVideoAd *_rewardedVideoAd;
}
@end

@interface APFANNativeAdRenderer: NSObject

@property (strong, nonatomic) UIView *adUIView;
@property (strong, nonatomic) FBMediaView *adIconImageView;
@property (strong, nonatomic) FBMediaView *adCoverMediaView;
@property (strong, nonatomic) UILabel *adTitleLable;
@property (strong, nonatomic) UILabel *adBodyLabel;
@property (strong, nonatomic) UIButton *adCallToActionButton;
@property (strong, nonatomic) UILabel *adSocialContextLabel;
@property (strong, nonatomic) UILabel *adSponsoredLabel;
@property (strong, nonatomic) FBAdChoicesView *adChoicesView;

@end

@interface APFANNativeBannerAdRenderer: NSObject

@property (strong, nonatomic) UIView *adUIView;
@property (strong, nonatomic) FBMediaView *adIconImageView;
@property (strong, nonatomic) FBAdChoicesView *adChoicesView;
@property (strong, nonatomic) UILabel *adAdvertiserNameLabel;
@property (strong, nonatomic) UILabel *adSponsoredLabel;
@property (strong, nonatomic) UIButton *adCallToActionButton;
@property (strong, nonatomic) FBNativeBannerAd *nativeBannerAd;

@end
