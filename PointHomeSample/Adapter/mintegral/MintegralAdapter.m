//
//  MintegralAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

// compatible with Mintegral v7.7.1
#import "MintegralAdapter.h"

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
        case AdPopcornSSPNoInterstitialVideoAdLoaded:
            return @"No Interstitial video ad Loaded";
        default: {
            return @"Success";
        }
    }
}

@interface MintegralAdapter () <MTGRewardAdLoadDelegate, MTGRewardAdShowDelegate, MTGInterstitialVideoDelegate, MTGBannerAdViewDelegate, MTGNativeAdManagerDelegate, MTGMediaViewDelegate>
{
    NSString *_mintegralUnitId, *_mintegralRewardId;
    NSString *_mintegralPlacementId;
    BOOL _isCurrentRunningAdapter;
    MTGInterstitialVideoAdManager *ivAdManager;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    MTGBannerAdView *mtgBannerAdView;
    
    MTGNativeAdManager *mtgNativeAdManager;
    APMintegralNativeAdRenderer *mintegralNativeAdRenderer;
    BOOL _isMute;
}
@end

@implementation MintegralAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    adNetworkNo = 8;
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

- (void)setInterstitialVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPInterstitialVideoAdType;
}

- (void)setNativeAdViewController:(UIViewController *)viewController nativeAdRenderer:(id)nativeAdRenderer rootNativeAdView:(AdPopcornSSPNativeAd *)adpopcornSSPNativeAd
{
    _viewController = viewController;
    _adType = SSPNativeAdType;
    if([nativeAdRenderer isKindOfClass:[APMintegralNativeAdRenderer class]])
        mintegralNativeAdRenderer = nativeAdRenderer;
    _adpopcornSSPNativeAd = adpopcornSSPNativeAd;
}

- (BOOL)isSupportInterstitialAd
{
    return NO;
}

