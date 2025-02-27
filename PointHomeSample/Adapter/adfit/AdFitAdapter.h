//
//  AdFitAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2017. 8. 2..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

#import <AdFitSDK/AdFitSDK-Swift.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface AdFitAdapter : AdPopcornSSPAdapter
{
    AdFitBannerAdView *_adFitBannerAdView;
    AdFitNativeAd *_adFitNativeAd;
    AdFitNativeAdLoader *_adFitNativeAdLoader;
}

@end

@interface APAdFitNativeAdRenderer: NSObject
@property (strong, nonatomic) BizBoardTemplate *adfitBizBoardTemplate;
@property (nonatomic) CGFloat bizBoardInfoIconTopConstant;
@property (nonatomic) CGFloat bizBoardInfoIconBottomConstant;
@property (nonatomic) CGFloat bizBoardInfoIconLeftConstant;
@property (nonatomic) CGFloat bizBoardInfoIconRightConstant;
@property (nonatomic, unsafe_unretained) BOOL useBizBoardTemplate;

// For Manaual Native
@property (strong, nonatomic) UIView *adfitNativeAdUIView;
@end

