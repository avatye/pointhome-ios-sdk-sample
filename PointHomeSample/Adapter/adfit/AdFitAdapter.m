//
//  AdFitAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2022. 8. 2..
//  Copyright (c) 2023년 Adpopcorn All rights reserved.
//

// compatible with AdFit v3.15.4
#import "AdFitAdapter.h"

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

@interface AdFitAdapter () <AdFitBannerAdViewDelegate, AdFitNativeAdDelegate, AdFitNativeAdLoaderDelegate>
{
    APAdFitNativeAdRenderer *adfitNativeAdRenderer;
    BizBoardTemplate *bizBoardTemplate;
}

- (void)addAlignCenterConstraint;
@end

@implementation AdFitAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;
@synthesize adpopcornSSPNativeAd = _adpopcornSSPNativeAd;
@synthesize adpopcornSSPReactNativeAd = _adpopcornSSPReactNativeAd;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
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
}

- (void)setRewardVideoViewController:(UIViewController *)viewController
{
}

- (void)setNativeAdViewController:(UIViewController *)viewController nativeAdRenderer:(id)nativeAdRenderer rootNativeAdView:(AdPopcornSSPNativeAd *)adpopcornSSPNativeAd
{
    _viewController = viewController;
    _adType = SSPNativeAdType;
    if([nativeAdRenderer isKindOfClass:[APAdFitNativeAdRenderer class]])
        adfitNativeAdRenderer = nativeAdRenderer;
    _adpopcornSSPNativeAd = adpopcornSSPNativeAd;
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

- (void)loadAd
{
    if (_adType == SSPAdBannerType)
    {
        if (_integrationKey != nil)
        {
            NSString *clientId = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];

            if(_adFitBannerAdView != nil)
            {
                [_adFitBannerAdView removeFromSuperview];
                _adFitBannerAdView.delegate = nil;
                _adFitBannerAdView = nil;
            }
            
            if(_size.width == 320.0f && _size.height == 100.0f)
            {
                _adFitBannerAdView = [[AdFitBannerAdView alloc] initWithClientId:clientId adUnitSize:@"320x100"];
                _adFitBannerAdView.frame = CGRectMake(0.f, 0.f, _bannerView.bounds.size.width, 100.f);
            }
            else if(_size.width == 300.0f && _size.height == 250.0f)
            {
                _adFitBannerAdView = [[AdFitBannerAdView alloc] initWithClientId:clientId adUnitSize:@"300x250"];
                _adFitBannerAdView.frame = CGRectMake(0.f, 0.f, _bannerView.bounds.size.width, 250.f);
            }
            else
            {
                _adFitBannerAdView = [[AdFitBannerAdView alloc] initWithClientId:clientId adUnitSize:@"320x50"];
                _adFitBannerAdView.frame = CGRectMake(0.f, 0.f, _bannerView.bounds.size.width, 50.f);
            }

            [_bannerView addSubview:_adFitBannerAdView];
            [self addAlignCenterConstraint];
            
            _adFitBannerAdView.rootViewController = _viewController;
            _adFitBannerAdView.delegate = self;
            
            [_adFitBannerAdView loadAd];
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
        if (_integrationKey != nil)
        {
            NSString *clientId = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
            if(adfitNativeAdRenderer.useBizBoardTemplate)
            {
                [_adpopcornSSPNativeAd addSubview:adfitNativeAdRenderer.adfitBizBoardTemplate];
                
                CGFloat width = _adpopcornSSPNativeAd.frame.size.width;
                CGFloat leftRightMargin = BizBoardTemplate.defaultEdgeInset.left +
                BizBoardTemplate.defaultEdgeInset.right;
                CGFloat topBottomMargin = BizBoardTemplate.defaultEdgeInset.top
                + BizBoardTemplate.defaultEdgeInset.bottom;
                CGFloat bizBoardWidth = width - leftRightMargin;
                CGFloat bizBoardRatio = 1029.0 / 258.0;
                CGFloat bizBoardHeight = bizBoardWidth / bizBoardRatio;
                CGFloat height = bizBoardHeight + topBottomMargin;
                
                adfitNativeAdRenderer.adfitBizBoardTemplate.frame = CGRectMake(0, 0, width, height);
            }
            else
            {
                [_adpopcornSSPNativeAd addSubview:adfitNativeAdRenderer.adfitNativeAdUIView];
            }
            _adFitNativeAdLoader = [[AdFitNativeAdLoader alloc] initWithClientId:clientId count:1 userObject:nil contentObject:nil];
            _adFitNativeAdLoader.delegate = self;
            
            [_adFitNativeAdLoader loadAdWithKeyword:nil];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadFailError:adapter:)])
            {
              [_delegate AdPopcornSSPAdapterNativeAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        if (_integrationKey != nil)
        {
            NSString *clientId = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
            
            if(_adpopcornSSPReactNativeAd.subviews)
            {
                for(UIView *view in _adpopcornSSPReactNativeAd.subviews)
                    [view removeFromSuperview];
            }
          
            CGRect frame = _adpopcornSSPReactNativeAd.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            _adpopcornSSPReactNativeAd.frame = frame;
            
            if(_adFitNativeAdLoader != nil)
            {
                _adFitNativeAdLoader.delegate = nil;
                _adFitNativeAdLoader = nil;
            }
            
            bizBoardTemplate = [[BizBoardTemplate alloc] init];
            
            bizBoardTemplate.frame = CGRectMake(0, 0, _adpopcornSSPReactNativeAd.frame.size.width, _adpopcornSSPReactNativeAd.frame.size.height);
              
            [_adpopcornSSPReactNativeAd addSubview:bizBoardTemplate];
          
            _adFitNativeAdLoader = [[AdFitNativeAdLoader alloc] initWithClientId:clientId count:1 userObject:nil contentObject:nil];
            _adFitNativeAdLoader.delegate = self;
            
            [_adFitNativeAdLoader loadAdWithKeyword:nil];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdLoadFailError:adapter:)])
            {
              [_delegate AdPopcornSSPAdapterReactNativeAdLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            
            [self closeAd];
        }
    }
}

