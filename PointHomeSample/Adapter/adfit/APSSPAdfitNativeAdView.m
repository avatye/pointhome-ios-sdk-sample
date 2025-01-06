//
//  APSSPAdfitNativeAdView.m
//  IgaworksDevApp
//
//  Created by 김민석 on 2024/02/19.
//  Copyright © 2024 AdPopcorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSSPAdfitNativeAdView.h"

@interface APSSPAdfitNativeAdView () <AdFitNativeAdRenderable>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;
@property (nonatomic, weak) IBOutlet UIButton *callToActionButton;
@property (nonatomic, weak) IBOutlet UILabel *profileNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileIconView;
@property (nonatomic, weak) IBOutlet AdFitMediaView *mediaView;
@end

@implementation APSSPAdfitNativeAdView

#pragma mark - AdFitNativeAdRenderable
- (UILabel *)adTitleLabel {
    return self.titleLabel;
}

- (UILabel *)adBodyLabel {
    return self.bodyLabel;
}

- (UIButton *)adCallToActionButton {
    return self.callToActionButton;
}

- (UILabel *)adProfileNameLabel {
    return self.profileNameLabel;
}

- (UIImageView *)adProfileIconView {
    return self.profileIconView;
}

- (AdFitMediaView *)adMediaView {
    return self.mediaView;
}

@end
