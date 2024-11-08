//
//  MezzoAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2017. 9. 6..
//  Copyright (c) 2017년 igaworks All rights reserved.

// compatible with Mezzo v300 0103
#import "MezzoAdapter.h"

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


@interface MezzoAdapter ()
{
    NSString *appID, *appName, *storeURL;
}
- (void)addAlignCenterConstraint;
@end

@implementation MezzoAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        appID = @"ApplicationID";
        appName = @"ApplicationName";
        storeURL = @"AppStoreURL";
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
    _viewController = viewController;
    _adType = SSPAdInterstitialType;
}

- (BOOL)isSupportInterstitialAd
{
    return NO;
}

- (BOOL)isSupportRewardVideoAd
{
    return NO;
}

- (void)loadAd
{
    if (_adType == SSPAdBannerType)
    {
        if (_integrationKey != nil)
        {
            NSString *publisherCode = [_integrationKey valueForKey:@"PublisherCode"];
            NSString *mediaCode = [_integrationKey valueForKey:@"MediaCode"];
            NSString *sectionCode = [_integrationKey valueForKey:@"SectionCode"];
            
            NSLog(@"SSPAdBannerType PublisherCode : %@", publisherCode);
            NSLog(@"SSPAdBannerType MediaCode : %@", mediaCode);
            NSLog(@"SSPAdBannerType SectionCode : %@", sectionCode);

            CGSize size = CGSizeMake(_size.width, _size.height);
                
            ADMZBannerModel *model = [[ADMZBannerModel alloc]
                              initWithPublisherID:[publisherCode integerValue]
                              withMediaID:[mediaCode integerValue]
                              withSectionID:[sectionCode integerValue]
                              withBannerSize:size
                              withKeywordParameter:@"KeywordTargeting"
                              withOtherParameter:@"BannerAdditionalParameters"
                              withMediaAgeLevel:ADMZUserAgeLevelTypeOver13Age
                              withAppID:appID
                              withAppName:appName
                              withStoreURL:storeURL
                              withSMS:YES
                              withTel:YES
                              withCalendar:YES
                              withStorePicture:YES
                              withInlineVideo:YES
                              withBannerType:ADMZBannerTypeStrip];
            
            if(_adBannerView == nil)
            {
                _adBannerView = [[ADMZBannerView alloc] init];
                _adBannerView.frame = CGRectMake(0, 0, _size.width, _size.height);
            }
            else
            {
                [_adBannerView removeFromSuperview];
            }
            
            [_adBannerView updateModelWithValue:model];
            
            __weak typeof(self) weakSelf = self;
            [_adBannerView setFailHandlerWithValue:^(enum ADMZResponseStatusType type) {
                [weakSelf handleBannerEvent:type];
            }];
            [_adBannerView setOtherHandlerWithValue:^(enum ADMZResponseStatusType type) {
                [weakSelf handleBannerEvent:type];
            }];
            [_adBannerView setSuccessHandlerWithValue:^(enum ADMZResponseStatusType type) {
                [weakSelf handleBannerEvent:type];
            }];
            
            [_adBannerView setAPIResponseHandlerWithValue:^(NSDictionary<NSString *,id> * _Nullable param) {
                NSLog(@"Result = %@",param);
            }];
            
            [_bannerView addSubview:_adBannerView];
            [self addAlignCenterConstraint];
            [_adBannerView startBanner];
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

- (void)handleBannerEvent:(ADMZResponseStatusType) type
{
    NSLog(@"MezzoAdapter handleBannerEvent type : %ld", type);
    switch (type) {
            case ADMZResponseStatusTypeAdSuccess: {
                NSLog(@"MezzoAdapter handleBannerEvent ADMZResponseStatusTypeAdSuccess");
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
                }
                break;
            }
            case ADMZResponseStatusTypeAdClick: {
                NSLog(@"MezzoAdapter handleBannerEvent ADMZResponseStatusTypeAdClick");
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
                }
                break;
            }
            case ADMZResponseStatusTypeAdDidImpression: {
                NSLog(@"MezzoAdapter handleBannerEvent ADMZResponseStatusTypeAdDidImpression");
                break;
            }
            case ADMZResponseStatusTypeAdClose: {
                NSLog(@"MezzoAdapter handleBannerEvent ADMZResponseStatusTypeAdClose");
                break;
            }
            default:{
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                break;
            }
        }
}

- (void)showAd
{
}

- (void)closeAd
{
}

- (void)addAlignCenterConstraint
{
    [_adBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}
@end
