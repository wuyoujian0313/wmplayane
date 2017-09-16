//
//  ANEExtensionFuncAV.h
//  wmaneSDK
//
//  Created by wuyoujian on 17/3/1.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

@interface ANEExtensionFuncAV : NSObject

- (instancetype)initWithContext:(FREContext)extensionContext;
- (FREObject)playAV:(FREObject)text;
- (FREObject)playAVForLocal:(FREObject)text;


@end
