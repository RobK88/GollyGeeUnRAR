//
//  UnRARParsingUtils.m
//
//  GollyGeeUnRAR - Mac OS X GUI for unrar
//  Based on GeeUnRAR
//  Created by Robert Kennedy
//  Copyright 2022 Robert Kennedy
//
//  GeeUnRAR created by Giuliano A. Montecarlo on 3/27/11.
//  Copyright 2011 Giuliano A. Montecarlo. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "UnRARParsingUtils.h"


@implementation UnRARParsingUtils

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Status and control messages
//P = Percentage Update
//F = Extracting Filename
//O = Overwrite it?
//PWD = Password protection
//UCP = Use current password?

// Error messages
//CRC = CRC-Error
//FNF = File not found

// Terminating messages
//AO = ALL OK.
//TOT = Total errors
//NFTE = No files to extract

+ (NSArray *)parseTerminal:(NSString *)text {
    NSMutableArray *toRet = [NSMutableArray array];
    /*if([[text substringWithRange:NSMakeRange([text length]-1, 1)] isEqualToString:@"%"]) {
        NSNumber *percentage = [NSNumber numberWithDouble:[[text substringFromIndex:[text] doubleValue]];
        NSLog(@"%@ Percent", percentage);
        
        [toRet addObject:[NSArray arrayWithObjects:@"P", percentage, nil]];
    }*/
    
    
    /*
    NSMutableCharacterSet *aCharacterSet = [[NSMutableCharacterSet alloc] init];
    aCharacterSet = [NSCharacterSet newlineCharacterSet];
    
    NSRange lcEnglishRange;
    lcEnglishRange.location = (unsigned int)':';
    lcEnglishRange.length = 1;
    
    [aCharacterSet addCharactersInRange:lcEnglishRange]; 
    NSArray *lines = [text componentsSeparatedByCharactersInSet:aCharacterSet];
     */
    
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
   
    
    for(NSString *line in lines) {
        
        if([line hasSuffix:@"%"]) {
            NSNumber *percentage = [NSNumber numberWithDouble:[[line substringWithRange: NSMakeRange([line length]-4, 3)] doubleValue]];
            NSLog(@"%@ Percent", percentage);
                                    
            [toRet addObject:[NSArray arrayWithObjects:@"P", percentage, nil]];
        }
        
        // NSLog(@"Line is %@\n", line);
        
        if([line hasPrefix:@"Extracting"] && ![line hasPrefix:@"Extracting from"]) {
            NSString *file;
            if(![line hasSuffix:@"%"]) {
                file = [line substringFromIndex:12];
            } else {
                file = [line substringWithRange:NSMakeRange(12, [line length]-25)];
            }
            [toRet addObject:[NSArray arrayWithObjects:@"F", file, nil]];
        }
        
        if([line hasSuffix:@"use current password ? [Y]es, [N]o, [A]ll "]) {
            NSString *file = [line substringToIndex:[line length]-45];
            [toRet addObject:[NSArray arrayWithObjects:@"UCP", file, nil]];
        }
        
        if([line hasSuffix:@"already exists. Overwrite it ?"]) {
            NSString *file = [line substringToIndex:[line length]-31];
            [toRet addObject:[NSArray arrayWithObjects:@"O", file, nil]];
        }
        
        if([line hasPrefix:@"Would you like to replace the existing file"]) {
            // NSLog(@"Made it here!\n\n");
            NSString *file = [line substringFromIndex: 44];
            [toRet addObject:[NSArray arrayWithObjects:@"O", file, nil]];
        }

        if([line hasSuffix:@"- CRC failed"]) {
            NSString *file = [line substringToIndex:[line length]-13];
            [toRet addObject:[NSArray arrayWithObjects:@"CRC", file, nil]];
        }

        
        if([line hasPrefix:@"Checksum failed in the encrypted file"]) {
            NSString *file = [line substringWithRange:NSMakeRange(33, [line length]-33)];
            [toRet addObject:[NSArray arrayWithObjects:@"CRC", file, nil]];
        }

        
        if([line hasPrefix:@"CRC failed in the encrypted file"]) {
            NSString *file = [line substringWithRange:NSMakeRange(33, [line length]-33)];
            [toRet addObject:[NSArray arrayWithObjects:@"CRC", file, nil]];
        }
        
        if([line hasPrefix:@"Cannot find volume"]) {
            NSString *file = [line substringFromIndex:19];   
            [toRet addObject:[NSArray arrayWithObjects:@"FNF", file, nil]];
        }
        
        //NSLog(@"Made it here888!\nLine is %@\n\n", line);
        if([line hasPrefix:@"Enter password (will not be echoed) for"]) {
        //if([line hasSuffix:@":"]) {
            //NSLog(@"*** Finally made it here - REALLY!! ***\n\n");
            NSString *file = [line substringWithRange:NSMakeRange(40, [line length]-42)];
            [toRet addObject:[NSArray arrayWithObjects:@"PWD", file, nil]];            
        }
        
        NSLog(@"Made it here888!\nLine is %@\n\n", line);
        if([line hasPrefix:@"Enter new name"]) {
            //if([line hasSuffix:@":"]) {
            NSLog(@"*** Finally made it here - REALLY!! ***\n\n");
            NSString *file = [line substringWithRange:NSMakeRange(40, [line length]-42)];
            [toRet addObject:[NSArray arrayWithObjects:@"R", file, nil]];
        }
        
        
        if([line hasPrefix:@"No files to extract"]) {
            [toRet addObject:[NSArray arrayWithObjects:@"NFTE", nil]];  
        }
        
        if([line hasPrefix:@"All OK"]) {
            [toRet addObject:[NSArray arrayWithObjects:@"AO", nil]];  
        }
        
        if([line hasPrefix:@"Total errors: "]) {
            NSString *errors = [line substringFromIndex:14];
            [toRet addObject:[NSArray arrayWithObjects:@"TOT", errors, nil]];  
        }
    }
    
    NSLog(@"*** End of UnRARParsiing Util ***\n\n");
        
    return toRet;
}
@end
