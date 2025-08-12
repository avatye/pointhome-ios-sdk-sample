//
//  AdMobAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2017. 8. 2..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

// compatible with AdMob v11.10.0
#import "AdMobAdapter.h"

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
        case AdPopcornSSPNoVideoMixAdLoaded:
            return @"No videoMix ad Loaded";
        case AdPopcornSSPMediationAdapterNotInitialized:
            return @"Mediation Adapter Not Initialized";
        default: {
            return @"Success";
        }
    }
}

@interface AdMobAdapter () <GADBannerViewDelegate, GADFullScreenContentDelegate, GADAdLoaderDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate>
{
    NSString *_rewardVideoAdUnitId, *_interstitialVideoAdUnitId;
    BOOL _isCurrentRunningAdapter;
    APAdMobNativeAdRenderer *adMobNativeAdRenderer;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    
    VideoMixAdType videoMixAdType;
}

- (void)addAlignCenterConstraint;
@end

@implementation AdMobAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 1;
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
    if([nativeAdRenderer isKindOfClass:[APAdMobNativeAdRenderer class]])
        adMobNativeAdRenderer = nativeAdRenderer;
    _adpopcornSSPNativeAd = adpopcornSSPNativeAd;
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
    return YES;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (BOOL)isSupportVideoMixAd
{
    return YES;
}

- (void)loadAd {
    if (_adType == SSPAdBannerType)
    {
        [self setupBanner:@"Banner"];
    }
    else if (_adType == SSPAdInterstitialType)
    {
        [self setupInterstitial:@"Interstitial"];
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        [self setupRewardVideo:@"RewardVideo"];
    }
    else if(_adType == SSPNativeAdType)
    {
        [self setupNative:@"Native"];
    }
    else if(_adType == SSPInterstitialVideoAdType) {
        [self setupInterstitialVideo:@"InterstitialVideo"];
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
        NSString *adUnitID = [_integrationKey valueForKey:@"adUnitID"];
        NSLog(@"AdMobAdapter SSPAdBannerType adUnitID : %@", adUnitID);
        
        if(_size.width == 320.0f && _size.height == 100.0f)
        {
            _adBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeLargeBanner origin:CGPointMake(0.0f, 0.0f)];
        }
        else if(_size.width == 300.0f && _size.height == 250.0f)
        {
            _adBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeMediumRectangle origin:CGPointMake(0.0f, 0.0f)];
        }
        else
        {
            _adBannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner origin:CGPointMake(0.0f, 0.0f)];
        }
        _adBannerView.adUnitID = adUnitID;
        _adBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // add banner view
        [_bannerView addSubview:_adBannerView];
        
        [self addAlignCenterConstraint];
        
        _adBannerView.delegate = self;
        _adBannerView.rootViewController = _viewController;
        
        // load request
        [_adBannerView loadRequest:[GADRequest request]];
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

