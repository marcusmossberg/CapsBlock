//
//  main.m
//  QuartzTest
//
//  Created by Marcus Mossberg on 2019-12-30.
//  Copyright © 2019 Marcus Mossberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
bool capsLock = false;
bool shiftSet = false;
bool optionSet = false;

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {

    long keyCode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
    bool keyAutoRepeat = CGEventGetIntegerValueField(event, kCGKeyboardEventAutorepeat) == 1;
    
    long newKeyCode = keyCode;
    bool cancelEvent = false;
    
    long eventFlags = CGEventGetFlags(event);
    
    if(type == 14) {
        capsLock = !capsLock;
        if(!capsLock) {
            shiftSet = false;
            optionSet = false;
        }
    }
    
    if(capsLock) {
        
        if(shiftSet) {
            CGEventFlags newFlags = CGEventGetFlags(event);
            newFlags = newFlags | kCGEventFlagMaskShift;
            CGEventSetFlags(event, newFlags);
        }
        
        if(optionSet) {
            CGEventFlags newFlags = CGEventGetFlags(event);
            newFlags = newFlags | kCGEventFlagMaskAlternate;
            CGEventSetFlags(event, newFlags);
        }
        
        switch(keyCode) {
            case 53: // esc
                capsLock = false;
                shiftSet = false;
                optionSet = false;
                return NULL;
            case 34:
                newKeyCode = 126;
                break;
            case 38:
                newKeyCode = 123;
                break;
            case 40:
                newKeyCode = 125;
                break;
            case 37:
                newKeyCode = 124;
                break;
            case 14: // E -> Option
                 if(keyAutoRepeat)
                   return NULL;
                optionSet = type == kCGEventKeyDown;
                cancelEvent = true;
                break;
            case 3: // F -> LShift
                if(keyAutoRepeat)
                    return NULL;
                shiftSet = type == kCGEventKeyDown;
                cancelEvent = true;
                break;
            case 32: // U -> Home
                newKeyCode = 0x73;
                break;
            case 31: // O -> End
                newKeyCode = 0x77;
                break;
            case 5: // G -> Delete
                newKeyCode = 0x75;
                break;
        }
    }
    
    if(keyCode != newKeyCode)
         CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, newKeyCode);

    CGPoint point = CGEventGetLocation(event);
    long keyboardType = CGEventGetIntegerValueField(event, kCGMouseEventSubtype);
    
    //NSLog(@"%ld, %d, %ld, %d, %ld", keyCode, type, eventFlags, capsLock, keyboardType);
    
    if(cancelEvent)
        return NULL;
    else
        return event;
}

int main(int argc, char *argv[]) {
      
    @autoreleasepool {
        CFRunLoopSourceRef runLoopSource;
        
        CGEventMask mask = CGEventMaskBit(10) |
        CGEventMaskBit(11) | CGEventMaskBit(14);

        NSLog(@"Running caps block");

        CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, myCGEventCallback, NULL);
        if (!eventTap) {
            NSLog(@"Couldn't create event tap!");
            exit(1);
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

        CGEventTapEnable(eventTap, true);

        CFRunLoopRun();
        NSLog(@"Releasing event tap");
        CFRelease(eventTap);
        CFRelease(runLoopSource);
    }

    exit(0);
}
