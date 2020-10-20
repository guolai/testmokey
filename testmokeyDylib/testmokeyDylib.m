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


static id gpuFilter = nil;

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



CHDeclareClass(GPUImageFilter)
CHOptimizedMethod2(self,id,GPUImageFilter,initWithVertexShaderFromString,NSString *,arg1,fragmentShaderFromString,NSString *,arg2){
    NSLog(@"class %@",self);
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    NSLog(@"bob v:%@",arg1);
    NSLog(@"bob f:%@",arg2);
    NSLog(@"===============================\n");
    NSString *fragStr = arg2;
    if([strSelf containsString:@"GPUImageStarGlareFilter"]) {
//        gpuFilter = self;
        NSLog(@"GPUImageStarGlareFilter find");
    }
    if([strSelf containsString:@"GPUImageAFLengthFilter"]) {
        fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; uniform float afLength; void main() { vec3 src= min(texture2D(inputImageTexture, textureCoordinate).rgb,vec3(1.0)); vec3 dst= (texture2D(inputImageTexture2, textureCoordinate).rgb-afLength); gl_FragColor = texture2D(inputImageTexture, textureCoordinate); }";
        NSLog(@"GPUImageAFLengthFilter find");
    }
    if([strSelf containsString:@"GPUImageExtractHighLightAreaNoise"]) {
        gpuFilter = self;
//        fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; uniform float threshold; uniform float scalar; uniform float HLVig; uniform float grayScale; uniform float time; uniform float aspectRate; const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721); vec4 permute(vec4 x){ return mod(((x*34.0)+1.0)*x, 289.0); } vec4 taylorInvSqrt(vec4 r){ return 1.79284291400159 - 0.85373472095314 * r; } vec3 fade(vec3 t) { return t*t*t*(t*(t*6.0-15.0)+10.0); } void main() { vec3 col=texture2D(inputImageTexture, textureCoordinate).rgb; vec3 blu=texture2D(inputImageTexture2, textureCoordinate2).rgb; float n=0.0; if(grayScale > 0.5){ float v=col.r*0.299+col.g*0.587+col.b*0.114; float v2=blu.r*0.299+blu.g*0.587+blu.b*0.114+HLVig; float th=max(threshold,v2)+n; if(v>th){ v=(v-th)/(1.0-th)*scalar; gl_FragColor=vec4(v,v,v,1.0)*2.0; }else{  gl_FragColor=vec4(0.0,0.0,0.0,1.0); } }else{ vec3 thc=max(vec3(threshold),blu+HLVig)+n; col.r=(col.r>thc.r)?((col.r-thc.r)/(1.0-thc.r)*scalar):0.0; col.g=(col.g>thc.g)?((col.g-thc.g)/(1.0-thc.g)*scalar):0.0; col.b=(col.b>thc.b)?((col.b-thc.b)/(1.0-thc.b)*scalar):0.0; gl_FragColor=vec4(col,1.0); } }";
        NSLog(@"GPUImageExtractHighLightAreaNoise find");
    }
    if([strSelf containsString:@"GPUImageGlareCompositionFilter"]) {
//        gpuFilter = self;
         fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; varying highp vec2 textureCoordinate3; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; uniform sampler2D inputImageTexture3; uniform vec3 mixCoeff; void main() { gl_FragColor = texture2D(inputImageTexture3, textureCoordinate3);}";
        NSLog(@"GPUImageGlareCompositionFilter find");
    }
    if([strSelf containsString:@"TempGlareCompositionFilter"]) {
        fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; uniform vec3 mixCoeff; void main() { gl_FragColor = texture2D(inputImageTexture2, textureCoordinate2);}";
        NSLog(@"TempGlareCompositionFilter find");
    }
    if([strSelf containsString:@"GPUImageMaxFilter"]) {
        fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; void main() { gl_FragColor = texture2D(inputImageTexture, textureCoordinate);}";
        NSLog(@"GPUImageMaxFilter find");
    }
    
    if([strSelf containsString:@"GPUImageDownSample4xFilter"]) {
//        gpuFilter = self;
        NSLog(@"GPUImageDownSample4xFilter find");
    }
    if([strSelf containsString:@"GPUImageVague2Filter"]) {
//        if(!gpuFilter) {
//            gpuFilter  = self;
//        }
        NSLog(@"GPUImageVague2Filter find");
    }
    if([strSelf containsString:@"GPUImageFilter"]) {
//        if(!gpuFilter) {
//            gpuFilter  = self;
//        }
        NSLog(@"GPUImageFilter find");
    }
    if([strSelf containsString:@"GPUImageToneMappingPassFilter"]) {
//        gpuFilter = self;
        fragStr = @"precision highp float; varying highp vec2 textureCoordinate; varying highp vec2 textureCoordinate2; varying highp vec2 textureCoordinate3; uniform sampler2D inputImageTexture; uniform sampler2D inputImageTexture2; uniform sampler2D inputImageTexture3; uniform vec3 uCOLOR; uniform vec3 uTONE; uniform vec3 uFX; uniform float uFilter; uniform float isHiddenStart; const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721); const vec3 AvgLumin = vec3(0.5, 0.5, 0.5); void main(){ if(isHiddenStart > 0.5){ gl_FragColor = texture2D(inputImageTexture, textureCoordinate); }else{ vec4 textureColor = texture2D(inputImageTexture, textureCoordinate); vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2); vec4 whiteColor = vec4(1.0, 0.0, 0.0, 1.0); gl_FragColor = textureColor2; } }";
        NSLog(@"GPUImageToneMappingPassFilter find");
    }
    return CHSuper2(GPUImageFilter,initWithVertexShaderFromString,arg1,fragmentShaderFromString,fragStr);
}

