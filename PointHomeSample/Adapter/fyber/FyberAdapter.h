//
//  FyberAdapter.h
//  AdPopcornSSP
//
//  Created by mick on 2020. 10. 28..
//  Copyright (c) 2020년 igaworks All rights reserved.
//
#import <IASDKCore/IASDKCore.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface FyberAdapter : AdPopcornSSPAdapter
{
    IAAdSpot *_adSpot;
    IAFullscreenUnitController *_fullscreenUnitController;
    IAVideoContentController *_videoContentController;
}
@end
