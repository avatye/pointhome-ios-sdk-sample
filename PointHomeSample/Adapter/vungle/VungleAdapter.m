//
//  VungleAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

// compatible with Vungle v7.1.0
#import "VungleAdapter.h"

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
        case AdPopcornSSPMediationInvalidIntegrationKey:
            return @"Invalid Integration Key";
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

@interface VungleAdapter () <VungleBannerDelegate, VungleRewardedDelegate, VungleInterstitialDelegate>
{
    BOOL _isCurrentRunningAdapter;
    NSString *vungleAppId, *vungleBannerPlacementId, *vungleRVPlacementId, *vungleIVPlacementId;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    BOOL _isMute;
    NSMutableArray *_impTrackersListArray, *_clickTrackersListArray;
    NSString *_biddingData;
    BOOL _isInAppBidding;
}

@property (nonatomic, strong) VungleBanner *bannerAd;
@property (nonatomic, strong) VungleRewarded *rewardedAd;
@property (nonatomic, strong) VungleInterstitial *interstitialAd;
@end

@implementation VungleAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 14;
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

- (void)setInterstitialVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPInterstitialVideoAdType;
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

- (void)setBiddingData:(NSString *)biddingData impressionList:(NSMutableArray *)impTrackersListArray clickList: (NSMutableArray *)clickTrackersListArray
{
    _biddingData = biddingData;
    _impTrackersListArray = impTrackersListArray;
    _clickTrackersListArray =  clickTrackersListArray;
}

- (void)setMute:(bool)mute
{
    _isMute = mute;
}

- (void)setInAppBiddingMode:(bool)isInAppBiddingMode
{
    _isInAppBidding = isInAppBiddingMode;
    NSLog(@"VungleAdapter setInAppBiddingMode : %d", _isInAppBidding);
}

- (void)loadAd
{
    if(_adType == SSPAdBannerType)
    {
        NSLog(@"VungleAdapter %@ : SSPAdBannerType loadAd : %d", self, _isInAppBidding);
        if (_integrationKey != nil)
        {
            if(_size.width == 320.0f && _size.height == 100.0f)
            {
                NSLog(@"%@ : Vungle can not load 320x100", self);
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                
                [self closeAd];
                return;
            }
            
            BannerSize bannerSize = BannerSizeRegular;
            if(_size.width == 300.0f && _size.height == 250.0f)
            {
                bannerSize = BannerSizeMrec;
            }
            
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleBannerPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleBannerPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
            
            if([VungleAds isInitialized])
            {
                NSLog(@"VungleAdapter banner already initialized : %@", vungleBannerPlacementId);
                self.bannerAd = [[VungleBanner alloc] initWithPlacementId:vungleBannerPlacementId size:bannerSize];
                self.bannerAd.delegate = self;
                
                if(_isInAppBidding)
                {
                    [self.bannerAd load:_biddingData];
                }
                else
                {
                    [self.bannerAd load:nil];
                }
            }
            else
            {
                NSLog(@"VungleAdapter banner initWithAppId");
                [VungleAds initWithAppId:vungleAppId completion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"VungleAdapter banner Error initializing SDK %@", error);
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        [self closeAd];
                    } else {
                        NSLog(@"VungleAdapter banner initialized");
                        self.bannerAd = [[VungleBanner alloc] initWithPlacementId:vungleBannerPlacementId size:bannerSize];
                        self.bannerAd.delegate = self;
                        
                        if(_isInAppBidding)
                        {
                            [self.bannerAd load:_biddingData];
                        }
                        else
                        {
                            [self.bannerAd load:nil];
                        }
                    }
                }];
            }
        }
        else
        {
            NSLog(@"VungleAdapter banner no integrationKey");
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        NSLog(@"VungleAdapter %@ : SSPRewardVideoAdType loadAd : %d", self, _isInAppBidding);
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
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleRVPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleRVPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
                
            if([VungleAds isInitialized])
            {
                NSLog(@"VungleAdapter rewardVideo already initialized : %@", vungleRVPlacementId);
                self.rewardedAd = [[VungleRewarded alloc] initWithPlacementId:vungleRVPlacementId];
                    self.rewardedAd.delegate = self;
                
                if(_isInAppBidding)
                {
                    [self.rewardedAd load:_biddingData];
                }
                else
                {
                    [self.rewardedAd load:nil];
                }
            }
            else
            {
                NSLog(@"VungleAdapter rewardVideo initWithAppId");
                [VungleAds initWithAppId:vungleAppId completion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"VungleAdapter rewardVideo initializing error %@", error);
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        [self invalidateNetworkTimer];
                    } else {
                        NSLog(@"VungleAdapter rewardVideo initialized");
                        self.rewardedAd = [[VungleRewarded alloc] initWithPlacementId:vungleRVPlacementId];
                        self.rewardedAd.delegate = self;
                        
                        if(_isInAppBidding)
                        {
                            [self.rewardedAd load:_biddingData];
                        }
                        else
                        {
                            [self.rewardedAd load:nil];
                        }
                    }
                }];
            }
        }
        else
        {
            NSLog(@"VungleAdapter rewardVideo no integrationKey");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"VungleAdapter %@ : SSPInterstitialVideoAdType loadAd", self);
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
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleIVPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleIVPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
            
            if([VungleAds isInitialized])
            {
                NSLog(@"VungleAdapter interstitialVideo already initialized : %@", vungleIVPlacementId);
                self.interstitialAd = [[VungleInterstitial alloc]     initWithPlacementId:vungleIVPlacementId];
                self.interstitialAd.delegate = self;
                if(_isInAppBidding)
                {
                    [self.interstitialAd load:_biddingData];
                }
                else
                {
                    [self.interstitialAd load:nil];
                }
            }
            else
            {
                NSLog(@"VungleAdapter interstitialVideo initWithAppId");
                [VungleAds initWithAppId:vungleAppId completion:^(NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"VungleAdapter interstitialVideo initializing error %@", error);
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        [self invalidateNetworkTimer];
                    } else {
                        NSLog(@"VungleAdapter interstitialVideo initialized");
                        self.interstitialAd = [[VungleInterstitial alloc]     initWithPlacementId:vungleIVPlacementId];
                        self.interstitialAd.delegate = self;
                        
                        if(_isInAppBidding)
                        {
                            [self.interstitialAd load:_biddingData];
                        }
                        else
                        {
                            [self.interstitialAd load:nil];
                        }
                    }
                }];
            }
        }
        else
        {
            NSLog(@"VungleAdapter interstitialVideo no integrationKey");
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
    NSLog(@"VungleAdapter : showAd : %d", _adType);
    if (_adType == SSPRewardVideoAdType)
    {
        [self.rewardedAd presentWith:_viewController];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self.interstitialAd presentWith:_viewController];
    }
}

