//
//  KSMethodProfile.m
//  KSMethodLibrary
//
//  Created by kensuo on 16/6/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "KSMethodProfile.h"
#import "NSInvocation+additions.h"

@implementation KSMethodProfile

id invokeFunctor(id target,
                 SEL selector,
                 NSInteger param,
                 ...) {
    
    NSInteger anIndex = 2;
    NSInvocation *invoke = nil;
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature == nil) return NULL;
    invoke = [NSInvocation invocationWithMethodSignature:signature];
    [invoke setTarget:target];
    [invoke setSelector:selector];
    
    va_list args;
    va_start(args, param);
    for (NSInteger arg = param; arg != -1; arg = va_arg(args, int)) {
        //        NSLog(@"%d", arg);
        
        [invoke setArgument:&arg atIndex:anIndex++];
    }
    va_end(args);
    
    [invoke invokeWithTarget:target];
    
    return [invoke returnValueAsObject];
}

@end
