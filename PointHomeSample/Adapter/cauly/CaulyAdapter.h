//
//  CaulyAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2017. 9. 6..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

@import CaulySDK;

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface CaulyAdapter : AdPopcornSSPAdapter
{
    CaulyAdView *_adBannerView;
    CaulyInterstitialAd *_interstitial;
}
@end
