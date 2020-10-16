//
//  NSArray+KSWeakArray.m
//  QTL
//
//  Created by kensuo on 17/1/10.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "NSArray+KSWeakArray.h"

@interface KSArrayWeakPointer : NSObject

@property (nonatomic, weak) NSObject *object;

@end

@implementation KSArrayWeakPointer

@end

@implementation NSArray(KSWeakArray)

- (__weak id)weakObjectForIndex:(NSUInteger)index
{
    KSArrayWeakPointer *ptr = [self objectAtIndex:index];
    return ptr.object;
}

- (KSArrayWeakPointer *)weakPointerForObject:(id)object
{
    // Linear search for the object in question
    for (KSArrayWeakPointer *ptr in self) {
        if(ptr) {
            if(ptr.object == object) {
                return ptr;
            }
        }
    }
    
    return nil;
}

- (BOOL)isExistObjectInWeekArray:(id)object{
    
    for (KSArrayWeakPointer *ptr in self) {
        if(ptr) {
            if(ptr.object == object) {
                return YES;
            }
        }
    }
    return NO;
}

-(id<NSFastEnumeration>)weakObjectsEnumerator
{
    NSMutableArray *enumerator = [[NSMutableArray alloc] init];
    for (KSArrayWeakPointer *ptr in self) {
        if(ptr && ptr.object) {
            [enumerator addObject:ptr.object];
        }
    }
    return enumerator;
}

@end

@implementation NSMutableArray (KSMWeakArray)

-(void)addWeakObject:(id)object
{
    if(!object)
        return;
    
    BOOL isExsit = [self isExistObjectInWeekArray:object];
    
    if (!isExsit) {
        KSArrayWeakPointer *ptr = [[KSArrayWeakPointer alloc] init];
        ptr.object = object;
        [self addObject:ptr];
    }
    [self cleanWeakObjects];
}

-(void)removeWeakObject:(id)object
{
    if(!object)
        return;
    
    // Find the underlying object in the array
    KSArrayWeakPointer *ptr = [self weakPointerForObject:object];
    
    if(ptr) {
        
        [self removeObject:ptr];
        
        [self cleanWeakObjects];
    }
}

-(void)cleanWeakObjects
{
    // Build a list of dead references
    NSMutableArray *toBeRemoved = [[NSMutableArray alloc] init];
    for (KSArrayWeakPointer *ptr in self) {
        if(ptr && !ptr.object) {
            [toBeRemoved addObject:ptr];
        }
    }
    
    // Remove the dead references from the collection
    for(KSArrayWeakPointer *ptr in toBeRemoved) {
        [self removeObject:ptr];
    }
}


@end
