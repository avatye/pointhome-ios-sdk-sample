//
//  UnityAdsAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.

// compatible with UnityAds v4.12.5
#import "UnityAdsAdapter.h"

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

@interface UnityAdsAdapter () <UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsShowDelegate>
{
    NSString *_unityAdsRewardPlacementId, *_unityAdsInterstitialVideoPlacementId, *_unityAdsInterstitialPlacementId;
    BOOL _isCurrentRunningAdapter;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    BOOL isTestMode;
    
    VideoMixAdType videoMixAdType;
}

@end

@implementation UnityAdsAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    adNetworkNo = 7;
    isTestMode = NO;
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

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (BOOL)isSupportVideoMixAd
{
    return YES;
}

- (void)loadAd {
    NSLog(@"UnityAdsAdapter %@ : loadAd", self);
    if (_adType == SSPAdBannerType) {
        
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

-(void)setupInterstitial:(NSString*) typeName {
    if (_integrationKey != nil)
    {
        NSString *_unityAdsGameId = [_integrationKey valueForKey:@"UnityGameId"];
        _unityAdsInterstitialPlacementId = [_integrationKey valueForKey:@"UnityPlacementId"];
        
        if([UnityAds isInitialized])
        {
            NSLog(@"UnityAds isInitialized true");
            [UnityAds load:_unityAdsInterstitialPlacementId loadDelegate:self];
        }
        else{
            NSLog(@"UnityAds try initialize");
            [UnityAds initialize:_unityAdsGameId testMode:isTestMode initializationDelegate:self];
        }
    }
    else {
        
        if (videoMixAdType == VideoMix_InterstitialType) {
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
    if (_integrationKey != nil)
    {
        NSString *_unityAdsGameId = [_integrationKey valueForKey:@"UnityGameId"];
        _unityAdsInterstitialVideoPlacementId = [_integrationKey valueForKey:@"UnityPlacementId"];
        
        if([UnityAds isInitialized])
        {
            NSLog(@"UnityAds isInitialized true");
            [UnityAds load:_unityAdsInterstitialVideoPlacementId loadDelegate:self];
        }
        else{
            NSLog(@"UnityAds try initialize");
            [UnityAds initialize:_unityAdsGameId testMode:isTestMode initializationDelegate:self];
        }
    }
    else {
        if (videoMixAdType == VideoMix_InterstitialVideoType) {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
            {
                [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self videoMixType:videoMixAdType];
            }
        }
        else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
        }
        [self invalidateNetworkTimer];
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
    if (_integrationKey != nil)
    {
        NSString *_unityAdsGameId = [_integrationKey valueForKey:@"UnityGameId"];
        _unityAdsRewardPlacementId = [_integrationKey valueForKey:@"UnityPlacementId"];
        
        if([UnityAds isInitialized])
        {
            NSLog(@"UnityAds isInitialized true");
            [UnityAds load:_unityAdsRewardPlacementId loadDelegate:self];
        }
        else{
            NSLog(@"UnityAds try initialize");
            [UnityAds initialize:_unityAdsGameId testMode:isTestMode initializationDelegate:self];
        }
    }
    else
    {
        if (videoMixAdType == VideoMix_RewardVideoType) {
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
        [self invalidateNetworkTimer];
    }
}

- (void)showAd
{
    NSLog(@"UnityAdsAdapter %@ : showAd", self);
    if (_adType == SSPRewardVideoAdType)
    {
        [UnityAds show:self.viewController placementId:_unityAdsRewardPlacementId showDelegate:self];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [UnityAds show:self.viewController placementId:_unityAdsInterstitialVideoPlacementId showDelegate:self];
    }
    else if(_adType == SSPAdInterstitialType)
    {
        [UnityAds show:self.viewController placementId:_unityAdsInterstitialPlacementId showDelegate:self];
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                [UnityAds show:self.viewController placementId:_unityAdsInterstitialPlacementId showDelegate:self];
                break;
                
            case VideoMix_InterstitialVideoType:
                [UnityAds show:self.viewController placementId:_unityAdsInterstitialPlacementId showDelegate:self];
                break;
                
            case VideoMix_RewardVideoType:
                [UnityAds show:self.viewController placementId:_unityAdsRewardPlacementId showDelegate:self];
                break;
        }
    }
}

- (void)closeAd
{
    NSLog(@"UnityAdsAdapter closeAd");
    _isCurrentRunningAdapter = NO;
}

- (void)loadRequest
{
    // Not used any more
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"UnityAds rewardVideo load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"UnityAds interstitialVideo load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if (_adType == SSPVideoMixAdType) {
        NSLog(@"UnityAds VideoMix_interstitialVideo load timeout");
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                }
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

// Implement initialization callbacks to handle success or failure:
#pragma mark : UnityAdsInitializationDelegate
- (void)initializationComplete {
    NSLog(@" - UnityAdsInitializationDelegate initializationComplete" );
    // Pre-load an ad when initialization succeeds, so it is ready to show:
    if(_adType == SSPRewardVideoAdType)
    {
        [UnityAds load:_unityAdsRewardPlacementId loadDelegate:self];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [UnityAds load:_unityAdsInterstitialVideoPlacementId loadDelegate:self];
    }
    else if(_adType == SSPAdInterstitialType)
    {
        [UnityAds load:_unityAdsInterstitialPlacementId loadDelegate:self];
    }
    else if(_adType == SSPAdInterstitialType){
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                [UnityAds load: _unityAdsInterstitialPlacementId loadDelegate:self];
                break;
                
            case VideoMix_InterstitialVideoType:
                [UnityAds load:_unityAdsInterstitialVideoPlacementId loadDelegate:self];
                break;
                
            case VideoMix_RewardVideoType:
                [UnityAds load:_unityAdsRewardPlacementId loadDelegate:self];
                break;
                
            default:
                break;
        }
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message {
    NSLog(@"UnityAdsInitializationDelegate initializationFailed with message: %@", message);
    if (_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                }
                break;
                
            default:
                [self invalidateNetworkTimer];
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
                }
                break;
        }
        
    }
}

// Implement load callbacks to handle success or failure after initialization:
#pragma mark: UnityAdsLoadDelegate
- (void)unityAdsAdLoaded:(NSString *)adUnitId {
    NSLog(@" - UnityAdsLoadDelegate unityAdsAdLoaded placementId : %@", adUnitId);
    if (_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        if([adUnitId isEqualToString:_unityAdsRewardPlacementId]){
            NSLog(@"UnityAdsAdapter : RewardVideo unityAdsReady");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        if([adUnitId isEqualToString:_unityAdsInterstitialVideoPlacementId]){
            NSLog(@"UnityAdsAdapter : InterstitialVideo unityAdsReady");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPAdInterstitialType)
    {
        if([adUnitId isEqualToString:_unityAdsInterstitialPlacementId]){
            NSLog(@"UnityAdsAdapter : Interstitial unityAdsReady");
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialAdLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if([adUnitId isEqualToString:_unityAdsInterstitialPlacementId]){
                    NSLog(@"UnityAdsAdapter : VideoMixAd_Interstitial unityAdsReady");
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                break;
                
            case VideoMix_InterstitialVideoType:
                [self invalidateNetworkTimer];
                if([adUnitId isEqualToString:_unityAdsInterstitialVideoPlacementId]){
                    NSLog(@"UnityAdsAdapter : VideoMixAd_InterstitialVideo unityAdsReady");
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                break;
                
            case VideoMix_RewardVideoType:
                [self invalidateNetworkTimer];
                if([adUnitId isEqualToString:_unityAdsRewardPlacementId]){
                    NSLog(@"UnityAdsAdapter : VideoMixAd_RewardVideo unityAdsReady");
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadSuccess:videoMixType:)])
                    {
                        [_delegate AdPopcornSSPAdapterVideoMixAdLoadSuccess:self videoMixType:videoMixAdType];
                    }
                }
                break;
        }
    }
}

- (void)unityAdsAdFailedToLoad:(NSString *)adUnitId
                     withError:(UnityAdsLoadError)error
                   withMessage:(NSString *)message {
    NSLog(@" - UnityAdsLoadDelegate unityAdsAdFailedToLoad placementId : %@, message : %@", adUnitId, message);
    if (_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                break;
                
            case VideoMix_InterstitialVideoType:
                [self invalidateNetworkTimer];
                break;
                
            case VideoMix_RewardVideoType:
                [self invalidateNetworkTimer];
                break;
        }
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdLoadFailError:adapter:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self videoMixType:videoMixAdType];
        }
    }
}
// Implement callbacks for events related to the show method:
#pragma mark: UnityAdsShowDelegate
- (void)unityAdsShowComplete:(NSString *)adUnitId withFinishState:(UnityAdsShowCompletionState)state {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowComplete placementId : %@, state : %ld", adUnitId, state);
    if(_adType == SSPRewardVideoAdType)
    {
        if (state == kUnityShowCompletionStateCompleted)
        {
            if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
            {
                [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
            }
        }
        else if(state == kUnityShowCompletionStateSkipped)
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
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
    }
    else if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClosed:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdClosed:self];
        }
    }
    else if(_adType == SSPVideoMixAdType) {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdClose:videoMixType:)])
        {
            [_delegate AdPopcornSSPAdapterVideoMixAdClose:self videoMixType:videoMixAdType];
        }
    }
    _isCurrentRunningAdapter = NO;
}

- (void)unityAdsShowFailed:(NSString *)adUnitId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowFailed placementId : %@, message : %@", adUnitId, message);
    if (_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPVideoMixAdType)
    {
        
        switch (videoMixAdType) {
            case VideoMix_InterstitialType:
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterVideoMixAdShowFailError:adapter:videoMixType:)])
                {
                    [_delegate AdPopcornSSPAdapterVideoMixAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialLoaded)}] adapter:self videoMixType:videoMixAdType];
                }
                break;
                
            case VideoMix_InterstitialVideoType:
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
                }
                break;
                
            case VideoMix_RewardVideoType:
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
                }
                break;
        }
    }
}

- (void)unityAdsShowStart:(NSString *)adUnitId {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowStart placementId : %@", adUnitId);
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
    else if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdShowSuccess:self];
        }
    }
    else if(_adType == SSPVideoMixAdType)
    {
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

- (void)unityAdsShowClick:(NSString *)adUnitId {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowClick placementId : %@", adUnitId);
    if(_adType == SSPAdInterstitialType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClicked:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialAdClicked:self];
        }
    }
}
@end
