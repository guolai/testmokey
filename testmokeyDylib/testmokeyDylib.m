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
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>
#import "KSMethodLibrary.h"
#import <Photos/Photos.h>

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

//CHDeclareClass(FilterViewController)
//CHOptimizedMethod3(self, id, FilterViewController, genStarStreak, id, arg1, withDir, long, arg2, withType, long, arg3) {
//    NSLog(@"genStarStreak %@, dir:%d,type:%d", arg1, arg2, arg3);
//    return CHSuper3(FilterViewController, genStarStreak, arg1, withDir, arg2, withType, arg3);
//}
//
//CHConstructor{
//    CHLoadLateClass(FilterViewController);
//
//    CHHook3(FilterViewController, genStarStreak, withDir, withType);
//}

CHDeclareClass(GPUImageFilter)
CHOptimizedMethod2(self,id,GPUImageFilter,initWithVertexShaderFromString,NSString *,arg1,fragmentShaderFromString,NSString *,arg2){
    NSLog(@"class %@",self);
    NSLog(@"bob v:%@",arg1);
    NSLog(@"bob f:%@",arg2);
    NSLog(@"===============================\n");
//    LogMessage(@"filter", 1, arg2);
    return CHSuper2(GPUImageFilter,initWithVertexShaderFromString,arg1,fragmentShaderFromString,arg2);
}

CHConstructor{
    CHLoadLateClass(GPUImageFilter);
    CHHook2(GPUImageFilter,initWithVertexShaderFromString,fragmentShaderFromString);
}

//- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
//- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
CHDeclareClass(GPUImageOutput)
CHOptimizedMethod2(self, void, GPUImageOutput, addTarget, id, arg1, atTextureLocation, int, arg2) {
    NSLog(@"addTarget %@, %@", self, arg1);
    if([arg1 isKindOfClass:NSClassFromString(@"GPUImageStarGlareFilter")]) {
        NSLog(@"GPUImageStarGlareFilter find");
    }
    if([arg1 isKindOfClass:NSClassFromString(@"GPUImageExtractHighLightAreaNoise")]) {
        NSLog(@"GPUImageExtractHighLightAreaNoise find");
    }
    if([arg1 isKindOfClass:NSClassFromString(@"GPUImageGlareCompositionFilter")]) {
        NSLog(@"GPUImageGlareCompositionFilter find");
    }
    if([arg1 isKindOfClass:NSClassFromString(@"TempGlareCompositionFilter")]) {
        NSLog(@"TempGlareCompositionFilter find");
    }
    CHSuper2(GPUImageOutput, addTarget, arg1, atTextureLocation, arg2);
}
CHConstructor{
    CHLoadLateClass(GPUImageOutput);
    CHHook2(GPUImageOutput, addTarget, atTextureLocation);
}

CHDeclareClass(GPUImageFramebuffer)

//CHOptimizedMethod0(self, void *, GPUImageFramebuffer, newCGImageFromFramebufferContents) {
//    NSLog(@"newCGImageFromFramebufferContents");
//    return CHSuper0(GPUImageFramebuffer, newCGImageFromFramebufferContents);
//}
////CHOptimizedMethod
CHDeclareMethod0(UIImage *, GPUImageFramebuffer, genenImageFromBuffer) {
    NSLog(@"genenImageFromBuffer");
    NSValue *sizeValue = invokeFunctor(self, @selector(valueForKey:),@"size", -1);
    CGSize size = sizeValue.CGSizeValue;
    NSUInteger totalNumberOfPixels = round(size.width * size.height);
    GLubyte *rawImagePixels = nil;
    if (rawImagePixels == NULL){
        rawImagePixels = (GLubyte *)malloc(totalNumberOfPixels * 4);
    }

    invokeFunctor(self, @selector(activateFramebuffer), -1);
    glReadPixels(0, 0, (int)size.width, (int)size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);

    CGDataProviderRef dataProvider = CGDataProviderCreateWithData((__bridge_retained void*)self, rawImagePixels, totalNumberOfPixels*4, nil);

    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();

    CGImageRef cgImageFromBytes = CGImageCreate((int)size.width, (int)size.height, 8, 32, (int)size.width*4, defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImageFromBytes];
    CGImageRelease(cgImageFromBytes);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
//    free(rawImagePixels);
    NSLog(@"%@", image);
    if(image) {
        NSData* imageData =  UIImagePNGRepresentation(image);
        UIImage* pngImage = [UIImage imageWithData:imageData];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:pngImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@",@"保存失败");
            } else {
                NSLog(@"%@",@"保存成功");
            }
        }];
    }
    return image;
}



CHConstructor{
    CHLoadLateClass(GPUImageFramebuffer);
//    CHHook0(GPUImageFramebuffer, genenImageFromBuffer);
//    CHHook0(GPUImageFramebuffer, newCGImageFromFramebufferContents);
}

