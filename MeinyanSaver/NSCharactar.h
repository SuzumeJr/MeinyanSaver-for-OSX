//
//  NSCharactar.h
//  MeinyanSaver
//
//  Created by 梅村 直寛 on 2013/06/27.
//  Copyright (c) 2013年 梅村 直寛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharactar : NSObject
-(BOOL)initData:(NSRect)rectScreen L2RPattern:(NSArray*)aL2RPt R2LPattern:(NSArray*)aR2LPt;
-(BOOL)setWaitPattern:(NSInteger)iWait;
-(BOOL)Action;
@end
