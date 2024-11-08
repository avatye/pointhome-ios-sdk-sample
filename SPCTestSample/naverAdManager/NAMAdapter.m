//
//  NAMAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2022. 9. 27..
//  Copyright (c) 2022년 adpopcorn All rights reserved.
//

// compatible with NAMManger v6.7.0
#import "NAMAdapter.h"

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

@interface NAMAdapter () <GFPAdLoaderDelegate, GFPBannerViewDelegate, GFPNativeSimpleAdDelegate>
{
    NSString *_rewardVideoAdUnitId, *_interstitialVideoAdUnitId;
    BOOL _isCurrentRunningAdapter;
    APNAMNativeAdRenderer *namNativeAdRenderer;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    GFPNativeSimpleAdView *gfpNativeSimpleAdVew;
}
- (void)addAlignCenterConstraint;
@end

@implementation NAMAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;
@synthesize adpopcornSSPReactNativeAd = _adpopcornSSPReactNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 21;
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
    if([nativeAdRenderer isKindOfClass:[APNAMNativeAdRenderer class]])
        namNativeAdRenderer = nativeAdRenderer;
    _adpopcornSSPNativeAd = adpopcornSSPNativeAd;
}

- (void)setInterstitialVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPInterstitialVideoAdType;
}

- (void)setViewController:(UIViewController *)viewController reactNativeAd:(AdPopcornSSPReactNativeAd *)reactNativeAd
{
    _viewController = viewController;
    _adType = SSPReactNativeAdType;
    _adpopcornSSPReactNativeAd = reactNativeAd;
}

- (BOOL)isSupportInterstitialAd
{
    return NO;
}

- (BOOL)isSupportRewardVideoAd
{
    return NO;
}

- (BOOL)isSupportNativeAd
{
    return YES;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return NO;
}

