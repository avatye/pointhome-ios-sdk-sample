//
//  FyberAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2020. 10. 28..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

// compatible with Fyber v8.2.4 (FairBid SDK 3.47.0)
#import "FyberAdapter.h"

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

@interface FyberAdapter () <IAUnitDelegate, IAVideoContentDelegate>
{
    BOOL _isCurrentRunningAdapter;
    NSString *fyberAppId, *fyberSpotId;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
}

@end

@implementation FyberAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 16;
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
    return NO;
}

- (void)loadAd
{
    if(networkScheduleTimer == nil)
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    
    if (_adType == SSPRewardVideoAdType)
    {
        NSLog(@"FyberAdapter %@ : SSPRewardVideoAdType loadAd", self);
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            fyberAppId = [_integrationKey valueForKey:@"FyberAppId"];
            fyberSpotId = [_integrationKey valueForKey:@"FyberSpotId"];
            
            IAAdRequest *adRequest =
            [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
                builder.useSecureConnections = YES;
                builder.spotID = fyberSpotId;
                builder.timeout = 10;
            }];
            
            IAVideoContentController *videoContentController =
            [IAVideoContentController build:
              ^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
               builder.videoContentDelegate = self; // a delegate should be passed in order to get video content related callbacks;
            }];

            _videoContentController = videoContentController;
            
            IAFullscreenUnitController *fullscreenUnitController =
              [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder)
               {
                 builder.unitDelegate = self;
                 // all the needed content controllers should be added to the desired unit controller:
                 [builder addSupportedContentController:_videoContentController];
               }];
                
            _fullscreenUnitController = fullscreenUnitController;
            
            IAAdSpot *adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
                builder.adRequest = adRequest; // pass here the ad request object;
                // all the supported (by a client side) unit controllers,
                // (in this case - view unit controller) should be added to the desired ad spot:
                [builder addSupportedUnitController:_fullscreenUnitController];
            }];

            _adSpot = adSpot;
            
            [_adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
                if (error)
                {
                    NSLog(@"FyberAdapter fetchAdWithCompletion Error : %@", error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                    }
                    
                }
                else
                {
                    NSLog(@"FyberAdapter fetchAdWithCompletion Success");
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
            NSLog(@"FyberAdapter rv no integrationKey");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
}

- (void)showAd
{
    NSLog(@"FyberAdapter : showAd : %d", _adType);
    if (_adType == SSPRewardVideoAdType)
    {
        if (_adSpot.activeUnitController == _fullscreenUnitController)
        {
            [_fullscreenUnitController showAdAnimated:YES completion:nil];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
            }
        }
    }
}

- (void)closeAd
{
    NSLog(@"FyberAdapter closeAd");
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
        NSLog(@"FyberAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    [self invalidateNetworkTimer];
}

-(void)invalidateNetworkTimer
{
    if(networkScheduleTimer != nil)
        [networkScheduleTimer invalidate];
}

#pragma IAUnitDelegate
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController
{
    NSLog(@"FyberAdapter IAParentViewControllerForUnitController");
    return _viewController;
}

- (void)IAAdDidReward:(IAUnitController * _Nullable)unitController
{
    NSLog(@"FyberAdapter IAAdDidReward");
    if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
    {
        [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
    }
}
- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController
{
    NSLog(@"FyberAdapter IAUnitControllerDidPresentFullscreen");

    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
    }
}
- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController
{
    NSLog(@"FyberAdapter IAUnitControllerDidDismissFullscreen");

    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
    {
        [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
    }
    _isCurrentRunningAdapter = NO;
}

#pragma IAVideoContentDelegate
@end
