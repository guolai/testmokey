//
//  KSBaseManager.m
//  KSMethodLibrary
//
//  Created by kensuo on 16/6/23.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "KSBaseManager.h"
#import <objc/runtime.h>


@interface KSBaseManager ()

@property(nonatomic, strong)NSMutableArray              *delegatesArray;
@end

@implementation KSBaseManager

+ (instancetype)shareInstance{
    
    id instance = objc_getAssociatedObject(self, @"KSBaseManager");
    
    if (!instance)
    {
        instance = [[super allocWithZone:NULL] init];
        [instance initManagerData];
        objc_setAssociatedObject(self, @"KSBaseManager", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return instance;
}

+ (void)freeSharedInstance
{
    Class selfClass = [self class];
    objc_setAssociatedObject(selfClass, @"KSBaseManager", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self shareInstance] ;
}
- (id) copyWithZone:(struct _NSZone *)zone
{
    Class selfClass = [self class];
    return [selfClass shareInstance] ;
}

- (void)initManagerData{

    self.delegatesArray = [NSMutableArray array];
}

- (void)addDelegateObserver:(id)delegate{
    
    if (delegate == nil) {
        return;
    }
    [_delegatesArray addWeakObject:delegate];
    
}

- (void)removeDelegateObserver:(id)delegate{
    
    if (delegate == nil) {
        return;
    }
    [_delegatesArray removeWeakObject:delegate];
}

- (void)performSelectorByDelegate:(SEL)method object:(id)object{
    
    if (method == nil) {
        return;
    }
    
    [_delegatesArray cleanWeakObjects];
    for (int i = 0; i < [_delegatesArray count]; i++) {
        __weak  id  _delegate = [_delegatesArray weakObjectForIndex:i];
        if (_delegate) {
            if (object) {
                invokeFunctor(_delegate, method, object, -1);
            }
            else{
                invokeFunctor(_delegate, method, -1);
            }
        }
    }
}

@end
