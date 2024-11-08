//
//  FANAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2017. 8. 2..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

// compatible with FAN v6.14.0
#import "FANAdapter.h"

static inline NSString *SSPErrorString(SSPErrorCode code)
{
    switch (code)
    {
        case AdPopcornSSPException:
            return @"Exception";
        case AdPopcornSSPInvalidParameter:
            return @"Invalid Parameter";
        case AdPopcornSSPUnknownServerError:
            return @"Unknown Server Error";
        case AdPopcornSSPInvalidMediaKey:
            return @"Invalid Media key";
        case AdPopcornSSPInvalidPlacementId:
            return @"Invalid Placement Id";
        case AdPopcornSSPInvalidNativeAssetsConfig:
            return @"Invalid native assets config";
        case AdPopcornSSPNativePlacementDoesNotInitialized:
            return @"Native Placement Does Not Initialized";
        case AdPopcornSSPServerTimeout:
            return @"Server Timeout";
        case AdPopcornSSPLoadAdFailed:
            return @"Load Ad Failed";
        case AdPopcornSSPNoAd:
            return @"No Ad";
        case AdPopcornSSPNoInterstitialLoaded:
            return @"No Interstitial Loaded";
        case AdPopcornSSPNoRewardVideoAdLoaded:
            return @"No Reward video ad Loaded";
        case AdPopcornSSPMediationAdapterNotInitialized:
            return @"Mediation Adapter Not Initialized";
        default: {
            return @"Success";
        }
    }
}

@interface FANAdapter () <FBAdViewDelegate, FBInterstitialAdDelegate, FBNativeAdDelegate, FBNativeBannerAdDelegate, FBRewardedVideoAdDelegate>
{
    BOOL _isCurrentRunningAdapter;
    APFANNativeAdRenderer *fanNativeAdRenderer;
    APFANNativeBannerAdRenderer *fanNativeBannerAdRenderer;
    BOOL isFANNativeBannerAd;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    NSMutableArray *_impTrackersListArray, *_clickTrackersListArray;
    NSString *_biddingData;
    BOOL _isInAppBidding;
}

- (void)addAlignCenterConstraint;
- (void)showNativeAd;
- (void)showNativeBannerAd;

@property (strong, nonatomic) FBNativeAd *nativeAd;
@property (strong, nonatomic) FBNativeBannerAd *nativeBannerAd;

@end

@implementation FANAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 2;
    _isInAppBidding = NO;
    return self;
}


- (void)setViewController:(UIViewController *)viewController origin:(CGPoint)origin size:(CGSize)size bannerView:(AdPopcornSSPBannerView *)bannerView
{
    _viewController = viewController;
    _origin = origin;
    _size = size;
    _bannerView = bannerView;
    _adType = SSPAdBannerType;
}

- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPAdInterstitialType;
}

- (void)setRewardVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPRewardVideoAdType;
}

- (void)setNativeAdViewController:(UIViewController *)viewController nativeAdRenderer:(id)nativeAdRenderer rootNativeAdView:(AdPopcornSSPNativeAd *)adpopcornSSPNativeAd
{
    _viewController = viewController;
    _adType = SSPNativeAdType;
    if([nativeAdRenderer isKindOfClass:[APFANNativeAdRenderer class]])
    {
        fanNativeAdRenderer = nativeAdRenderer;
        isFANNativeBannerAd = NO;
    }
    else if ([nativeAdRenderer isKindOfClass:[APFANNativeBannerAdRenderer class]])
    {
        fanNativeBannerAdRenderer = nativeAdRenderer;
        isFANNativeBannerAd = YES;
    }
    _adpopcornSSPNativeAd = adpopcornSSPNativeAd;
}

- (void)setInterstitialVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPInterstitialVideoAdType;
}

- (BOOL)isSupportInterstitialAd
{
    return YES;
}

- (BOOL)isSupportRewardVideoAd
{
    return YES;
}