- (BOOL)isSupportRewardVideoAd
{
    return YES;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (BOOL)isSupportNativeAd
{
    return YES;
}

- (void)setMute:(bool)mute
{
    _isMute = mute;
}

- (void)loadAd
{
    NSLog(@"MintegralAdapter : loadAd");
    if(networkScheduleTimer == nil)
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    
    if(_adType == SSPAdBannerType)
    {
        if (_integrationKey != nil)
        {
            _mintegralUnitId = [_integrationKey valueForKey:@"MintegralUnitId"];
            _mintegralPlacementId = [_integrationKey valueForKey:@"MintegralPlacementId"];
            
            if(_size.width == 320.0f && _size.height == 100.0f)
            {
                mtgBannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:MTGLargeBannerType320x90 placementId:_mintegralPlacementId unitId:_mintegralUnitId rootViewController:_viewController];
            }
            else if(_size.width == 300.0f && _size.height == 250.0f)
            {
                mtgBannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:MTGMediumRectangularBanner300x250 placementId:_mintegralPlacementId unitId:_mintegralUnitId rootViewController:_viewController];
            }
            else
            {
                mtgBannerAdView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:MTGStandardBannerType320x50 placementId:_mintegralPlacementId unitId:_mintegralUnitId rootViewController:_viewController];
            }
            mtgBannerAdView.delegate = self;
            [_bannerView addSubview:mtgBannerAdView];
            
            [self addAlignCenterConstraint];
            [mtgBannerAdView loadBannerAd];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPNativeAdType)
    {
        if(_integrationKey != nil)
        {
            _mintegralUnitId = [_integrationKey valueForKey:@"MintegralUnitId"];
            _mintegralPlacementId = [_integrationKey valueForKey:@"MintegralPlacementId"];
            
            mtgNativeAdManager = [[MTGNativeAdManager alloc] initWithPlacementId:_mintegralPlacementId unitID:_mintegralUnitId fbPlacementId:nil forNumAdsRequested:1 presentingViewController:_viewController];
            mtgNativeAdManager.delegate = self;
            [mtgNativeAdManager loadAds];
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
    else if (_adType == SSPRewardVideoAdType)
    {
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            _mintegralUnitId = [_integrationKey valueForKey:@"MintegralUnitId"];
            _mintegralPlacementId = [_integrationKey valueForKey:@"MintegralPlacementId"];
            _mintegralRewardId = [_integrationKey valueForKey:@"MintegralRewardId"];
            
            if(_isMute)
            {
                [MTGRewardAdManager sharedInstance].playVideoMute = YES;
            }
            
            [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId delegate:self];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            _mintegralUnitId = [_integrationKey valueForKey:@"MintegralUnitId"];
            _mintegralPlacementId= [_integrationKey valueForKey:@"MintegralPlacementId"];
            if(!ivAdManager)
            {
                ivAdManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId delegate:self];
            }
            
            if(_isMute)
            {
                [ivAdManager setPlayVideoMute:YES];
            }
            ivAdManager.delegate = self;
            [ivAdManager loadAd];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
}

- (void)showAd
{
    NSLog(@"MintegralAdapter : showAd");
    if (_adType == SSPRewardVideoAdType)
    {
        if ([[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId]) {
            [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId withRewardId:_mintegralRewardId userId:@"" delegate:self viewController:_viewController];
            return;
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
        if(!ivAdManager)
        {
            ivAdManager = [[MTGInterstitialVideoAdManager alloc] initWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId delegate:self];
            ivAdManager.delegate = self;
        }
        
        if([ivAdManager isVideoReadyToPlayWithPlacementId:_mintegralPlacementId unitId:_mintegralUnitId])
        {
            [ivAdManager showFromViewController:_viewController];
        }
    }
}

- (void)closeAd
{
    NSLog(@"MintegralAdapter closeAd");
    _isCurrentRunningAdapter = NO;
    if(_adType == SSPAdBannerType)
    {
        if(mtgBannerAdView != nil)
            [mtgBannerAdView destroyBannerAdView];
    }
}

- (void)loadRequest
{
    // Not used any more
}

- (void)addAlignCenterConstraint
{
    // add constraints
    [mtgBannerAdView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:mtgBannerAdView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:mtgBannerAdView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:mtgBannerAdView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:mtgBannerAdView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"Mintegral rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"Mintegral iv load timeout");
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

#pragma MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView
{
    //This method is called when adView ad slot loaded successfully.
    NSLog(@"Mintegral adViewLoadSuccess");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView
{
    //This method is called when adView ad slot failed to load.
    NSLog(@"Mintegral adViewLoadFailedWithError : %@", error);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:error adapter:self];
    }
    
    [self closeAd];
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView
{
    //This method is called before the impression of an MTGBannerAdView object.
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView
{
    //This method is called when ad is clicked.
    NSLog(@"Mintegral adViewDidClicked");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView
{
    //Sent when a user is about to leave your application as a result of tapping.Your application will be moved to the background shortly after this method is called.
}
- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView
{
    //Would open the full screen view.Sent when openning storekit or openning the webpage in app.
}
- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView
{
    //Would close the full screen view.Sent when closing storekit or closing the webpage in app.
}

#pragma MTGRewardAdLoadDelegate
/**
 *  Called when the ad is loaded , but not ready to be displayed,need to wait download video
 completely
 *  @param unitId - the unitId string of the Ad that was loaded.
 */
- (void)onAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    NSLog(@"MintegralAdapter onAdLoadSuccess");
}

/**
 *  Called when the ad is loaded , but is ready to be displayed
 completely
 *  @param unitId - the unitId string of the Ad that was loaded.
 */
- (void)onVideoAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    NSLog(@"MintegralAdapter onVideoAdLoadSuccess");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
    }
    [self invalidateNetworkTimer];
}

/**
 *  Called when the ad is loaded failure
 completely
 */
- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(nonnull NSError *)error
{
    NSLog(@"MintegralAdapter onVideoAdLoadFailed");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:error adapter:self];
    }
    [self invalidateNetworkTimer];
}

#pragma MTGRewardAdShowDelegate
/**
 *  Called when the ad display success
 *
 *  @param unitId - the unitId string of the Ad that display success.
 */
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    NSLog(@"MintegralAdapter onVideoAdShowSuccess");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
    }
}