- (void)loadAd
{
    if (_adType == SSPAdBannerType)
    {
        if (_integrationKey != nil)
        {
            NSString *adUnitID = [_integrationKey valueForKey:@"NamUnitId"];
            NSLog(@"NAMAdapter SSPAdBannerType adUnitID : %@", adUnitID);
            if((_size.width == 320.0f && _size.height == 50.0f)
               || (_size.width == 320.0f && _size.height == 100.0f))
            {
                NSLog(@"NAMAdapter can not load 320x50 or 320x100");
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                
                [self closeAd];
                return;
            }
            GFPAdParam *adParam = [[GFPAdParam alloc] init];
            adLoader = [[GFPAdLoader alloc] initWithUnitID:adUnitID rootViewController:_viewController adParam:adParam];
                    
            GFPAdBannerOptions *bannerOptions = [[GFPAdBannerOptions alloc] init];
            bannerOptions.layoutType = GFPBannerViewLayoutTypeFixed;
            [adLoader setBannerDelegate:self bannerOptions:bannerOptions];
            
            // 광고 요청
            adLoader.delegate = self;
            [adLoader loadAd];
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
    else if(_adType == SSPNativeAdType)
    {
        if(_integrationKey != nil)
        {
            NSString *adUnitID = [_integrationKey valueForKey:@"NamUnitId"];
            NSLog(@"NAMAdapter SSPNativeAdType adUnitID : %@", adUnitID);
            GFPAdParam *adParam = [[GFPAdParam alloc] init];
            
            adLoader = [[GFPAdLoader alloc] initWithUnitID:adUnitID rootViewController:_viewController adParam:adParam];
            
            GFPAdNativeSimpleOptions *nativeSimpleOptions =  [[GFPAdNativeSimpleOptions alloc] init];
            [adLoader setNativeSimpleDelegate:self nativeSimpleOptions:nativeSimpleOptions];
            
            adLoader.delegate = self;
            [adLoader loadAd];
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
    else if(_adType == SSPReactNativeAdType)
    {
        if(_integrationKey != nil)
        {
            NSString *adUnitID = [_integrationKey valueForKey:@"NamUnitId"];
            NSLog(@"NAMAdapter SSPReactNativeAdType adUnitID : %@", adUnitID);
            GFPAdParam *adParam = [[GFPAdParam alloc] init];
            
            adLoader = [[GFPAdLoader alloc] initWithUnitID:adUnitID rootViewController:_viewController adParam:adParam];
            
            GFPAdNativeSimpleOptions *nativeSimpleOptions =  [[GFPAdNativeSimpleOptions alloc] init];
            [adLoader setNativeSimpleDelegate:self nativeSimpleOptions:nativeSimpleOptions];
            
            adLoader.delegate = self;
            [adLoader loadAd];
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
}

- (void)closeAd
{
    NSLog(@"NAMAdapter : closeAd : %d", _adType);
    if (_adType == SSPAdBannerType)
    {
        [gfpBannerView removeFromSuperview];
        gfpBannerView.delegate = nil;
        gfpBannerView = nil;
    }
    else if(_adType == SSPReactNativeAdType)
    {
        [gfpNativeSimpleAdVew removeFromSuperview];
    }
}

- (void)loadRequest
{
    // Not used any more
}

- (void)addAlignCenterConstraint
{
    // add constraints
    [gfpBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:gfpBannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:gfpBannerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:gfpBannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:gfpBannerView.frame.size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:gfpBannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:gfpBannerView.frame.size.width]];
}

#pragma mark - GFPAdLoaderDelegate
- (void)adLoader:(GFPAdLoader *)unifiedAdLoader didReceiveBannerAd:(GFPBannerView *)bannerView {
    NSLog(@"NAMAdapter didReceiveBannerAd : %@", bannerView);
    
    gfpBannerView = bannerView;
    [_bannerView addSubview:bannerView];

    if(_bannerView != nil)
    {
        _bannerView.frame = CGRectMake(_bannerView.frame.origin.x, _bannerView.frame.origin.y, gfpBannerView.frame.size.width, gfpBannerView.frame.size.height);
        [self addAlignCenterConstraint];
    }

    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

- (void)adLoader:(GFPAdLoader *)unifiedAdLoader didReceiveNativeSimpleAd:(GFPNativeSimpleAd *)nativeSimpleAd
{
    NSLog(@"NAMAdapter didReceiveNativeSimpleAd");
    if(_adType == SSPNativeAdType)
    {
        if(namNativeAdRenderer != nil && namNativeAdRenderer.namNativeSimpleAdView != nil)
        {
            // 네이티브 광고객체 및 delegate 등록
            gfpNativeSimpleAd = nativeSimpleAd;
            gfpNativeSimpleAd.delegate = self;
            
            // 뷰 객체에 네이티브 광고를 세팅하면, mediaView 렌더링 및 뷰 트래킹이 시작됨.
            namNativeAdRenderer.namNativeSimpleAdView.nativeAd = nativeSimpleAd;
            [_adpopcornSSPNativeAd addSubview:namNativeAdRenderer.namNativeSimpleAdView];
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
    else if(_adType == SSPReactNativeAdType)
    {
        if(_adpopcornSSPReactNativeAd.subviews)
        {
            for(UIView *view in _adpopcornSSPReactNativeAd.subviews)
                [view removeFromSuperview];
        }
        CGRect frame = _adpopcornSSPReactNativeAd.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        _adpopcornSSPReactNativeAd.frame = frame;
      
        gfpNativeSimpleAdVew = [[NSBundle mainBundle] loadNibNamed:@"GFPNativeSimpleAdView" owner:nil options:nil].firstObject;
        gfpNativeSimpleAdVew.frame = CGRectMake(0, 0, _adpopcornSSPReactNativeAd.frame.size.width, _adpopcornSSPReactNativeAd.frame.size.height);
        [gfpNativeSimpleAdVew layoutIfNeeded];
      
        // 네이티브 광고객체 및 delegate 등록
        gfpNativeSimpleAd = nativeSimpleAd;
        gfpNativeSimpleAd.delegate = self;
        
        // 뷰 객체에 네이티브 광고를 세팅하면, mediaView 렌더링 및 뷰 트래킹이 시작됨.
        gfpNativeSimpleAdVew.nativeAd = nativeSimpleAd;
        [_adpopcornSSPReactNativeAd addSubview:gfpNativeSimpleAdVew];
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdLoadSuccess:adSize:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdLoadSuccess:self adSize:CGSizeMake(gfpNativeSimpleAdVew.frame.size.width, gfpNativeSimpleAdVew.frame.size.height)];
        }
        
    }
}

- (void)adLoader:(GFPAdLoader *)unifiedAdLoader didFailWithError:(GFPError *)error responseInfo:(GFPLoadResponseInfo *)responseInfo {
    NSLog(@"NAMAdapter didFailWithError");
    if(_adType == SSPAdBannerType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:error adapter:self];
        }
        
        [self closeAd];
    }
    else if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdLoadFailError:error adapter:self];
        }
    }
}

#pragma mark - GFPBannerViewDelegate
- (void)bannerViewDidReceiveAd:(GFPBannerView *)bannerView
{
    NSLog(@"NAMAdapter bannerViewDidReceiveAd : %@", bannerView);
}

- (void)bannerView:(GFPBannerView *)bannerView didFailToReceiveAdWithError:(GFPError *)error
{
    NSLog(@"NAMAdapter didFailToReceiveAdWithError");
}

- (void)bannerAdWasSeen:(GFPBannerView *)bannerView
{
    NSLog(@"NAMAdapter bannerAdWasSeen");
}

- (void)bannerAdWasClicked:(GFPBannerView *)bannerView
{
    NSLog(@"NAMAdapter bannerAdWasClicked");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}

- (void)bannerView:(GFPBannerView *)bannerView didChangeWith:(GFPBannerAdSize *)size
{
    NSLog(@"NAMAdapter didChangeWith : %@", size);
}

#pragma mark GFPNativeSimpleAdDelegate
- (void)nativeSimpleAdWasSeen:(GFPNativeSimpleAd *)nativeSimpleAd
{
    NSLog(@"NAMAdapter GFPNativeSimpleAdDelegate nativeSimpleAdWasSeen");
    if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdImpression:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdImpression:self];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdImpression:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdImpression:self];
        }
    }
}