- (BOOL)isSupportNativeAd
{
    return YES;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (void)setBiddingData:(NSString *)biddingData impressionList:(NSMutableArray *)impTrackersListArray clickList: (NSMutableArray *)clickTrackersListArray
{
    _biddingData = biddingData;
    _impTrackersListArray = impTrackersListArray;
    _clickTrackersListArray =  clickTrackersListArray;
}

- (void)setInAppBiddingMode:(bool)isInAppBiddingMode
{
    _isInAppBidding = isInAppBiddingMode;
}

- (void)loadAd
{
    /* For Test
    [FBAdSettings setLogLevel:FBAdLogLevelLog];
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
    FBAdSettings.testAdType = FBAdTestAdType_Vid_HD_16_9_15s_App_Install;
    [FBAdSettings setAdvertiserTrackingEnabled:YES];*/
    
    if (_adType == SSPAdBannerType)
    {
        if (_adView.superview == nil)
        {
            if (_integrationKey != nil)
            {
                NSString *placementID = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
                if(_size.width == 320.0f && _size.height == 100.0f)
                {
                    NSLog(@"%@ : FAN can not load 320x100", self);
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                    }
                    
                    [self closeAd];
                    return;
                }
                else if(_size.width == 300.0f && _size.height == 250.0f)
                {
                    _adView = [[FBAdView alloc] initWithPlacementID:placementID adSize:kFBAdSizeHeight250Rectangle rootViewController:_viewController];
                }
                else
                {
                    _adView = [[FBAdView alloc] initWithPlacementID:placementID adSize:kFBAdSizeHeight50Banner rootViewController:_viewController];
                }
                
                _adView.frame = CGRectMake(0.0f, 0.0f, _size.width, _size.height);
                _adView.delegate = self;
                _adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

                // add banner view
                [_bannerView addSubview:_adView];
                
                [self addAlignCenterConstraint];
                
                [_adView loadAd];
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                }
                
                [self closeAd];
            }
        }
    }
    else if (_adType == SSPAdInterstitialType)
    {
        if (_integrationKey != nil)
        {
            //NSString *placementID = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
            NSString *placementID = [_integrationKey valueForKey:@"fb_placement_id"];
            _interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:placementID];
            _interstitialAd.delegate = self;
            [_interstitialAd loadAdWithBidPayload:_biddingData];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        if(networkScheduleTimer == nil)
        {
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        else{
            [self invalidateNetworkTimer];
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            NSString *placementID = [_integrationKey valueForKey:@"fb_placement_id"];
            NSLog(@"fb_placement_id : %@", placementID);
            _rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:placementID];
            _rewardedVideoAd.delegate = self;
            [_rewardedVideoAd loadAdWithBidPayload:_biddingData];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
    else if (_adType == SSPInterstitialVideoAdType)
    {
        if(networkScheduleTimer == nil)
        {
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        else{
            [self invalidateNetworkTimer];
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            //NSString *placementID = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
            NSString *placementID = [_integrationKey valueForKey:@"fb_placement_id"];
            _interstitialVideoAd = [[FBInterstitialAd alloc] initWithPlacementID:placementID];
            _interstitialVideoAd.delegate = self;
            [_interstitialVideoAd loadAdWithBidPayload:_biddingData];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
    else if (_adType == SSPNativeAdType)
    {
        NSString *placementID = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
        if(placementID != nil)
        {
            if(isFANNativeBannerAd)
            {
                NSLog(@"FANNativeBannerAd loadAd");
                _nativeBannerAd = [[FBNativeBannerAd alloc] initWithPlacementID:placementID];
                _nativeBannerAd.delegate = self;
                [_nativeBannerAd loadAd];
            }
            else{
                NSLog(@"FBNativeAd loadAd");
                _nativeAd = [[FBNativeAd alloc] initWithPlacementID:placementID];
                _nativeAd.delegate = self;
                [_nativeAd loadAd];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
}

- (void)showAd
{
    NSLog(@"FANAdapter showAd");
    if (_adType == SSPAdInterstitialType)
    {
        [_interstitialAd showAdFromRootViewController:_viewController];
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        if (_rewardedVideoAd && _rewardedVideoAd.isAdValid)
        {
            [_rewardedVideoAd showAdFromRootViewController:_viewController];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if(_interstitialVideoAd && [_interstitialVideoAd isAdValid])
        {
            [_interstitialVideoAd showAdFromRootViewController:_viewController];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
            }
        }
    }
}

- (void)closeAd
{
    if (_adType == SSPAdBannerType)
    {
        if(_adView != nil)
        {
            [_adView removeFromSuperview];
            _adView.delegate = nil;
            _adView = nil;
        }
    }
    else if (_adType == SSPAdInterstitialType)
    {
        if(_interstitialAd != nil)
        {
            _interstitialAd.delegate = nil;
            _interstitialAd = nil;
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        _isCurrentRunningAdapter = NO;
        if(_rewardedVideoAd != nil)
        {
            _rewardedVideoAd.delegate = nil;
            _rewardedVideoAd = nil;
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        _isCurrentRunningAdapter = NO;
        if(_interstitialVideoAd != nil)
        {
            _interstitialVideoAd.delegate = nil;
            _interstitialVideoAd = nil;
        }
    }
}

- (void)addAlignCenterConstraint
{
    // add constraints
    if(_adView != nil)
    {
        [_adView setTranslatesAutoresizingMaskIntoConstraints:NO];
        UIView *superview = _bannerView;
        [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
        [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
        [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
        [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
    }
}
-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"FANAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"FANAdapter iv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    [self invalidateNetworkTimer];
}

-(void)invalidateNetworkTimer
{
    if(networkScheduleTimer != nil)
        [networkScheduleTimer invalidate];
}

#pragma mark - FBAdViewDelegate
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error;
{
    NSLog(@"adViewDidLoad didFailWithError : %@", error);
    adView.hidden = YES;
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:error adapter:self];
    }
}

- (void)adViewDidLoad:(FBAdView *)adView;
{
    NSLog(@"FANAdapter adViewDidLoad");
    // Add code to show the ad unit...
    adView.hidden = NO;
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

- (void)adViewDidClick:(FBAdView *)adView
{
    NSLog(@"FANAdapter adViewDidClick");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"FANAdapter interstitialAdDidLoad");
    // You can now display the full screen ad using this code:
    if(_adType == SSPAdInterstitialType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadSuccess:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
        }
        [self invalidateNetworkTimer];
    }
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"FANAdapter didFailWithError : %@", error);
    if(_adType == SSPAdInterstitialType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:error adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType){
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:error adapter:self];
        }
    }
    [self closeAd];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"FANAdapter interstitialAdWillLogImpression");
    if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdShowSuccess:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
        }
    }
    
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"FANAdapter interstitialAdDidClose");
    if(_adType == SSPAdInterstitialType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClosed:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdClosed:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
        _isCurrentRunningAdapter = false;
    }
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"FANAdapter interstitialAdDidClick");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

- (void)showNativeAd
{
    @try {
        if (self.nativeAd && self.nativeAd.isAdValid) {
            [self.nativeAd unregisterView];
            
            NSMutableArray *clickableViewArray = [[NSMutableArray alloc] init];
            if(fanNativeAdRenderer.adTitleLable != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adTitleLable];
            if(fanNativeAdRenderer.adBodyLabel != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adBodyLabel];
            if(fanNativeAdRenderer.adIconImageView != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adIconImageView];
            if(fanNativeAdRenderer.adCoverMediaView != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adCoverMediaView];
            if(fanNativeAdRenderer.adSocialContextLabel != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adSocialContextLabel];
            if(fanNativeAdRenderer.adSponsoredLabel != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adSponsoredLabel];
            if(fanNativeAdRenderer.adCallToActionButton != nil)
                [clickableViewArray addObject:fanNativeAdRenderer.adCallToActionButton];
            
            // Wire up UIView with the native ad; only call to action button and media view will be clickable.
            [self.nativeAd registerViewForInteraction:fanNativeAdRenderer.adUIView mediaView:fanNativeAdRenderer.adCoverMediaView iconView:fanNativeAdRenderer.adIconImageView viewController:_viewController clickableViews:clickableViewArray];
            
            // Render native ads onto UIView
            if(fanNativeAdRenderer.adTitleLable != nil)
                fanNativeAdRenderer.adTitleLable.text = self.nativeAd.advertiserName;
            if(fanNativeAdRenderer.adBodyLabel != nil)
                fanNativeAdRenderer.adBodyLabel.text = self.nativeAd.bodyText;
            if(fanNativeAdRenderer.adSocialContextLabel != nil)
                fanNativeAdRenderer.adSocialContextLabel.text = self.nativeAd.socialContext;
            if(fanNativeAdRenderer.adSponsoredLabel != nil)
                fanNativeAdRenderer.adSponsoredLabel.text = self.nativeAd.sponsoredTranslation;
            if(fanNativeAdRenderer.adCallToActionButton != nil)
                [fanNativeAdRenderer.adCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
            }
        }
    } @catch (NSException *exception) {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPInvalidNativeAssetsConfig userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPInvalidNativeAssetsConfig)}] adapter:self];
        }
    } @finally {}
}