- (void)addAlignCenterConstraint
{
    // add constraints
    [_adFitBannerAdView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adFitBannerAdView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adFitBannerAdView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adFitBannerAdView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adFitBannerAdView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}


- (void)showAd
{
    
}

- (void)closeAd
{
    NSLog(@"AdFitAdapter : closeAd");
    if (_adType == SSPAdBannerType)
    {
        [_adFitBannerAdView removeFromSuperview];
        _adFitBannerAdView.delegate = nil;
        _adFitBannerAdView = nil;
    }
    else if(_adType == SSPNativeAdType || _adType == SSPReactNativeAdType)
    {
        if(_adFitNativeAdLoader != nil)
        {
            _adFitNativeAdLoader.delegate = nil;
            _adFitNativeAdLoader = nil;
        }
    }
}

- (void)loadRequest
{
    // Not used any more
}

- (void)bindAdView
{
    if(_adType == SSPNativeAdType)
    {
        _adFitNativeAd.infoIconTopConstant = adfitNativeAdRenderer.bizBoardInfoIconTopConstant;
        _adFitNativeAd.infoIconRightConstant = adfitNativeAdRenderer.bizBoardInfoIconRightConstant;
        _adFitNativeAd.infoIconBottomConstant = adfitNativeAdRenderer.bizBoardInfoIconBottomConstant;
        _adFitNativeAd.infoIconLeftConstant = adfitNativeAdRenderer.bizBoardInfoIconLeftConstant;
        if(adfitNativeAdRenderer.useBizBoardTemplate)
        {
            [_adFitNativeAd bind:adfitNativeAdRenderer.adfitBizBoardTemplate];
            _adFitNativeAd.delegate = self;
            adfitNativeAdRenderer.adfitBizBoardTemplate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else
        {
            [_adFitNativeAd bind:adfitNativeAdRenderer.adfitNativeAdUIView];
            _adFitNativeAd.delegate = self;
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        _adFitNativeAd.infoIconRightConstant = -16;
        [_adFitNativeAd bind:bizBoardTemplate];
        _adFitNativeAd.delegate = self;
        bizBoardTemplate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

#pragma mark - AdFitBannerAdViewDelegate
- (void)adViewDidReceiveAd:(AdFitBannerAdView *)bannerAdView {
    NSLog(@"AdFitAdapter didReceiveAd");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

- (void)adViewDidFailToReceiveAd:(AdFitBannerAdView *)bannerAdView error:(NSError *)error {
    NSLog(@"AdFitAdapter didFailToReceiveAd - error = %@", [error localizedDescription]);
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:error adapter:self];
    }
    
    [self closeAd];
}

- (void)adViewDidClickAd:(AdFitBannerAdView *)bannerAdView {
    NSLog(@"AdFitAdapter didClickAd");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}

#pragma mark AdFitNativeAdLoaderDelegate
- (void)nativeAdLoaderDidReceiveAd:(AdFitNativeAd * _Nonnull)nativeAd
{
    NSLog(@"AdFitAdapter nativeAdLoaderDidReceiveAd");
    if(_adType == SSPNativeAdType)
    {
        _adFitNativeAd = nativeAd;
        _adpopcornSSPNativeAd.hidden = NO;
        [self bindAdView];
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterNativeAdLoadSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterNativeAdLoadSuccess:self];
        }
    }
    else if(_adType == SSPReactNativeAdType)
    {
        _adFitNativeAd = nativeAd;
        _adpopcornSSPReactNativeAd.hidden = NO;
        [self bindAdView];
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterReactNativeAdLoadSuccess:adSize:)])
        {
            [_delegate AdPopcornSSPAdapterReactNativeAdLoadSuccess:self adSize:CGSizeMake(bizBoardTemplate.frame.size.width, bizBoardTemplate.frame.size.height)];
        }
    }
}
/// 네이티브 광고 로드에 실패한 경우 호출됩니다.
- (void)nativeAdLoaderDidFailToReceiveAd:(AdFitNativeAdLoader * _Nonnull)nativeAdLoader error:(NSError * _Nonnull)error
{
    NSLog(@"AdFitAdapter nativeAdLoaderDidFailToReceiveAd : %@", error);
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

#pragma mark AdFitNativeAdDelegate
- (void)nativeAdDidClickAd:(AdFitNativeAd * _Nonnull)nativeAd
{
    NSLog(@"AdFitAdapter nativeAdDidClickAd");
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
@end

@implementation APAdFitNativeAdRenderer
{
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _useBizBoardTemplate = YES;
    }
    return self;
}
@end
