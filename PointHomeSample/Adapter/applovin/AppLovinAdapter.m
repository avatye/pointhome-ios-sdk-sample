//
//  AppLovinAdapter.m
//  AdPopcornSSP
//
//  Created by 김민석 on 2022/03/31.
//  Copyright © 2022 AdPopcorn. All rights reserved.
//

// compatible with AppLovin v13.0.1
#import "AppLovinAdapter.h"

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

@interface AppLovinAdapter () <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdViewEventDelegate, ALAdRewardDelegate, ALAdVideoPlaybackDelegate>
{
    BOOL _isCurrentRunningAdapter;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    BOOL _isRewardVerified;
    BOOL _isMute;
    
    VideoMixAdType videoMixAdType;
}

- (void)addAlignCenterConstraint;
@end

@implementation AppLovinAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 15;
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

- (void)setVideoMixAdViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPVideoMixAdType;
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
    return NO;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (BOOL)isSupportVideoMixAd
{
    return YES;
}

- (void)setMute:(bool)mute
{
    _isMute = mute;
}

- (void)loadAd
{
    if (_adType == SSPAdBannerType) {
        [self setupBanner:@"Banner"];
    }
    else if (_adType == SSPNativeAdType) {
        
    }
    else if (_adType == SSPRewardVideoAdType) {
        [self setupRewardVideo:@"RewardVideo"];
    }
    else if(_adType == SSPInterstitialVideoAdType) {
        [self setupInterstitialVideo:@"InterstitialVideo"];
    }
    else if(_adType == SSPAdInterstitialType) {
        [self setupInterstitial:@"Interstitial"];
    }
    else if (_adType == SSPVideoMixAdType) {
        NSNumber *campaignType = [_integrationKey valueForKey:@"CampaignType"];
        NSInteger campaignValue = [campaignType integerValue];
        videoMixAdType = SSPVideoMixAdTypeFromInteger(campaignValue);
        
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                [self setupInterstitial:@"VideoMix_Interstitial"];
                break;
                
            case VideoMix_InterstitialVideoType:
                [self setupInterstitialVideo:@"VideoMix_InterstitialVIdeo"];
                break;
                
            case VideoMix_RewardVideoType:
                [self setupRewardVideo:@"VideoMix_RewardVideo"];
                break;
        }
    }
}

-(void)setupBanner:(NSString*) typeName {
    if (_integrationKey != nil)
    {
        NSString *zoneId = [_integrationKey valueForKey:@"AppLovinZoneId"];
        NSLog(@"AppLovinAdapter SSPAdBannerType zoneId : %@", zoneId);
        if(_size.width == 320.0f && _size.height == 50.0f)
        {
            appLovinBannerAdView = [[ALAdView alloc] initWithSize: [ALAdSize banner] zoneIdentifier:zoneId];
            appLovinBannerAdView.frame = CGRectMake(0, 0, 320, 50);
        }
        else if(_size.width == 300.0f && _size.height == 250.0f)
        {
            appLovinBannerAdView = [[ALAdView alloc] initWithSize: [ALAdSize mrec] zoneIdentifier:zoneId];
            appLovinBannerAdView.frame = CGRectMake(0, 0, 300, 250);
        }
        else
        {
            NSLog(@"%@ : AppLovinAdapter can not load 320x100", self);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            
            [self closeAd];
            return;
        }
        appLovinBannerAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        appLovinBannerAdView.adLoadDelegate = self;
        appLovinBannerAdView.adDisplayDelegate = self;
        appLovinBannerAdView.adEventDelegate = self;
        
        // add banner view
        [_bannerView addSubview:appLovinBannerAdView];
        
        [self addAlignCenterConstraint];
        
        // load request
        [appLovinBannerAdView loadNextAd];
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

-(void)setupInterstitial:(NSString*) typeName {
    if (_integrationKey != nil)
    {
        NSString *zoneId = [_integrationKey valueForKey:@"AppLovinZoneId"];
        NSLog(@"AppLovinAdapter SSPAdInterstitialType zoneId : %@", zoneId);
        
        //[[ALSdk shared].adService loadNextAd: [ALAdSize interstitial] andNotify: self];
        [[ALSdk shared].adService loadNextAdForZoneIdentifier:zoneId andNotify:self];
    }
    else
    {
        if(_adType == SSPVideoMixAdType) {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }
        [self closeAd];
    }
}
-(void)setupInterstitialVideo:(NSString*) typeName {
    if(networkScheduleTimer == nil)
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    _isCurrentRunningAdapter = YES;
    
    if (_integrationKey != nil)
    {
        NSString *zoneId = [_integrationKey valueForKey:@"AppLovinZoneId"];
        NSLog(@"AppLovinAdapter SSPInterstitialVideoAdType zoneId : %@", zoneId);
        
        //[[ALSdk shared].adService loadNextAd: [ALAdSize interstitial] andNotify: self];
        [[ALSdk shared].adService loadNextAdForZoneIdentifier:zoneId andNotify: self];
    }
    else
    {
        if(_adType == SSPVideoMixAdType) {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
        } else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }
        [self closeAd];
    }
}
-(void)setupRewardVideo:(NSString*) typeName {
    if(networkScheduleTimer == nil)
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    
    _isCurrentRunningAdapter = YES;
    _isRewardVerified = NO;
    if (_integrationKey != nil)
    {
        NSString *zoneId = [_integrationKey valueForKey:@"AppLovinZoneId"];
        NSLog(@"AppLovinAdapter SSPRewardVideoAdType zoneId : %@", zoneId);
        rewardVideoAd = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier: zoneId];
        [rewardVideoAd preloadAndNotify:self];
    }
    else
    {
        if(_adType == SSPVideoMixAdType) {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }

        } else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }
        [self closeAd];
    }
}


