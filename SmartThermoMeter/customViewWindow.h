//
//  customViewWindow.h
//  SmartThermoMeter
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface customViewWindow : NSViewController
@property (strong) IBOutlet NSButton *showAppButton;

+ (instancetype)viewController;

@end