//CHDeclareClass(GPUImageStarGlareFilter)
//CHOptimizedMethod2(self, void, GPUImageStarGlareFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
////    NSString *pSlef = [NSString stringWithFormat:@"%p", self];
////    NSLog(@"%@, %@", self, pSlef);
////    static int count = 0;
////    static NSDictionary *dic = nil;
////    if(!dic) {
////        dic = [[NSMutableDictionary alloc] init];
////    }
////
////    if(count >= 300 && ![dic objectForKey:pSlef]) {
////        [dic setValue:@"123" forKey:pSlef];
////        glFinish();
////        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image1 = invokeFunctor(fb1, @selector(genenImageFromBuffer), -1);
////        if(image1) {
////            UIImageWriteToSavedPhotosAlbum(image1, nil, nil, nil);
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
////
////        NSLog(@"%@", image1);
//////        if(secondInputFramebuffer) {
//////            GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,__strong GPUImageFramebuffer *);
//////            UIImage *image2 = invokeFunctor(fb2, @selector(genenImageFromBuffer), -1);
//////            NSLog(@"%@---%@", image1, image2);
//////        }
////
//////        count = 0;
////    }
////    count++;
//    CHSuper2(GPUImageStarGlareFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
//}
////CHOptimizedMethod1(self, void, GPUImageStarGlareFilter, setColorCoeff, void *, arg1) {
////    NSLog(@"%p", arg1);
//////    CHSuper1(GPUImageStarGlareFilter, colorCoeff, arg1);
////}
//
//CHConstructor{
//    CHLoadLateClass(GPUImageStarGlareFilter);
//    CHHook2(GPUImageStarGlareFilter, renderToTextureWithVertices, textureCoordinates);
//    //    CHHook1(GPUImageStarGlareFilter, setColorCoeff);
//}
////TempGlareCompositionFilter
//
//CHDeclareClass(TempGlareCompositionFilter)
//CHOptimizedMethod2(self, void, TempGlareCompositionFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
//    NSString *pSlef = [NSString stringWithFormat:@"%p", self];
//    NSLog(@"%@, %@", self, pSlef);
//    static int count = 0;
//    static NSDictionary *dic = nil;
//    if(!dic) {
//        dic = [[NSMutableDictionary alloc] init];
//    }
//
//    if(count >= 600 && ![dic objectForKey:pSlef]) {
//        [dic setValue:@"123" forKey:pSlef];
//        glFinish();
//        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
//        UIImage *image1 = invokeFunctor(fb1, @selector(genenImageFromBuffer), -1);
////        if(image1) {
////            NSData* imageData =  UIImagePNGRepresentation(image1);
////            UIImage* pngImage = [UIImage imageWithData:imageData];
////            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
////                [PHAssetChangeRequest creationRequestForAssetFromImage:pngImage];
////            } completionHandler:^(BOOL success, NSError * _Nullable error) {
////                if (error) {
////                    NSLog(@"%@",@"保存失败");
////                } else {
////                    NSLog(@"%@",@"保存成功");
////                }
////            }];
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
//        GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,__strong GPUImageFramebuffer *);
//        UIImage *image2 = invokeFunctor(fb2, @selector(genenImageFromBuffer), -1);
////        if(image2) {
////            NSData* imageData =  UIImagePNGRepresentation(image2);
////            UIImage* pngImage = [UIImage imageWithData:imageData];
////            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
////                [PHAssetChangeRequest creationRequestForAssetFromImage:pngImage];
////            } completionHandler:^(BOOL success, NSError * _Nullable error) {
////                if (error) {
////                    NSLog(@"%@",@"保存失败");
////                } else {
////                    NSLog(@"%@",@"保存成功");
////                }
////            }];
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
//
//    }
//    count++;
//    CHSuper2(TempGlareCompositionFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
//}
//
//CHConstructor{
//    CHLoadLateClass(TempGlareCompositionFilter);
//    CHHook2(TempGlareCompositionFilter, renderToTextureWithVertices, textureCoordinates);
//}
//
//CHDeclareClass(GPUImageGlareCompositionFilter)
//CHOptimizedMethod2(self, void, GPUImageGlareCompositionFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
////    NSString *pSlef = [NSString stringWithFormat:@"%p", self];
////    NSLog(@"%@, %@", self, pSlef);
////    static int count = 0;
////    static NSDictionary *dic = nil;
////    if(!dic) {
////        dic = [[NSMutableDictionary alloc] init];
////    }
////
////    if(count >= 300 && ![dic objectForKey:pSlef]) {
////        [dic setValue:@"123" forKey:pSlef];
////        glFinish();
////        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image1 = invokeFunctor(fb1, @selector(genenImageFromBuffer), -1);
////        if(image1) {
////            UIImageWriteToSavedPhotosAlbum(image1, nil, nil, nil);
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
////        GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image2 = invokeFunctor(fb2, @selector(genenImageFromBuffer), -1);
////        if(image2) {
////            UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil);
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
////        GPUImageFramebuffer *fb3 = CHIvar(self,thirdInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image3 = invokeFunctor(fb3, @selector(genenImageFromBuffer), -1);
////        if(image3) {
////            UIImageWriteToSavedPhotosAlbum(image3, nil, nil, nil);
////            NSLog(@"UIImageWriteToSavedPhotosAlbum %@", pSlef);
////        }
////    }
////    count++;
//    CHSuper2(GPUImageGlareCompositionFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
//}
//
//CHConstructor{
//    CHLoadLateClass(GPUImageGlareCompositionFilter);
//    CHHook2(GPUImageGlareCompositionFilter, renderToTextureWithVertices, textureCoordinates);
//}

//- (id)initWithImage:(UIImage *)newImageSource;
//- (id)initWithCGImage:(CGImageRef)newImageSource;
CHDeclareClass(GPUImagePicture)
CHOptimizedMethod1(self, void, GPUImagePicture, initWithImage, id, arg1) {
    NSLog(@"addTarget %@, %@", self, arg1);

    CHSuper1(GPUImagePicture, initWithImage, arg1);
}

CHOptimizedMethod1(self, void, GPUImagePicture, initWithCGImage, void *, arg1) {
    NSLog(@"addTarget %@, %@", self, arg1);

    CHSuper1(GPUImagePicture, initWithCGImage, arg1);
}

CHConstructor{
    CHLoadLateClass(GPUImagePicture);
    CHHook1(GPUImagePicture, initWithImage);
    CHHook1(GPUImagePicture, initWithCGImage);
}
