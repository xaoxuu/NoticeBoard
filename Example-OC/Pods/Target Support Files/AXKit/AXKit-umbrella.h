#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AXKit.h"
#import "AXDebugUtilities.h"
#import "AXMacros.h"
#import "AXResult.h"
#import "CoreGraphics+AXAdd.h"
#import "GCD+AXAdd.h"
#import "NSArray+AXAdd.h"
#import "NSBundle+AXAdd.h"
#import "NSDate+AXAdd.h"
#import "NSDateFormatter+AXAdd.h"
#import "NSDictionary+AXAdd.h"
#import "NSError+AXAdd.h"
#import "NSLog+AXAdd.h"
#import "NSObject+AXAdd.h"
#import "NSObject+AXJsonAdd.h"
#import "NSString+AXAdd.h"
#import "NSString+AXFileManager.h"
#import "NSTimer+AXAdd.h"
#import "NSUserDefaults+AXAdd.h"
#import "_AXEventTarget.h"
#import "_AXKitBundle.h"
#import "_AXKitError.h"
#import "CALayer+AXAdd.h"
#import "UIActivityIndicatorView+AXAdd.h"
#import "UIAlertController+AXAdd.h"
#import "UIApplication+AXAdd.h"
#import "UIBarButtonItem+AXAdd.h"
#import "UIColor+AXAdd.h"
#import "UIColor+AXColorPack.h"
#import "UIColor+MDColorPack.h"
#import "UIControl+AXAdd.h"
#import "UIImage+AXAdd.h"
#import "UIImageView+AXAdd.h"
#import "UIImageView+AXGetColor.h"
#import "UINavigationBar+AXAdd.h"
#import "UINavigationController+AXAdd.h"
#import "UINavigationItem+AXAdd.h"
#import "UIResponder+AXAdd.h"
#import "UITabBar+AXAdd.h"
#import "UITextField+AXAdd.h"
#import "UITextView+AXAdd.h"
#import "UIView+AXAdd.h"
#import "UIView+AXAnimation.h"
#import "UIView+AXFrameAdd.h"
#import "UIView+AXGestureAdd.h"
#import "UIViewController+AXAdd.h"

FOUNDATION_EXPORT double AXKitVersionNumber;
FOUNDATION_EXPORT const unsigned char AXKitVersionString[];

