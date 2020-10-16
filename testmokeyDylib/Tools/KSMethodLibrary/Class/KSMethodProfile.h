//
//  KSMethodProfile.h
//  KSMethodLibrary
//
//  Created by kensuo on 16/6/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSMethodProfile : NSObject

//the param list of end oparam must be -1
extern id invokeFunctor(id target,
                        SEL selector,
                        NSInteger param1,
                        ...);

@end