- (void)showNativeBannerAd
{
    @try {
        if (self.nativeBannerAd && self.nativeBannerAd.isAdValid) {
            [self.nativeBannerAd unregisterView];
            
            NSMutableArray *clickableViewArray = [[NSMutableArray alloc] init];
            
            // Render native banner ads onto UIView
            if(fanNativeBannerAdRenderer.adAdvertiserNameLabel != nil)
            {
                fanNativeBannerAdRenderer.adAdvertiserNameLabel.text = self.nativeBannerAd.advertiserName;
                [clickableViewArray addObject:fanNativeBannerAdRenderer.adAdvertiserNameLabel];
            }
            if(fanNativeBannerAdRenderer.adSponsoredLabel != nil)
            {
                fanNativeBannerAdRenderer.adSponsoredLabel.text = self.nativeBannerAd.sponsoredTranslation;
                [clickableViewArray addObject:fanNativeBannerAdRenderer.adSponsoredLabel];
            }
            if (self.nativeBannerAd.callToAction && fanNativeBannerAdRenderer.adCallToActionButton != nil) {
                [fanNativeBannerAdRenderer.adCallToActionButton setHidden:NO];
                [fanNativeBannerAdRenderer.adCallToActionButton setTitle:self.nativeBannerAd.callToAction
                                           forState:UIControlStateNormal];
                [clickableViewArray addObject:fanNativeBannerAdRenderer.adCallToActionButton];
            }
            else
            {
                if(fanNativeBannerAdRenderer.adCallToActionButton != nil)
                    [fanNativeBannerAdRenderer.adCallToActionButton setHidden:YES];
            }
            
            // Set native banner ad view tags to declare roles of your views for better analysis in future
            // We will be able to provide you statistics how often these views were clicked by users
            // Views provided by Facebook already have appropriate tag set
            if(fanNativeBannerAdRenderer.adAdvertiserNameLabel != nil)
            {
                fanNativeBannerAdRenderer.adAdvertiserNameLabel.nativeAdViewTag = FBNativeAdViewTagTitle;
            }
            if(fanNativeBannerAdRenderer.adCallToActionButton != nil)
            {
                fanNativeBannerAdRenderer.adCallToActionButton.nativeAdViewTag = FBNativeAdViewTagCallToAction;
            }
            // Specify the clickable areas. View you were using to set ad view tags should be clickable.
            [self.nativeBannerAd registerViewForInteraction:fanNativeBannerAdRenderer.adUIView
                            iconView:fanNativeBannerAdRenderer.adIconImageView
                            viewController:_viewController
                            clickableViews:clickableViewArray];
            
            if(fanNativeBannerAdRenderer.adChoicesView != nil)
            {
                fanNativeBannerAdRenderer.adChoicesView.corner = UIRectCornerTopLeft;
                fanNativeBannerAdRenderer.adChoicesView.nativeAd = self.nativeBannerAd;
            }
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
            }
        }
    } @catch (NSException *exception) {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPInvalidNativeAssetsConfig userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPInvalidNativeAssetsConfig)}] adapter:self];
        }
    } @finally {}
}

