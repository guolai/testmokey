//
//  NSArray+WeakArray.h
//  QTCF
//
//  Created by Liang Jin on 15/6/7.
//  Copyright (c) 2015年 tencent. All rights reserved.
//


#import <Foundation/Foundation.h>

///
/// Category on NSArray that provides read methods for weak pointers
/// NOTE: These methods may scan the whole array
///
@interface NSArray(WeakArray)

- (__weak id)weakObjectForIndex:(NSUInteger)index;
-(id<NSFastEnumeration>)weakObjectsEnumerator;
- (BOOL)isExistObjectInWeekArray:(id)object;

@end

///
/// Category on NSMutableArray that provides write methods for weak pointers
/// NOTE: These methods may scan the whole array
///
@interface NSMutableArray (FRSWeakArray)

-(void)addWeakObject:(id)object;
-(void)removeWeakObject:(id)object;

-(void)cleanWeakObjects;

@end