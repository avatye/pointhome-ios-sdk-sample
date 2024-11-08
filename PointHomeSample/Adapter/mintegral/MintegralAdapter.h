//
//  AdMobAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

#import <MTGSDK/MTGSDK.h>
#import <MTGSDK/MTGAdChoicesView.h>
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDKInterstitialVideo/MTGInterstitialVideoAdManager.h>
#import <MTGSDK/MTGNativeAdManager.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface MintegralAdapter : AdPopcornSSPAdapter
{
}
@end

@interface APMintegralNativeAdRenderer: NSObject

@property (strong, nonatomic) UIView *adUIView;
@property (weak, nonatomic) MTGMediaView *mMediaView;
@property (weak, nonatomic) UIImageView *iconImageView;
@property (weak, nonatomic) UILabel *appNameLabel;
@property (weak, nonatomic) UILabel *appDescLabel;
@property (weak, nonatomic) UIButton *adCallButton;
@property (weak, nonatomic) MTGAdChoicesView *adChoicesView;
@property (weak, nonatomic) NSLayoutConstraint *adChoicesViewWithConstraint;
@property (weak, nonatomic) NSLayoutConstraint *adChoicesViewHeightConstraint;

@end