- (void)closeAd
{
    NSLog(@"VungleAdapter closeAd");
    if(_adType == SSPAdBannerType)
    {
        for (id subview in _bannerView.subviews) {
            [subview removeFromSuperview];
        }
        self.bannerAd.delegate = nil;
        self.bannerAd = nil;
    }
    else{
        _isCurrentRunningAdapter = NO;
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
        NSLog(@"VungleAdapter rewardVideo load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"VungleAdapter interstitialVideo load timeout");
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

#pragma mark - VungleBanner Delegate Methods
- (void)bannerAdDidLoad:(VungleBanner *)banner {
    NSLog(@"VungleAdapter bannerAdDidLoad");
    [self.bannerAd presentOn:_bannerView];
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}
- (void)bannerAdDidFailToLoad:(VungleBanner *)banner
                    withError:(NSError *)withError {
    NSLog(@"VungleAdapter bannerAdDidFailToLoad");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
    [self closeAd];
}
- (void)bannerAdDidPresent:(VungleBanner *)banner {
    NSLog(@"VungleAdapter bannerAdDidPresent");
}
- (void)bannerAdDidFailToPresent:(VungleBanner *)banner
                       withError:(NSError *)withError {
    NSLog(@"VungleAdapter bannerAdDidFailToPresent");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
    [self closeAd];
}
- (void)bannerAdDidTrackImpression:(VungleBanner *)banner {
    NSLog(@"VungleAdapter bannerAdDidTrackImpression");
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}
- (void)bannerAdDidClick:(VungleBanner *)banner {
    NSLog(@"VungleAdapter bannerAdDidClick");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}
- (void)bannerAdDidClose:(VungleBanner *)banner {
    NSLog(@"bannerAdDidClose");
}

#pragma mark - VungleRewarded Delegate Methods
// Ad load events
- (void)rewardedAdDidLoad:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidLoad");
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
    }
}
- (void)rewardedAdDidFailToLoad:(VungleRewarded *)rewarded
                      withError:(NSError *)withError {
    NSLog(@"VungleAdapter rewardedAdDidFailToLoad");
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
}
// Ad Lifecycle Events
- (void)rewardedAdDidPresent:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidPresent");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
    }
}
- (void)rewardedAdDidFailToPresent:(VungleRewarded *)rewarded
                         withError:(NSError *)withError {
    NSLog(@"VungleAdapter rewardedAdDidFailToPresent");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
    }
}
- (void)rewardedAdDidTrackImpression:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidTrackImpression");
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}
- (void)rewardedAdDidClick:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidClick");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}
- (void)rewardedAdWillLeaveApplication:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdWillLeaveApplication");
}
- (void)rewardedAdDidRewardUser:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidRewardUser");
    if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
    {
        [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
    }
}
- (void)rewardedAdDidClose:(VungleRewarded *)rewarded {
    NSLog(@"VungleAdapter rewardedAdDidClose");
    _isCurrentRunningAdapter = NO;
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
    }
}

#pragma mark - VungleInterstitial Delegate Methods
// Ad load events
- (void)interstitialAdDidLoad:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdDidLoad");
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
    }
}
- (void)interstitialAdDidFailToLoad:(VungleInterstitial *)interstitial
                          withError:(NSError *)withError {
    NSLog(@"VungleAdapter interstitialAdDidFailToLoad");
    [self invalidateNetworkTimer];
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
}

// Ad Lifecycle Events
- (void)interstitialAdDidPresent:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdDidPresent");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
    }
}
- (void)interstitialAdDidFailToPresent:(VungleInterstitial *)interstitial
                             withError:(NSError *)withError {
    NSLog(@"VungleAdapter interstitialAdDidFailToPresent");
    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
    }
}
- (void)interstitialAdDidTrackImpression:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdDidTrackImpression");
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}
- (void)interstitialAdDidClick:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdDidClick");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}
- (void)interstitialAdWillLeaveApplication:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdWillLeaveApplication");
}
- (void)interstitialAdDidClose:(VungleInterstitial *)interstitial {
    NSLog(@"VungleAdapter interstitialAdDidClose");
    _isCurrentRunningAdapter = NO;
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
    }
}

- (NSString *)getBiddingToken
{
    return [VungleAds getBiddingToken];
}

@end
