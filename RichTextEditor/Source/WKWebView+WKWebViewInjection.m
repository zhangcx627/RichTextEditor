//
//  WKWebView+WKWebViewInjection.m
//  RichTextEditor
//
//  Created by chenxu on 2019/8/13.
//  Copyright © 2019 chenxu. All rights reserved.
//

#import "WKWebView+WKWebViewInjection.h"


@implementation WKWebView (WKWebViewInjection)

static void (*originalIMP)(id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) = NULL;

void interceptIMP (id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
    originalIMP(self, _cmd, arg0, TRUE, arg2, arg3);
}

- (void)keyboardRequiresUserInteraction:(BOOL) show {
    if (show) {
       [self setWkWebViewShowKeybord];
    }
}

-(void) setWkWebViewShowKeybord {
    Class cls = NSClassFromString(@"WKContentView");
    SEL originalSelector = NSSelectorFromString(@"_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    IMP impOvverride = (IMP) interceptIMP;
    originalIMP = (void *)method_getImplementation(originalMethod);
    method_setImplementation(originalMethod, impOvverride);
}

- (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

- (id)syncEvalJavascriptString:(NSString *)jsCode {
    __block id returnValue = nil;
    __block BOOL finished = NO;
    [self evaluateJavaScript:jsCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        returnValue = result;
        finished = YES;
    }];

    while (!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return returnValue;
}

@end
