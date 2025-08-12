//
//  PangleAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2020. 10. 28..
//  Copyright (c) 2020년 igaworks All rights reserved.
//

// compatible with Pangle v6.2.0.5
#import "PangleAdapter.h"

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

@interface PangleAdapter () <PAGRewardedAdDelegate, PAGLInterstitialAdDelegate, PAGBannerAdDelegate, PAGLNativeAdDelegate>
{
    BOOL _isCurrentRunningAdapter;
    PAGRewardedAd *rewardedVideoAd;
    PAGLInterstitialAd *interstitialVideoAd;
    NSString *pangleAppId, *panglePlacementId;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    NSMutableArray *_impTrackersListArray, *_clickTrackersListArray;
    NSString *_biddingData;
    BOOL _isInAppBidding;
    PAGBannerAd *pangleBannerAd;
    PAGLNativeAd *pangleNativeAd;
    APPangleNativeAdRenderer *pangleNativeAdRenderer;
    
    VideoMixAdType videoMixAdType;
}

@end

@implementation PangleAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 18;
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

- (void)setNativeAdViewController:(UIViewController *)viewController nativeAdRenderer:(id)nativeAdRenderer rootNativeAdView:(AdPopcornSSPNativeAd *)adpopcornSSPNativeAd
{
    _viewController = viewController;
    _adType = SSPNativeAdType;
    if([nativeAdRenderer isKindOfClass:[APPangleNativeAdRenderer class]])
        pangleNativeAdRenderer = nativeAdRenderer;
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
    return NO;
}

- (BOOL)isSupportVideoMixAd
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
    NSLog(@"PangleAdapter setInAppBiddingMode : %d", _isInAppBidding);
}

- (void)loadAd {
    NSLog(@"PangleAdapter %@ : loadAd", self);
    
    if (_adType == SSPAdBannerType) {
        [self isNotSupport:_adType];
    }
    else if (_adType == SSPNativeAdType) {
        [self isNotSupport:_adType];
    }
    else if (_adType == SSPRewardVideoAdType) {
        [self setupRewardVideo:@"RewardVideo"];
    }
    else if(_adType == SSPInterstitialVideoAdType) {
        [self setupInterstitialVideo:@"InterstitialVideo"];
    }
    else if(_adType == SSPAdInterstitialType) {
        [self isNotSupport:_adType];
        //        [self setupInterstitial:@"Interstitial"];
    }
    else if (_adType == SSPVideoMixAdType) {
        NSNumber *campaignType = [_integrationKey valueForKey:@"CampaignType"];
        NSInteger campaignValue = [campaignType integerValue];
        videoMixAdType = SSPVideoMixAdTypeFromInteger(campaignValue);
        
        switch (videoMixAdType) {
            case VideoMix_InterstitialType: // 지원 안함
                [self isNotSupport:_adType];
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

-(void)isNotSupport:(SSPAdType) adType {
    switch (adType) {
        case SSPAdBannerType:
            NSLog(@"PangleAdapter is not support :%u", _adType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            break;
        case SSPNativeAdType:
            NSLog(@"PangleAdapter is not support :%u", _adType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            break;
        case SSPAdInterstitialType:
            NSLog(@"PangleAdapter is not support :%u", _adType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            break;
        case SSPInterstitialVideoAdType:
            NSLog(@"PangleAdapter is not support :%u", _adType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            break;
        case SSPRewardVideoAdType:
            NSLog(@"PangleAdapter is not support :%u", _adType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
            break;
        case SSPVideoMixAdType:
            NSLog(@"PangleAdapter is not support :%u , videomix: %d", _adType, videoMixAdType);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter: videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
            }
            break;
        default:
            break;
    }
}

-(void)setupBanner:(NSString*) typeName {
    PAGSDKInitializationState state = PAGSdk.initializationState;
    if(state == PAGSDKInitializationStateNotReady) {
        NSLog(@"PangleAdapter PAGSDKInitializationStateNotReady");
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
        }
        PAGConfig *config = [PAGConfig shareConfig];
        config.appID = pangleAppId;
        [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self loadAdCore];
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                }
                [self closeAd];
            }
        }];
    }
    else
    {
        [self loadAdCore];
    }
}

-(void)setupNativeAd:(NSString*) typeName {
    PAGSDKInitializationState state = PAGSdk.initializationState;
    if(state == PAGSDKInitializationStateNotReady) {
        NSLog(@"PangleAdapter PAGSDKInitializationStateNotReady");
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
        }
        PAGConfig *config = [PAGConfig shareConfig];
        config.appID = pangleAppId;
        [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self loadAdCore];
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
                }
                [self closeAd];
            }
        }];
    }
    else
    {
        [self loadAdCore];
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
    
    PAGSDKInitializationState state = PAGSdk.initializationState;
    if(state == PAGSDKInitializationStateNotReady)
    {
        NSLog(@"PangleAdapter PAGSDKInitializationStateNotReady");
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
        }
        PAGConfig *config = [PAGConfig shareConfig];
        config.appID = pangleAppId;
        [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self loadAdCore];
            }
            else {
                if (_adType == SSPVideoMixAdType) {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
                    }
                    
                } else {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                    }
                }
                [self invalidateNetworkTimer];
            }
        }];
    }
    else
    {
        [self loadAdCore];
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
    
    PAGSDKInitializationState state = PAGSdk.initializationState;
    if(state == PAGSDKInitializationStateNotReady)
    {
        NSLog(@"PangleAdapter PAGSDKInitializationStateNotReady");
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
        }
        PAGConfig *config = [PAGConfig shareConfig];
        config.appID = pangleAppId;
        [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self loadAdCore];
            }
            else {
                if (_adType == SSPVideoMixAdType) {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
                    }
                } else {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                    }
                }
                [self invalidateNetworkTimer];
            }
        }];
    }
    else
    {
        [self loadAdCore];
    }
}