- (void)nativeSimpleAdWasClicked:(GFPNativeSimpleAd *)nativeSimpleAd
{
    NSLog(@"NAMAdapter GFPNativeSimpleAdDelegate nativeSimpleAdWasClicked");
    if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdClicked:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdClicked:self];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdClicked:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdClicked:self];
        }
    }
}

- (void)nativeSimpleAd:(GFPNativeSimpleAd *)nativeSimpleAd didFailWithError:(GFPError *)error
{
    // Rendering error
    NSLog(@"NAMAdapter GFPNativeSimpleAdDelegate didFailWithError");
    if(_adType == SSPNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:error adapter:self];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdLoadFailError:error adapter:self];
        }
    }
}
- (void)nativeSimpleAd:(GFPNativeSimpleAd *)nativeSimpleAd didChangeMediaViewSizeWith:(CGSize)size {
    NSLog(@"NAMAdapter GFPNativeSimpleAdDelegate didChangeMediaViewSizeWith : %f, %f", size.width, size.height);
  if(_adType == SSPReactNativeAdType)
  {
      gfpNativeSimpleAdVew.frame = CGRectMake(0, 0, size.width, size.height);
      if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdSizeChanged:adSize:)])
      {
        [_delegate AdPopcornSSPAdapterReactNativeAdSizeChanged:self adSize:size];
      }
  }
}
@end


@implementation APNAMNativeAdRenderer
{
}
@end

