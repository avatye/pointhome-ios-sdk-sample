//
//  PangleAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2020. 10. 28..
//  Copyright (c) 2020년 igaworks All rights reserved.
//

#import <PAGAdSDK/PAGAdSDK.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface PangleAdapter : AdPopcornSSPAdapter
{

}
@end

@interface APPangleNativeAdRenderer: NSObject

@property (nonatomic, weak) UIView *nativeAdView;
@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *titleLbl;
@property (nonatomic, weak) UILabel *ratingLbl;
@property (nonatomic, weak) UILabel *sponsorLbl;
@property (nonatomic, weak) UILabel *adTextLbl;
@property (nonatomic, weak) UIButton *downloadBtn;

@end