/**
 *  Called when the ad display is successful
 *
 *  @param unitId - the unitId string of the Ad that displayed successfully.
 */

- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(nonnull NSError *)error
{
    NSLog(@"MintegralAdapter onVideoAdShowFailed");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:error adapter:self];
    }
}

/**
 *  Called when the ad has been dismissed from being displayed, and control will return to your app
 *
 *  @param placementId      - the placementId string of the Ad that has been dismissed
 *  @param unitId      - the unitId string of the Ad that has been dismissed
 *  @param converted   - BOOL describing whether the ad has converted
 *  @param rewardInfo  - the rewardInfo object containing the info that should be given to your user.
 */
- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo
{
    NSLog(@"MintegralAdapter onVideoAdDismissed");
    [self invalidateNetworkTimer];

    if(converted)
    {
        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:NO];
        }
    }

    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
    }
    _isCurrentRunningAdapter = NO;
}

/**
 *  Called when the ad  did closed;
 *
 *  @param unitId - the unitId string of the Ad that video play did closed.
 *  @param placementId - the placementId string of the Ad that video play did closed.
 */
- (void)onVideoAdDidClosed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
}

/**
*  Called only when the ad has a video content, and called when the video play completed.

*  @param placementId - the placementId string of the Ad that video play completed.
*  @param unitId - the unitId string of the Ad that video play completed.
*/
- (void)onVideoPlayCompleted:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
}

/**
 *  Called only when the ad has a endcard content, and called when the endcard show.
 
 *  @param placementId - the placementId string of the Ad that endcard show.
 *  @param unitId - the unitId string of the Ad that endcard show.
 */
- (void) onVideoEndCardShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
}

/**
 *  Called when the ad is clicked
 *
 *  @param placementId - the placementId string of the Ad clicked.
 *  @param unitId - the unitId string of the Ad clicked.
 */
- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId
{
    
}


#pragma mark Interstitial Delegate Methods
- (void) onInterstitialAdLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialAdLoadSuccess");
}

- (void) onInterstitialVideoLoadSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoLoadSuccess");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
    }
    [self invalidateNetworkTimer];
}

- (void) onInterstitialVideoLoadFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoLoadFail : %@", error);
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:error adapter:self];
    }
    [self invalidateNetworkTimer];
}

- (void) onInterstitialVideoShowSuccess:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoShowSuccess");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
    }
}

- (void) onInterstitialVideoShowFail:(nonnull NSError *)error adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoShowFail");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:error adapter:self];
    }
}

- (void) onInterstitialVideoAdClick:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
}

- (void)onInterstitialVideoAdDismissedWithConverted:(BOOL)converted adManager:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoAdDismissedWithConverted");
}

- (void) onInterstitialVideoAdDidClosed:(MTGInterstitialVideoAdManager *_Nonnull)adManager
{
    NSLog(@"MintegralAdapter onInterstitialVideoAdDidClosed");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
    }
    _isCurrentRunningAdapter = NO;
    [self invalidateNetworkTimer];
}

