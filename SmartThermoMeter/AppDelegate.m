//
//  AppDelegate.m
//  SmartThermoMeter
//
//  Created by YuansMacMini on 15/6/11.
//  Copyright (c) 2015年 Yuan. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowConfiguration.h"
#import "customViewWindow.h"

@interface AppDelegate ()


@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *deviceStatusLbl;
@property (weak) IBOutlet NSTextField *temperatureValueLbl;
@property (weak) IBOutlet NSSlider *customSlider;
@property (weak) IBOutlet NSProgressIndicator *bar;
@property (weak) IBOutlet NSLevelIndicator *temperatureBar;

@property NSView *customItemView;
@property NSTextField *textField;

@end

@implementation AppDelegate
UsbHID *hidDev;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_deviceStatusLbl setStringValue:@"没有任何温度计连接到Mac上."];
    [_temperatureValueLbl setStringValue:@"--.- ℃"];
    hidDev=[[UsbHID alloc]initWithVID:0x2341 withPID:0x8037];
    hidDev.delegate=self;
    [hidDev connectHID];
    [_customSlider setIntValue:88];
    [_customSlider setTarget:self];
    
    [_temperatureBar setMinValue:0];
    [_temperatureBar setMaxValue:100];
    
    
    
    // configure the status item
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = CCNPresentationTransitionSlideAndFade;
    
    
    [self presentStatusItemWithCustomView];
    [self modifyStatusTextfiled:@"--.-℃"];

}



- (void)modifyStatusTextfiled:(NSString*)text{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSCenterTextAlignment;
    paragraphStyle.minimumLineHeight = 19;
    
    NSDictionary *attributes = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:14.0], NSParagraphStyleAttributeName: paragraphStyle };
    _textField.attributedStringValue = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.backgroundColor = [NSColor clearColor];
    _textField.bordered = NO;
    _textField.editable = NO;
    _textField.selectable = NO;
    
}

- (void)presentStatusItemWithCustomView {
    NSImageView *imageView = [[NSImageView alloc] init];
    imageView.image = [NSImage imageNamed:@"statusbar-icon"];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _textField= [[NSTextField alloc] init];
    
    [self modifyStatusTextfiled:@"29.00000"];
    // FIXME: I have absolutely no idea why the heck the width of that calculated rect is shorter than the given attributed string!
    NSRect textFieldRect = [_textField.attributedStringValue boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, [NSStatusBar systemStatusBar].thickness)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin];
    
    CGFloat imageWidth = imageView.image.size.width;
    CGFloat textFieldWidth = textFieldRect.size.width;
    CGFloat systemStatusBarHeight = [NSStatusBar systemStatusBar].thickness;
    NSInteger padding = 2;
    CGFloat customItemViewWidth = padding + imageWidth + ceilf(NSWidth(textFieldRect)) + padding;
    
    
    self.customItemView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, customItemViewWidth, systemStatusBarHeight)];
    [self.customItemView addSubview:imageView];
    [self.customItemView addSubview:_textField];
    
    NSDictionary *views = @{
                            @"imageView": imageView,
                            @"textField": _textField,
                            };
    NSDictionary *metrics = @{
                              @"imageWidth": @(imageWidth),
                              @"systemStatusBarHeight": @(systemStatusBarHeight),
                              @"textFieldWidth": @(textFieldWidth),
                              @"padding": @(padding),
                              };
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[imageView(imageWidth)][textField(textFieldWidth)]-(padding)-|" options:0 metrics:metrics views:views]];
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(systemStatusBarHeight)]|" options:0 metrics:metrics views:views]];
    [self.customItemView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField(systemStatusBarHeight)]|" options:0 metrics:metrics views:views]];
    
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    [sharedItem presentStatusItemWithView:self.customItemView
                    contentViewController:[customViewWindow viewController]];
    
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)usbhidDidRemove
{
    [_deviceStatusLbl setStringValue:@"温度计已从Mac拔掉了."];
}

- (void)usbhidDidMatch
{
    NSLog(@"检测到USB设备插入.");
    [_deviceStatusLbl setStringValue:@"温度计已连接至Mac了."];
}

- (void)usbhidDidRecvData:(uint8_t*)recvData length:(CFIndex)reportLength reportId:(CFIndex)reportId;
{
    //uint32_t hostData = CFSwapInt32BigToHost(*(const uint32_t *)recvData);
    //NSLog(@"收到数据:%X %X %X %X",recvData[0],recvData[1],recvData[2],recvData[3]);
    uint8_t buf[4];
    memcpy(buf, recvData,sizeof(buf));
    float value = *((float *)(&buf));
    [_temperatureBar setDoubleValue:value];
    

    [_temperatureValueLbl setStringValue:[NSString stringWithFormat: @"%.1f ℃", value]];
    [self modifyStatusTextfiled:[NSString stringWithFormat: @"%.1f ℃", value]];
}

@end