- (void)loadAdCore {
    if (_adType == SSPRewardVideoAdType || videoMixAdType == VideoMix_RewardVideoType)
    {
        NSLog(@"PangleAdapter %@ : SSPRewardVideoAdType loadAd", self);
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                pangleAppId = @"";
                panglePlacementId = [_integrationKey valueForKey:@"pangle_placement_id"];
            }
            else
            {
                pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
                panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            }
            
            //It is required to generate a new BURewardedVideoAd object each time calling the loadAdData method to request the latest rewarded video ad. Please do not reuse the local cache rewarded video ad.
            
            PAGRewardedRequest *request = [PAGRewardedRequest request];
            if(_isInAppBidding)
            {
                request.adString = _biddingData;
            }
            [PAGRewardedAd loadAdWithSlotID:panglePlacementId request:request completionHandler:^(PAGRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
                if (error) {
                    
                    if(_adType == SSPVideoMixAdType) {
                        NSLog(@"PangleAdapter load fail : %@", error);
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                        {
                            [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                        }
                    } else {
                        NSLog(@"PangleAdapter RV load fail : %@",error);
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                    }
                    [self invalidateNetworkTimer];
                    return;
                }
                
                NSLog(@"PangleAdapter RV load success");
                rewardedVideoAd = rewardedAd;
                rewardedVideoAd.delegate = self;
                if(_adType == SSPVideoMixAdType) {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                else {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
                    }
                }
                [self invalidateNetworkTimer];
            }];
        }
        else
        {
            NSLog(@"PangleAdapter rv no integrationKey");
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
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType || videoMixAdType == VideoMix_InterstitialVideoType)
    {
        _isCurrentRunningAdapter = YES;
        NSLog(@"PangleAdapter %@ : SSPInterstitialVideoAdType loadAd", self);
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                pangleAppId = @"";
                panglePlacementId = [_integrationKey valueForKey:@"pangle_placement_id"];
            }
            else
            {
                pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
                panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            }
            //It is required to generate a new BURewardedVideoAd object each time calling the loadAdData method to request the latest rewarded video ad. Please do not reuse the local cache rewarded video ad.
            PAGInterstitialRequest *request = [PAGInterstitialRequest request];
            if(_isInAppBidding)
            {
                request.adString = _biddingData;
            }
            [PAGLInterstitialAd loadAdWithSlotID:panglePlacementId request:request completionHandler:^(PAGLInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"PangleAdapter IV load fail : %@",error);
                        if(_adType == SSPVideoMixAdType) {
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                            {
                                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                            }
                        } else {
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                        }
                        [self invalidateNetworkTimer];
                        return;
                    }
                    interstitialVideoAd = interstitialAd;
                    interstitialVideoAd.delegate = self;
                
                    NSLog(@"PangleAdapter IV load Success");
                if(_adType == SSPVideoMixAdType) {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                } else {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
                    }
                }
                    [self invalidateNetworkTimer];
             }];
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
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPAdBannerType)
    {
        // 현재 태스트 중, 지원 안함(X)
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
        }
        
        /*NSLog(@"PangleAdapter %@ : SSPAdBannerType loadAd", self);
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                pangleAppId = @"";
                panglePlacementId = [_integrationKey valueForKey:@"pangle_placement_id"];
            }
            else
            {
                pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
                panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            }
            if(_size.width == 300.0f && _size.height == 250.0f)
            {
                pagSize = kPAGBannerSize300x250;
            }
            else if(_size.width == 320.0f && _size.height == 100.0f)
            {
                NSLog(@"PangleAdapter bannerAd 320x100 not supported");
            }
            
            PAGBannerRequest *request = [PAGBannerRequest requestWithBannerSize:pagSize];
            
            if(_isInAppBidding)
            {
                request.adString = _biddingData;
            }
            
            [PAGBannerAd loadAdWithSlotID:panglePlacementId
                                      request:request
                            completionHandler:^(PAGBannerAd * _Nullable bannerAd, NSError * _Nullable error) {
                    
                    if (error) {
                        NSLog(@"PangleAdapter bannerAd load fail : %@",error);
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                        {
                          [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        [self closeAd];
                        return;
                    }

                    pangleBannerAd = bannerAd;
                    pangleBannerAd.delegate = self;
                    pangleBannerAd.rootViewController = _viewController;
                
                    [_bannerView addSubview:pangleBannerAd.bannerView];

                }];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }*/
    }
    else if(_adType == SSPNativeAdType)
    {
        NSLog(@"PangleAdapter %@ : SSPNativeAdType loadAd", self);
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                pangleAppId = @"";
                panglePlacementId = [_integrationKey valueForKey:@"pangle_placement_id"];
            }
            else
            {
                pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
                panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            }
            
            PAGNativeRequest *request = [PAGNativeRequest request];
            if(_isInAppBidding)
            {
                request.adString = _biddingData;
            }
            
            [PAGLNativeAd loadAdWithSlotID:panglePlacementId request:PAGNativeRequest.request
                             completionHandler:^(PAGLNativeAd * _Nullable nativeAd, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"PangleAdapter native load fail : %@",error);
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        return;
                    }
                    pangleNativeAd = nativeAd;
                    pangleNativeAd.delegate = self;
                
                    NSLog(@"PangleAdapter native load Success");
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
                    }
             }];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }
    }

}