-(void)setupNative:(NSString*) typeName {
    if(_integrationKey != nil)
    {
        NSString *adUnitID = [_integrationKey valueForKey:@"adUnitID"];
        NSLog(@"AdMobAdapter SSPNativeAdType adUnitID : %@", adUnitID);
        _adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitID rootViewController:_viewController adTypes:@[GADAdLoaderAdTypeNative] options:nil];
        _adLoader.delegate = self;
        [_adLoader loadRequest:[GADRequest request]];
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

-(void)setupInterstitial:(NSString*) typeName {
    
    if (_integrationKey != nil) {
        NSString *adUnitID = [_integrationKey valueForKey:@"adUnitID"];
        
        NSLog(@"AdMobAdapter %@ adUnitID: %@", typeName, adUnitID);
        
        [GADInterstitialAd loadWithAdUnitID:adUnitID
                                    request:[GADRequest request] completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            if (error)
            {
                if (videoMixAdType == VideoMix_InterstitialType) {
                    NSLog(@"AdMobAdapter %@ load error: %@", typeName, [error localizedDescription]);
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:error adapter:self videoMixType:videoMixAdType];
                    }
                    [self closeAd];
                }
                else {
                    NSLog(@"AdMobAdapter interstitial load error: %@", [error localizedDescription]);
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:error adapter:self];
                    }
                    [self closeAd];
                }
            }
            else {
                _interstitial = ad;
                _interstitial.fullScreenContentDelegate = self;
                
                if(videoMixAdType == VideoMix_InterstitialType) {
                    NSLog(@"AdMobAdapter %@ load success", typeName);
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                else {
                    NSLog(@"AdMobAdapter %@ load success", typeName);
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialAdLoadSuccess:self];
                    }
                }
            }
        }];
    }
    else {
        
        if (_adType == SSPVideoMixAdType) {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
        }
        else {
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
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    _isCurrentRunningAdapter = YES;
    
    
    if (_integrationKey != nil) {
        NSString *adUnitID = [_integrationKey valueForKey:@"adUnitID"];
        [GADInterstitialAd loadWithAdUnitID:adUnitID
                                    request:[GADRequest request] completionHandler:^(GADInterstitialAd *ad, NSError *error) {
            [self invalidateNetworkTimer];
            if (error)
            {
                if(_adType == SSPVideoMixAdType) {
                    NSLog(@"AdMobAdapter  %@ interstitial video error %@", typeName, error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:error adapter:self videoMixType:videoMixAdType];
                    }
                    [self closeAd];
                }
                else {
                    NSLog(@"AdMobAdapter  %@ interstitial video error %@", typeName, error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:error adapter:self];
                    }
                    [self closeAd];
                }
            }
            else {
                if(_adType == SSPVideoMixAdType) {
                    NSLog(@"AdMobAdapter %@ load success", typeName);
                    _interstitialVideo = ad;
                    _interstitialVideo.fullScreenContentDelegate = self;
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                else {
                    NSLog(@"AdMobAdapter %@ load success", typeName);
                    _interstitialVideo = ad;
                    _interstitialVideo.fullScreenContentDelegate = self;
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
                    }
                }
            }
        }];
    }
    else {
        if (_adType == SSPVideoMixAdType) {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
        }
        else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
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
    if (_integrationKey != nil) {
        _rewardVideoAdUnitId = [_integrationKey valueForKey:@"adUnitID"];
        
        [GADRewardedAd loadWithAdUnitID:_rewardVideoAdUnitId request:[GADRequest request] completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
                if (videoMixAdType == VideoMix_RewardVideoType) {
                    NSLog(@"AdMobAdapter %@ ad failed to load : %@", typeName, [error localizedDescription]);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:error adapter:self videoMixType:videoMixAdType];
                    }
                    [self invalidateNetworkTimer];
                    [self closeAd];
                }
                else {
                    NSLog(@"AdMobAdapter %@ ad failed to load : %@", typeName, [error localizedDescription]);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:error adapter:self];
                    }
                    [self invalidateNetworkTimer];
                    [self closeAd];
                }
            }
            else {
                if (_adType == SSPVideoMixAdType) {
                    NSLog(@"AdMobAdapter  %@ load success", typeName);
                    
                    _rewardedAd = ad;
                    _rewardedAd.fullScreenContentDelegate = self;
                    
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                    [self invalidateNetworkTimer];
                }
                else {
                    NSLog(@"AdMobAdapter  %@ load success", typeName);
                    
                    _rewardedAd = ad;
                    _rewardedAd.fullScreenContentDelegate = self;
                    
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
                    }
                    [self invalidateNetworkTimer];
                }
            }
        }];
    }
    else {
        if (_adType == SSPVideoMixAdType) {
            NSLog(@"AdMobAdapter  %@ load success", typeName);
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
            
        }
        else {
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
    NSLog(@"AdMobAdapter : showAd %d", _adType);
    if (_adType == SSPAdInterstitialType)
    {
        if(_interstitial)
        {
            [_interstitial presentFromRootViewController:_viewController];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialLoaded)}] adapter:self];
            }
        }
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        if (_rewardedAd) {
            [_rewardedAd presentFromRootViewController:_viewController
              userDidEarnRewardHandler:^{
                NSLog(@"AdMobAdapter reward Video didRewardUserWithReward.");
                if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
                {
                    [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
                }
                _isCurrentRunningAdapter = NO;
            }];
        }
    }
    else if (_adType == SSPInterstitialVideoAdType)
    {
        if (_interstitialVideo) {
            [_interstitialVideo presentFromRootViewController:_viewController];
        }
        else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if (_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if(_interstitial) {
                    [_interstitial presentFromRootViewController:_viewController];
                }
                else
                {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoVideoMixAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoVideoMixAdLoaded)}] adapter:self videoMixType: videoMixAdType];
                    }
                }
                break;
                
            case VideoMix_InterstitialVideoType:
                if(_interstitialVideo) {
                    [_interstitialVideo presentFromRootViewController:_viewController];
                }
                else
                {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoVideoMixAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoVideoMixAdLoaded)}] adapter:self videoMixType: videoMixAdType];
                    }
                }
                break;
                
            case VideoMix_RewardVideoType:
                if (_rewardedAd) {
                    [_rewardedAd presentFromRootViewController:_viewController
                      userDidEarnRewardHandler:^{
                        NSLog(@"AdMobAdapter reward Video didRewardUserWithReward.");
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:isCompleted:videoMixType:)])
                        {
                            [_delegate AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:adNetworkNo isCompleted:YES videoMixType:videoMixAdType];
                        }
                        _isCurrentRunningAdapter = NO;
                    }];
                }
                else {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoVideoMixAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoVideoMixAdLoaded)}] adapter:self videoMixType: videoMixAdType];
                    }
                }
                break;
        }
    }
}