- (NSString *)getBiddingToken
{
    return [FBAdSettings bidderToken];
}

#pragma mark - FBNativeAdDelegate
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    NSLog(@"FANAdapter nativeAdDidLoad...%@", nativeAd);
    self.nativeAd = nativeAd;
    [self showNativeAd];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    NSLog(@"FANAdapter Native ad failed to load with error: %@", error);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    NSLog(@"FANAdapter Native ad was clicked.");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    NSLog(@"FANAdapter Native ad impression is being captured.");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
    }
}

#pragma mark - FBNativeBannerAdDelegate
- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd
{
    NSLog(@"FANAdapter nativeBannerAdDidLoad...%@", nativeBannerAd);
    self.nativeBannerAd = nativeBannerAd;
    [self showNativeBannerAd];
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error
{
    NSLog(@"FANAdapter Native banner ad failed to load with error: %@", error);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
    }
}

- (void)nativeBannerAdDidClick:(FBNativeBannerAd *)nativeBannerAd
{
    NSLog(@"FANAdapter Native banner ad was clicked.");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}

- (void)nativeBannerAdDidFinishHandlingClick:(FBNativeBannerAd *)nativeBannerAd
{
    NSLog(@"Native banner ad did finish click handling.");
}

- (void)nativeBannerAdWillLogImpression:(FBNativeBannerAd *)nativeBannerAd
{
    NSLog(@"FANAdapter Native banner ad impression is being captured.");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
    }
}

#pragma mark FBRewardedVideoAdDelegate
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    NSLog(@"FANAdapter didFailWithError : %@", error);
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"FANAdapter rewardedVideoAdDidLoad");
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
    }
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"FANAdapter rewardedVideoAdDidClick");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd;
{
    NSLog(@"FANAdapter rewardedVideoAdVideoComplete");
    if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
    {
        [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
    }
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"FANAdapter rewardedVideoAdWillLogImpression");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
    }
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"FANAdapter rewardedVideoAdDidClose");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
    }
    _isCurrentRunningAdapter = NO;
}
@end

@implementation APFANNativeAdRenderer
{
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}
@end

@implementation APFANNativeBannerAdRenderer
{
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}
@end