- (void)showAd
{
    NSLog(@"PangleAdapter : showAd");
    if (_adType == SSPRewardVideoAdType)
    {
        if (rewardedVideoAd) {
             [rewardedVideoAd presentFromRootViewController:_viewController];
        }
        else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if(interstitialVideoAd){
            [interstitialVideoAd presentFromRootViewController:_viewController];
        }
        else{
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;

            case VideoMix_InterstitialVideoType:
                if(interstitialVideoAd){
                    [interstitialVideoAd presentFromRootViewController:_viewController];
                }
                else{
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self videoMixType:videoMixAdType];
                    }
                }
                break;

            case VideoMix_RewardVideoType:
                if (rewardedVideoAd) {
                     [rewardedVideoAd presentFromRootViewController:_viewController];
                }
                else {
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
    NSLog(@"PangleAdapter closeAd");
    _isCurrentRunningAdapter = NO;
}

- (void)addAlignCenterConstraint
{
    if(pangleBannerAd.bannerView.constraints)
    {
        [pangleBannerAd.bannerView removeConstraints:pangleBannerAd.bannerView.constraints];
    }
    
    // add constraints
    [pangleBannerAd.bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:pangleBannerAd.bannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:pangleBannerAd.bannerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:pangleBannerAd.bannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:pangleBannerAd.bannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}

- (void)loadRequest
{
    // Not used any more
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"PangleAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"PangleAdapter iv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        NSLog(@"PangleAdapter videomix load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
        }
    }
    [self invalidateNetworkTimer];
}

-(void)invalidateNetworkTimer
{
    if(networkScheduleTimer != nil)
        [networkScheduleTimer invalidate];
}

- (NSString *)getBiddingToken
{
    return [PAGSdk getBiddingToken:nil];
}

#pragma mark PAGRewardedAdDelegate, PAGLInterstitialAdDelegate, PAGBannerAdDelegate, PAGLNativeAdDelegate
- (void)adDidShow:(id<PAGAdProtocol>)ad {
    NSLog(@"PangleAdapter adDidShow : %d", _adType);
    if(_adType == SSPRewardVideoAdType)
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
    else if(_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
        }
    }
    else if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
        }
    }
    else if(_adType == SSPVideoMixAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowSuccess:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdShowSuccess:self videoMixType:videoMixAdType];
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

- (void)adDidClick:(id<PAGAdProtocol>)ad {
    NSLog(@"PangleAdapter adDidClick : %d", _adType);
    if(_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
        }
    }
    else if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
        }
    }
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

- (void)adDidDismiss:(id<PAGAdProtocol>)ad {
    NSLog(@"PangleAdapter adDidDismiss : %d", _adType);
    if(_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
        }
        _isCurrentRunningAdapter = NO;
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
        _isCurrentRunningAdapter = NO;
    }
    else if(_adType == SSPVideoMixAdType) {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdClose:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdClose:self videoMixType:videoMixAdType];
        }
        _isCurrentRunningAdapter = NO;
    }
    else if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdHidden:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdHidden:self];
        }
    }
}

#pragma mark PAGRewardedAdDelegate
- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userDidEarnReward:(PAGRewardModel *)rewardModel {
    if(_adType == SSPVideoMixAdType) {
        NSLog(@"PangleAdapter VideoMix_reward earned! rewardName:%@ rewardMount:%ld",rewardModel.rewardName,(long)rewardModel.rewardAmount);
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:isCompleted:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdCompleteTrackingEvent:adNetworkNo isCompleted:YES videoMixType:videoMixAdType];
        }
    }
    else {
        NSLog(@"PangleAdapter reward earned! rewardName:%@ rewardMount:%ld",rewardModel.rewardName,(long)rewardModel.rewardAmount);
        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
        }
    }
}
@end

@implementation APPangleNativeAdRenderer
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
