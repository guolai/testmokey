//
//  KSBaseManager.h
//  KSMethodLibrary
//
//  Created by kensuo on 16/6/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+KSWeakArray.h"
#import "KSMethodProfile.h"
#import "UIAlertView+KSBlock.h"
#import "UIControl+KSBlock.h"
#import "UIActionSheet+KSBlock.h"

@interface KSBaseManager : NSObject

+ (instancetype)shareInstance;

+ (void)freeSharedInstance; //释放

- (void)initManagerData;    //初始化数据

- (void)performSelectorByDelegate:(SEL)method object:(id)object;
//添加观察
- (void)addDelegateObserver:(id)delegate;
//删除观察
- (void)removeDelegateObserver:(id)delegate;

@end