- (void)showAd
{
    NSLog(@"AppLovinAdapter : showAd %d", _adType);
    if (_adType == SSPAdInterstitialType)
    {
        [ALInterstitialAd shared].adDisplayDelegate = self;
        [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
        [[ALInterstitialAd shared] showAd:interstitialAd];
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        if(_isMute)
            [ALSdk shared].settings.muted = YES;
        // Check to see if an ad is ready before attempting to show
        if ( [rewardVideoAd isReadyForDisplay] )
        {
            rewardVideoAd.adDisplayDelegate = self;
            rewardVideoAd.adVideoPlaybackDelegate = self;
            // Show call if using a reward delegate.
            [rewardVideoAd showAndNotify:self];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if (_adType == SSPInterstitialVideoAdType)
    {
        if(_isMute)
            [ALSdk shared].settings.muted = YES;
        [ALInterstitialAd shared].adDisplayDelegate = self;
        [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
        [[ALInterstitialAd shared] showAd:interstitialVideoAd];
    }
    else if (_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                [ALInterstitialAd shared].adDisplayDelegate = self;
                [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
                [[ALInterstitialAd shared] showAd:interstitialAd];
                break;
                
            case VideoMix_InterstitialVideoType:
                if(_isMute)
                    [ALSdk shared].settings.muted = YES;
                [ALInterstitialAd shared].adDisplayDelegate = self;
                [ALInterstitialAd shared].adVideoPlaybackDelegate = self;
                [[ALInterstitialAd shared] showAd:interstitialVideoAd];
                break;
                
            case VideoMix_RewardVideoType:
                if(_isMute)
                    [ALSdk shared].settings.muted = YES;
                // Check to see if an ad is ready before attempting to show
                if ( [rewardVideoAd isReadyForDisplay] )
                {
                    rewardVideoAd.adDisplayDelegate = self;
                    rewardVideoAd.adVideoPlaybackDelegate = self;
                    // Show call if using a reward delegate.
                    [rewardVideoAd showAndNotify:self];
                }
                else
                {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self videoMixType:videoMixAdType];
                    }
                }
                break;
        }
    }
}

- (void)closeAd
{
    NSLog(@"AppLovinAdapter : closeAd : %d", _adType);
   if (_adType == SSPRewardVideoAdType)
    {
        _isCurrentRunningAdapter = NO;
        [self invalidateNetworkTimer];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        _isCurrentRunningAdapter = NO;
        [self invalidateNetworkTimer];
    } else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;
                
            case VideoMix_InterstitialVideoType:
                _isCurrentRunningAdapter = NO;
                [self invalidateNetworkTimer];
                break;
                
            case VideoMix_RewardVideoType:
                _isCurrentRunningAdapter = NO;
                [self invalidateNetworkTimer];
                break;
        }
    }
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"AppLovinAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"AppLovinAdapter iv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;
                
            case VideoMix_InterstitialVideoType:
                NSLog(@"AppLovinAdapter VideoMix_InterstitialVideo load timeout");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                }
                break;
                
            case VideoMix_RewardVideoType:
                NSLog(@"AppLovinAdapter VideoMix_RewardVideo load timeout");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                }
                break;
        }
    }
    [self invalidateNetworkTimer];
}

