//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  testmokeyDylib.m
//  testmokeyDylib
//
//  Created by Hbo on 2020/10/16.
//  Copyright (c) 2020 HaiboZhu. All rights reserved.
//

#import "testmokeyDylib.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import <Cycript/Cycript.h>
#import <MDCycriptManager.h>
#import "KSMethodLibrary.h"

CHConstructor{
    printf(INSERT_SUCCESS_WELCOME);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
#ifndef __OPTIMIZE__
        CYListenServer(6666);

        MDCycriptManager* manager = [MDCycriptManager sharedInstance];
        [manager loadCycript:NO];

        NSError* error;
        NSString* result = [manager evaluateCycript:@"UIApp" error:&error];
        NSLog(@"result: %@", result);
        if(error.code != 0){
            NSLog(@"error: %@", error.localizedDescription);
        }
#endif
        
    }];
}


CHDeclareClass(CustomViewController)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

//add new method
CHDeclareMethod1(void, CustomViewController, newMethod, NSString*, output){
    NSLog(@"This is a new method : %@", output);
}

#pragma clang diagnostic pop

CHOptimizedClassMethod0(self, void, CustomViewController, classMethod){
    NSLog(@"hook class method");
    CHSuper0(CustomViewController, classMethod);
}

CHOptimizedMethod0(self, NSString*, CustomViewController, getMyName){
    //get origin value
    NSString* originName = CHSuper(0, CustomViewController, getMyName);
    
    NSLog(@"origin name is:%@",originName);
    
    //get property
    NSString* password = CHIvar(self,_password,__strong NSString*);
    
    NSLog(@"password is %@",password);
    
    [self newMethod:@"output"];
    
    //set new property
    self.newProperty = @"newProperty";
    
    NSLog(@"newProperty : %@", self.newProperty);
    
    //change the value
    return @"Hbo";
    
}

//add new property
CHPropertyRetainNonatomic(CustomViewController, NSString*, newProperty, setNewProperty);

CHConstructor{
    CHLoadLateClass(CustomViewController);
    CHClassHook0(CustomViewController, getMyName);
    CHClassHook0(CustomViewController, classMethod);
    
    CHHook0(CustomViewController, newProperty);
    CHHook1(CustomViewController, setNewProperty);
}


CHDeclareClass(GPUImageFramebuffer)

CHOptimizedMethod0(self, void *, GPUImageFramebuffer, newCGImageFromFramebufferContents33333) {
    NSLog(@"newCGImageFromFramebufferContents33333");
}

//CHDeclareMethod0(UIImage *, GPUImageFramebuffer, genenImageFromBuffer) {
//    [self activateFramebuffer];
//}


//CHDeclareMethod1(UIImage *, GPUImageFramebuffer, genenImageFromBuffer, NSString*, output){
//    NSLog(@"genenImageFromBuffer : %@", output);
//    UIImage *retImg = nil;
//
//    NSUInteger totalNumberOfPixels = 0;//round(self.size.width * self.size.height);
//        static GLubyte *rawImagePixels = nil;
//        if (rawImagePixels == NULL){
//            rawImagePixels = (GLubyte *)malloc(totalNumberOfPixels * 4);
//        }
//
////        [GPUImageContext useImageProcessingContext];
////        [self performSelector:NSSelectorFromString(@"activateFramebuffer")];
//        [self activateFramebuffer];
//        glReadPixels(0, 0, (int)self.size.width, (int)self.size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
//
//        CGDataProviderRef dataProvider = CGDataProviderCreateWithData((__bridge_retained void*)self, rawImagePixels, totalNumberOfPixels*4, nil);
//
//
//
//        CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
//
//
//        CGImageRef cgImageFromBytes = CGImageCreate((int)inputFramebufferForDisplay.size.width, (int)inputFramebufferForDisplay.size.height, 8, 32, (int)inputFramebufferForDisplay.size.width*4, defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
//        UIImage *image = [UIImage imageWithCGImage:cgImageFromBytes];
//        CGImageRelease(cgImageFromBytes);
//        CGDataProviderRelease(dataProvider);
//        CGColorSpaceRelease(defaultRGBColorSpace);
//        NSLog(@"%@", image);
//
//    return retImg;
//
//}


CHConstructor{
    CHLoadLateClass(GPUImageFramebuffer);
    CHHook0(GPUImageFramebuffer, newCGImageFromFramebufferContents33333);
}

CHDeclareClass(GPUImageStarGlareFilter)
CHOptimizedMethod2(self, void, GPUImageStarGlareFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
    NSLog(@"%@", self);
    GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
        GPUImageFramebuffer *tmpfb = fb1;
    invokeFunctor(fb1, @selector(newCGImageFromFramebufferContents33333), nil);
//        CGImageRef imageRef = [tmpfb newCGImageFromFramebufferContents33333];
    //     [tmpfb performSelector:NSSelectorFromString(@"newCGImageFromFramebufferContents33333")];
    //    [fb1 newCGImageFromFramebufferContents33333];
    //    GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,GPUImageFramebuffer *);
    //    NSLog(@"%@---%@", fb1, fb2);
    CHSuper2(GPUImageStarGlareFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
}
//CHOptimizedMethod1(self, void, GPUImageStarGlareFilter, setColorCoeff, void *, arg1) {
//    NSLog(@"%p", arg1);
////    CHSuper1(GPUImageStarGlareFilter, colorCoeff, arg1);
//}

CHConstructor{
    CHLoadLateClass(GPUImageStarGlareFilter);
    CHHook2(GPUImageStarGlareFilter, renderToTextureWithVertices, textureCoordinates);
    //    CHHook1(GPUImageStarGlareFilter, setColorCoeff);
}
