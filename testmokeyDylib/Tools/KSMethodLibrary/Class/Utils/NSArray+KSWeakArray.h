//
//  NSArray+KSWeakArray.h
//  QTL
//
//  Created by kensuo on 17/1/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(KSWeakArray)

- (__weak id)weakObjectForIndex:(NSUInteger)index;
-(id<NSFastEnumeration>)weakObjectsEnumerator;
- (BOOL)isExistObjectInWeekArray:(id)object;

@end

///
/// Category on NSMutableArray that provides write methods for weak pointers
/// NOTE: These methods may scan the whole array
///
@interface NSMutableArray (KSMWeakArray)

-(void)addWeakObject:(id)object;
-(void)removeWeakObject:(id)object;

-(void)cleanWeakObjects;

@end