-(void)invalidateNetworkTimer
{
    if(networkScheduleTimer != nil)
        [networkScheduleTimer invalidate];
}

- (void)addAlignCenterConstraint
{
    // add constraints
    [appLovinBannerAdView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:appLovinBannerAdView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:appLovinBannerAdView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:appLovinBannerAdView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:appLovinBannerAdView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}

#pragma mark - Ad Load Delegate
- (void)adService:(nonnull ALAdService *)adService didLoadAd:(nonnull ALAd *)ad
{
    // We now have an interstitial ad we can show!
    NSLog(@"AppLovinAdapter : didLoadAd %d", _adType);
    [self invalidateNetworkTimer];
    if (_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
        }
    }
    else if (_adType == SSPAdInterstitialType)
    {
        interstitialAd = ad;
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadSuccess:self];
        }
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
        }
    }
    else if (_adType == SSPInterstitialVideoAdType)
    {
        interstitialVideoAd = ad;
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
        }
    }
    else if (_adType == SSPVideoMixAdType)
    {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                interstitialVideoAd = ad;
                break;
                
            case VideoMix_InterstitialVideoType:
                interstitialVideoAd = ad;
                break;
                
            case VideoMix_RewardVideoType:
                break;
        }
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
        }
    }
}

- (void)adService:(nonnull ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    // Look at ALErrorCodes.h for the list of error codes.
    NSLog(@"AppLovinAdapter : didFailToLoadAdWithError %d, error : %d", _adType, code);
    if (_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
        
        [self closeAd];
    }
    else if (_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
        [self closeAd];
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
        [self closeAd];
    }
    else if (_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
        [self closeAd];
    }
    else if (_adType == SSPVideoMixAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
        }
        [self closeAd];
    }
}

#pragma mark - ALAdDisplayDelegate Methods
- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    NSLog(@"AppLovinAdapter didClickAd : %@", ad);
    if (_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
        }
    }
    else if(_adType == SSPAdInterstitialType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClicked:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdClicked:self];
        }
    }
    else if(_adType == SSPVideoMixAdType){
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdClicked:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdClicked:self videoMixType:videoMixAdType];
                }
                break;
                
            case VideoMix_InterstitialVideoType:
                break;
                
            case VideoMix_RewardVideoType:
                break;
        }
    }
}

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    NSLog(@"AppLovinAdapter wasDisplayedIn : %@", ad);
    if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdShowSuccess:self];
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
        }
    }
    else if(_adType == SSPVideoMixAdType){
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowSuccess:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdShowSuccess:self videoMixType:videoMixAdType];
                }
                break;
                
            default:
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowSuccess:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdShowSuccess:self videoMixType:videoMixAdType];
                }
                break;
        }
    }
}
- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    NSLog(@"AppLovinAdapter wasHiddenIn : %@", ad);
    if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClosed:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdClosed:self];
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
    }
    else if(_adType == SSPVideoMixAdType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdClose:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdClose:self videoMixType:videoMixAdType];
        }
    }
}
#pragma mark ALAdVideoPlaybackDelegate
- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    NSLog(@"AppLovinAdapter videoPlaybackEndedInAd %d, wasFullyWatched %d", _isRewardVerified, wasFullyWatched);
    if(_adType == SSPRewardVideoAdType){
        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:_isRewardVerified];
        }
    }
    else if(_adType == SSPVideoMixAdType){
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;
                
            case VideoMix_InterstitialVideoType:
                break;
                
            case VideoMix_RewardVideoType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:isCompleted:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:adNetworkNo isCompleted:_isRewardVerified videoMixType:videoMixAdType];
                }
                break;
        }
    }
    _isCurrentRunningAdapter = NO;
}

#pragma mark ALAdRewardDelegate
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response
{
    NSLog(@"AppLovinAdapter rewardValidationRequestForAd : didSucceedWithResponse");
    _isRewardVerified = YES;
}

- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response
{
    NSLog(@"AppLovinAdapter rewardValidationRequestForAd : wasRejectedWithResponse");
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response
{
    NSLog(@"AppLovinAdapter rewardValidationRequestForAd : didExceedQuotaWithResponse : %@", response);
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    NSLog(@"AppLovinAdapter rewardValidationRequestForAd : didFailWithError : %ld", responseCode);
}

@end
