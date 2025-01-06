//
//  VungleAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

#import <VungleAdsSDK/VungleAdsSDK.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface VungleAdapter : AdPopcornSSPAdapter
{
}
@end

@interface APVungleNativeAdRenderer: NSObject

@property (nonatomic, weak) UIView *nativeAdView;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) MediaView *mediaView;
@property (nonatomic, weak) UILabel *titleLbl;
@property (nonatomic, weak) UILabel *ratingLbl;
@property (nonatomic, weak) UILabel *sponsorLbl;
@property (nonatomic, weak) UILabel *adTextLbl;
@property (nonatomic, weak) UIButton *downloadBtn;

@end
