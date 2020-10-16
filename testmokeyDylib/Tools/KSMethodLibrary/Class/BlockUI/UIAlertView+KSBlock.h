//
//  UIAlertView+KSBlock.h
//  QTL
//
//  Created by kensuo on 17/1/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIAlertView(KSBlock)<UIAlertViewDelegate>

//UIAlertView
- (void)showWithCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler;

@end