#pragma mark AdManger delegate
- (void)nativeAdsLoaded:(NSArray *)nativeAds nativeManager:(nonnull MTGNativeAdManager *)nativeManager
{
    NSLog(@"Mintegral Native ad loaded");
    @try {
        if (nativeAds.count > 0) {
            NSMutableArray *clickableViewArray = [[NSMutableArray alloc] init];
            
            MTGCampaign *campaign = nativeAds[0];
            if(mintegralNativeAdRenderer.adUIView != nil)
            {
                [clickableViewArray addObject:mintegralNativeAdRenderer.adUIView];
            }
            if(mintegralNativeAdRenderer.mMediaView != nil)
            {
                mintegralNativeAdRenderer.mMediaView.delegate = self;
                [mintegralNativeAdRenderer.mMediaView setMediaSourceWithCampaign:campaign unitId:_mintegralUnitId];
                [clickableViewArray addObject:mintegralNativeAdRenderer.mMediaView];
            }
            if(mintegralNativeAdRenderer.appNameLabel != nil)
            {
                mintegralNativeAdRenderer.appNameLabel.text = campaign.appName;
                [clickableViewArray addObject:mintegralNativeAdRenderer.appNameLabel];
            }
            if(mintegralNativeAdRenderer.appDescLabel != nil)
            {
                mintegralNativeAdRenderer.appDescLabel.text = campaign.appDesc;
                [clickableViewArray addObject:mintegralNativeAdRenderer.appDescLabel];
            }
            if(mintegralNativeAdRenderer.adCallButton != nil)
            {
                [mintegralNativeAdRenderer.adCallButton setTitle:campaign.adCall forState:UIControlStateNormal];
                [clickableViewArray addObject:mintegralNativeAdRenderer.adCallButton];
                
                // adCallButton align
                mintegralNativeAdRenderer.adCallButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                mintegralNativeAdRenderer.adCallButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            }
            if(mintegralNativeAdRenderer.iconImageView != nil)
            {
                [campaign loadIconUrlAsyncWithBlock:^(UIImage *image)
                {
                    if (image)
                    {
                        [mintegralNativeAdRenderer.iconImageView setImage:image];
                    }
                }];
                [clickableViewArray addObject:mintegralNativeAdRenderer.iconImageView];
            }
            if(mintegralNativeAdRenderer.adChoicesView != nil)
            {
                if (CGSizeEqualToSize(campaign.adChoiceIconSize, CGSizeZero))
                {
                    mintegralNativeAdRenderer.adChoicesView.hidden = YES;
                }
                else {
                    mintegralNativeAdRenderer.adChoicesView.hidden = NO;
                    mintegralNativeAdRenderer.adChoicesViewWithConstraint.constant = campaign.adChoiceIconSize.width;
                    mintegralNativeAdRenderer.adChoicesViewHeightConstraint.constant = campaign.adChoiceIconSize.height;
                    [clickableViewArray addObject:mintegralNativeAdRenderer.adChoicesView];
                }
                mintegralNativeAdRenderer.adChoicesView.campaign = campaign;
            }
            
            [mtgNativeAdManager registerViewForInteraction:mintegralNativeAdRenderer.adUIView withClickableViews:clickableViewArray withCampaign:campaign];
            
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
            }
        }
    }@catch (NSException *exception) {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPInvalidNativeAssetsConfig userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPInvalidNativeAssetsConfig)}] adapter:self];
        }
    } @finally {}
}

- (void)nativeAdsFailedToLoadWithError:(NSError *)error nativeManager:(nonnull MTGNativeAdManager *)nativeManager
{
    NSLog(@"Mintegral Native ad failed to load with error: %@", error);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
    }
}

- (void)nativeAdImpressionWithType:(MTGAdSourceType)type nativeManager:(MTGNativeAdManager *)nativeManager
{
    NSLog(@"Mintegral Native ad impressed");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
    }
}

#pragma mark MediaView delegate
- (void)MTGMediaViewWillEnterFullscreen:(MTGMediaView *)mediaView{
}

- (void)MTGMediaViewDidExitFullscreen:(MTGMediaView *)mediaView{
}

#pragma mark MediaView and AdManger Click delegate
- (void)nativeAdDidClick:(MTGCampaign *)nativeAd
{
    NSLog(@"Mintegral Registerview or mediaView Native ad clicked");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}

- (void)nativeAdDidClick:(MTGCampaign *)nativeAd nativeManager:(nonnull MTGNativeAdManager *)nativeManager
{
    NSLog(@"Mintegral Registerview ad clicked");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}
- (void)nativeAdDidClick:(MTGCampaign *)nativeAd mediaView:(nonnull MTGMediaView *)mediaView
{
    NSLog(@"Mintegral MTGMediaView ad clicked");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}
@end

@implementation APMintegralNativeAdRenderer
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
