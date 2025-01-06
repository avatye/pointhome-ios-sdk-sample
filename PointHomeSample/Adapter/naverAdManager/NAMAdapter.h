//
//  NAMAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2022. 9. 27..
//  Copyright (c) 2022년 adpopcorn All rights reserved.
//

@import GFPSDK;

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface NAMAdapter : AdPopcornSSPAdapter
{
    GFPAdLoader *adLoader;
    GFPBannerView *gfpBannerView, *gfpModalBannerView;
    GFPNativeSimpleAd *gfpNativeSimpleAd;
}

@end

@interface APNAMNativeAdRenderer: NSObject
@property (strong, nonatomic) GFPNativeSimpleAdView *namNativeSimpleAdView;
@end