CHConstructor{
    CHLoadLateClass(GPUImageFilter);
    CHHook2(GPUImageFilter,initWithVertexShaderFromString,fragmentShaderFromString);
}

//- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
//- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
CHDeclareClass(GPUImageOutput)
CHOptimizedMethod2(self, void, GPUImageOutput, addTarget, id, arg1, atTextureLocation, int, arg2) {
    NSLog(@"addTarget %@, %@, %d", self, arg1, arg2);
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
//TempGlareCompositionFilter

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
////        glFinish();
////        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image1 = invokeFunctor(fb1, @selector(genenImageFromBuffer), -1);
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
////        GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,__strong GPUImageFramebuffer *);
////        UIImage *image2 = invokeFunctor(fb2, @selector(genenImageFromBuffer), -1);
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

//GPUImageToneMappingPassFilter
CHDeclareClass(GPUImageToneMappingPassFilter)
CHOptimizedMethod2(self, void, GPUImageToneMappingPassFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
//    invokeFunctor(self, @selector(removeAllTargets), -1);
    CHSuper2(GPUImageToneMappingPassFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
}

CHOptimizedMethod1(self, void, GPUImageToneMappingPassFilter, informTargetsAboutNewFrameAtTime, void *, arg1) {
//    NSLog(@"informTargetsAboutNewFrameAtTime");
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    if(![strSelf containsString:@"GPUImageToneMappingPassFilter"])
    {
        CHSuper1(GPUImageToneMappingPassFilter, informTargetsAboutNewFrameAtTime, arg1);
    }
}

CHConstructor{
    CHLoadLateClass(GPUImageToneMappingPassFilter);
    CHHook2(GPUImageToneMappingPassFilter, renderToTextureWithVertices, textureCoordinates);
    CHHook1(GPUImageToneMappingPassFilter, informTargetsAboutNewFrameAtTime);
}

//- (id)initWithImage:(UIImage *)newImageSource;
//- (id)initWithCGImage:(CGImageRef)newImageSource;
//CHDeclareClass(GPUImagePicture)
//CHOptimizedMethod1(self, void, GPUImagePicture, initWithImage, id, arg1) {
//    NSLog(@"addTarget %@, %@", self, arg1);
//
//    CHSuper1(GPUImagePicture, initWithImage, arg1);
//}
//
//CHOptimizedMethod1(self, void, GPUImagePicture, initWithCGImage, void *, arg1) {
//    NSLog(@"addTarget %@, %@", self, arg1);
//
//    CHSuper1(GPUImagePicture, initWithCGImage, arg1);
//}
//
//CHConstructor{
//    CHLoadLateClass(GPUImagePicture);
//    CHHook1(GPUImagePicture, initWithImage);
//    CHHook1(GPUImagePicture, initWithCGImage);
//}


CHDeclareClass(GPUImageView)

CHDeclareClass(FilterViewController)

CHOptimizedMethod0(self, void, FilterViewController, startStarEffect) {
    CHSuper0(FilterViewController, startStarEffect);
//    GPUImageFilter *tmpfilter = CHIvar(self,extractHighLightAreaNoiseFilter,__strong GPUImageFilter *);
    UIView *gpuView = CHIvar(self,_gpuImageView,__strong UIView *);
//    GPUImageFilter *bobFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:fragStr];

//    invokeFunctor(gpuFilter, @selector(addTarget:),gpuView, -1);
//    GPUImageView *gpuView = [[GPUImageView alloc] init];

}

//CHOptimizedMethod3(self, id, FilterViewController, genStarStreak, id, arg1, withDir, long, arg2, withType, long, arg3) {
//    NSLog(@"genStarStreak %@, dir:%d,type:%d", arg1, arg2, arg3);
//    return CHSuper3(FilterViewController, genStarStreak, arg1, withDir, arg2, withType, arg3);
//}

CHConstructor{
    CHLoadLateClass(GPUImageView);
    CHLoadLateClass(FilterViewController);
    CHHook0(FilterViewController, startStarEffect);
    //    CHHook3(FilterViewController, genStarStreak, withDir, withType);
}


CHDeclareClass(GPUImageDownSample4xFilter)
CHOptimizedMethod2(self, void, GPUImageDownSample4xFilter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
    CHSuper2(GPUImageDownSample4xFilter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    if([strSelf containsString:@"GPUImageDownSample4xFilter"]) {
        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
        NSValue *sizeValue = invokeFunctor(fb1, @selector(valueForKey:),@"size", -1);
        NSValue *textureSize = invokeFunctor(self, @selector(valueForKey:),@"twoTexelSize", -1);
        NSValue *sizeoffbo = invokeFunctor(self, @selector(sizeOfFBO), -1);
        NSLog(@"%@, %@, %@", sizeValue, textureSize,sizeoffbo);
    }
}

CHDeclareClass(GPUImageVague2Filter)
CHOptimizedMethod2(self, void, GPUImageVague2Filter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
    CHSuper2(GPUImageVague2Filter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    if([strSelf containsString:@"GPUImageVague2Filter"]) {
        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
        NSValue *sizeValue = invokeFunctor(fb1, @selector(valueForKey:),@"size", -1);
        NSValue *sizeoffbo = invokeFunctor(self, @selector(sizeOfFBO), -1);
//        NSLog(@"%@, %@", sizeValue, sizeoffbo);
    }
}

CHDeclareClass(GPUImageVague1Filter)
CHOptimizedMethod2(self, void, GPUImageVague1Filter, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
    CHSuper2(GPUImageVague1Filter, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    if([strSelf containsString:@"GPUImageVague1Filter"]) {
        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
        NSValue *sizeValue = invokeFunctor(fb1, @selector(valueForKey:),@"size", -1);
        NSValue *sizeoffbo = invokeFunctor(self, @selector(sizeOfFBO), -1);
//        NSLog(@"%@, %@", sizeValue, sizeoffbo);
    }
}
//GPUImageExtractHighLightAreaNoise
CHDeclareClass(GPUImageExtractHighLightAreaNoise)
CHOptimizedMethod2(self, void, GPUImageExtractHighLightAreaNoise, renderToTextureWithVertices, void *, arg1, textureCoordinates, void *, arg2){
    CHSuper2(GPUImageExtractHighLightAreaNoise, renderToTextureWithVertices, arg1, textureCoordinates, arg2);
    NSString *strSelf = [NSString stringWithFormat:@"%@", self];
    if([strSelf containsString:@"GPUImageExtractHighLightAreaNoise"]) {
        GPUImageFramebuffer *fb1 = CHIvar(self,firstInputFramebuffer,__strong GPUImageFramebuffer *);
        NSValue *sizeValue = invokeFunctor(fb1, @selector(valueForKey:),@"size", -1);
        GPUImageFramebuffer *fb2 = CHIvar(self,secondInputFramebuffer,__strong GPUImageFramebuffer *);
        NSValue *sizeValue2 = invokeFunctor(fb2, @selector(valueForKey:),@"size", -1);
        NSValue *sizeoffbo = invokeFunctor(self, @selector(sizeOfFBO), -1);
        
         NSValue *HLVig = invokeFunctor(self, @selector(valueForKey:),@"HLVig", -1);
        NSValue *aspectRate = invokeFunctor(self, @selector(valueForKey:),@"aspectRate", -1);
        NSValue *grayScale = invokeFunctor(self, @selector(valueForKey:),@"grayScale", -1);
        NSValue *scalar = invokeFunctor(self, @selector(valueForKey:),@"scalar", -1);
        NSValue *threshold = invokeFunctor(self, @selector(valueForKey:),@"threshold", -1);
        NSValue *time = invokeFunctor(self, @selector(valueForKey:),@"time", -1);
        NSLog(@"1inputSize:%@,2 inputSize:%@, %@", sizeValue, sizeValue2,sizeoffbo);
        NSLog(@"param:%@, %@, %@, %@, %@, %@", HLVig, aspectRate,grayScale,  scalar,threshold,time);
        
    }
}

CHConstructor{
    CHLoadLateClass(GPUImageDownSample4xFilter);
    CHHook2(GPUImageDownSample4xFilter, renderToTextureWithVertices, textureCoordinates);
    CHLoadLateClass(GPUImageVague1Filter);
    CHHook2(GPUImageVague1Filter, renderToTextureWithVertices, textureCoordinates);
    CHLoadLateClass(GPUImageVague2Filter);
    CHHook2(GPUImageVague2Filter, renderToTextureWithVertices, textureCoordinates);
    CHLoadLateClass(GPUImageExtractHighLightAreaNoise);
    CHHook2(GPUImageExtractHighLightAreaNoise, renderToTextureWithVertices, textureCoordinates);
}