- (void)closeAd
{
    NSLog(@"AdMobAdapter : closeAd : %d", _adType);
    if (_adType == SSPAdBannerType)
    {
        [_adBannerView removeFromSuperview];
        _adBannerView.delegate = nil;
        _adBannerView = nil;
    }
    else if (_adType == SSPAdInterstitialType)
    {
        _interstitial.fullScreenContentDelegate = nil;
        _interstitial = nil;
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        _isCurrentRunningAdapter = NO;
        [self invalidateNetworkTimer];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        _isCurrentRunningAdapter = NO;
        [self invalidateNetworkTimer];
        _interstitialVideo.fullScreenContentDelegate = nil;
        _interstitialVideo = nil;
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                _interstitial.fullScreenContentDelegate = nil;
                _interstitial = nil;
                break;
                
            case VideoMix_InterstitialVideoType:
                _isCurrentRunningAdapter = NO;
                [self invalidateNetworkTimer];
                _interstitialVideo.fullScreenContentDelegate = nil;
                _interstitialVideo = nil;
                break;
                
            case VideoMix_RewardVideoType:
                _isCurrentRunningAdapter = NO;
                [self invalidateNetworkTimer];
                _rewardedAd.fullScreenContentDelegate = nil;
                _rewardedAd = nil;
                break;
        }
    }
}

- (void)loadRequest
{
    // Not used any more
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"AdMob rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"AdMob iv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if (_adType == SSPVideoMixAdType) {
        NSLog(@"AdMob VideoMixAd load timeout");
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;
                
            default:
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
    [_adBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}

#pragma mark - GADBannerViewDelegate
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"AdMobAdapter Banner : %@", bannerView);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"AdMobAdapter Banner : %@, error : %@", bannerView, error);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:error adapter:self];
    }
    
    [self closeAd];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView
{
    NSLog(@"AdMobAdapter Banner adViewWillPresentScreen");
}

#pragma mark - GADFullScreenContentDelegate
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"AdMobAdapter didFailToPresentFullScreenContentWithError : %d", _adType);
    if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType){
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoVideoMixAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoVideoMixAdLoaded)}] adapter:self videoMixType:videoMixAdType];
        }
    }
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"AdMobAdapter adDidPresentFullScreenContent : %d", _adType);
    
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"AdMobAdapter adWillPresentFullScreenContent : %d", _adType);
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
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if  ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowSuccess:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdShowSuccess:self videoMixType:videoMixAdType];
                }
                break;
                
            default:
                if  (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowSuccess:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdShowSuccess:self videoMixType:videoMixAdType];
                }
                break;
        }
    }
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"AdMobAdapter adDidDismissFullScreenContent : %d", _adType);
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
    else if(_adType == SSPVideoMixAdType) {
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdClose:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdClose:self videoMixType:videoMixAdType];
        }
    }
}


#pragma mark GADAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error;
{
    NSLog(@"AdMobAdapter GADAdLoaderDelegate didFailToReceiveAdWithError");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
    }
}

#pragma mark GADNativeAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    // A native ad has loaded, and can be displayed.
    NSLog(@"AdMobAdapter GADNativeAdLoaderDelegate didReceiveNativeAd: %@", nativeAd);
    nativeAd.delegate = self;
    
    // Create and place ad in view hierarchy.
    if(adMobNativeAdRenderer != nil && adMobNativeAdRenderer.admobNativeAdView != nil)
    {
        GADNativeAdView *nativeAdView = (GADNativeAdView *)adMobNativeAdRenderer.admobNativeAdView;
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        nativeAdView.nativeAd = nativeAd;
        
        // Set the mediaContent on the GADMediaView to populate it with available
        // video/image asset.
        if(nativeAdView.mediaView != nil)
            nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
        
        // Populate the native ad view with the native ad assets.
        // The headline is guaranteed to be present in every native ad.
        if(nativeAdView.headlineView != nil)
            ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        if(nativeAdView.bodyView != nil)
        {
            ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
            nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
        }
        
        if(nativeAdView.callToActionView != nil)
        {
            [((UIButton *)nativeAdView.callToActionView)setTitle:nativeAd.callToAction
                                                    forState:UIControlStateNormal];
            nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
            
            // adCallButton align
            ((UIButton *)nativeAdView.callToActionView).titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            ((UIButton *)nativeAdView.callToActionView).titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        if(nativeAdView.iconView != nil)
        {
            ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
            nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
        }
        
        if(nativeAdView.storeView != nil)
        {
            ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
            nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;
        }
        if(nativeAdView.priceView != nil)
        {
            ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
            nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;
        }
        if(nativeAdView.advertiserView != nil)
        {
            ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
            nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
        }
        // In order for the SDK to process touch events properly, user interaction
        // should be disabled.
        if(nativeAdView.callToActionView != nil)
            nativeAdView.callToActionView.userInteractionEnabled = NO;
        
        [_adpopcornSSPNativeAd addSubview:nativeAdView];
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPInvalidNativeAssetsConfig userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPInvalidNativeAssetsConfig)}] adapter:self];
        }
    }
}
#pragma GADNativeAdDelegate
- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
  // The native ad was shown.
    NSLog(@"AdMobAdapter nativeAdDidRecordImpression");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
    }
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  // The native ad was clicked on.
    NSLog(@"AdMobAdapter nativeAdDidRecordClick");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
    {
        [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
    }
}
@end


@implementation APAdMobNativeAdRenderer
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
