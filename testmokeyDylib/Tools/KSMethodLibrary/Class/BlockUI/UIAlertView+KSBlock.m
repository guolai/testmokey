//
//  UIAlertView+KSBlock.m
//  QTL
//
//  Created by kensuo on 17/1/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "UIAlertView+KSBlock.h"

const char alertDelegateKey;
const char alertCompletionHandlerKey;


@implementation UIAlertView(KSBlock)

-(void)showWithCompletionHandler:(void (^)(NSInteger buttonIndex))completionHandler
{
    UIAlertView *alert = (UIAlertView *)self;
    if(completionHandler != nil)
    {
        id oldDelegate = objc_getAssociatedObject(self, &alertDelegateKey);
        if(oldDelegate == nil)
        {
            objc_setAssociatedObject(self, &alertDelegateKey, oldDelegate, OBJC_ASSOCIATION_ASSIGN);
        }
        
        oldDelegate = alert.delegate;
        alert.delegate = self;
        objc_setAssociatedObject(self, &alertCompletionHandlerKey, completionHandler, OBJC_ASSOCIATION_COPY);
    }
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIAlertView *alert = (UIAlertView *)self;
    void (^theCompletionHandler)(NSInteger buttonIndex) = objc_getAssociatedObject(self, &alertCompletionHandlerKey);
    
    if(theCompletionHandler == nil)
        return;
    
    theCompletionHandler(buttonIndex);
    alert.delegate = objc_getAssociatedObject(self, &alertDelegateKey);
}

@end
