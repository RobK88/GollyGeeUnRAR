//
//  ExtractionWindowController.m
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

#import "ExtractionWindowController.h"


@implementation ExtractionWindowController
@synthesize progressbar;
@synthesize remainingTime;
@synthesize filename;
@synthesize cancelButton;
@synthesize overwriteSheet;
@synthesize yesButton;
@synthesize passwordSheet;
@synthesize overwriteFileName;
@synthesize errorSheet;
@synthesize currentPasswordSheet;
@synthesize errorText;
@synthesize passwordText;
@synthesize passwordField;
@synthesize passwordOKButton;
@synthesize errorCloseButton;
@synthesize ucpFilename;

@synthesize renameSheet;
@synthesize renameFileName;
@synthesize renameOKButton;




- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {

    }
    [NSApp activateIgnoringOtherApps:YES];
    return self;
}
//initWithWindowNibName:(N@"ExtractionWindow" withFile:file];
                       
                       
- (id)initWithWindowNibName:(NSString *)windowNibName withFile:(NSString *)file {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        NSLog(@"File: %@", file);
        NSLog(@"File URL: %@", [NSURL fileURLWithPath:file]);
        [self unrarFile:[NSURL fileURLWithPath:file]];
        [[NSDocumentController sharedDocumentController]
         noteNewRecentDocumentURL:[NSURL fileURLWithPath:file]];
        [self.window makeKeyAndOrderFront:self];
    }
    [NSApp activateIgnoringOtherApps:YES];
    return self;

}

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
    //[self.window orderOut:self];
        [NSApp activateIgnoringOtherApps:YES];
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.title = @"Select file to extract…";
        NSInteger ret = [panel runModal];
        NSLog(@"PANEL URLS: %@", panel.URLs);
        if(ret == NSFileHandlingPanelOKButton && [panel.URLs count] > 0) {
            [self.filename setStringValue:[[panel.URLs objectAtIndex:0] lastPathComponent]];
            [self unrarFile:[panel.URLs objectAtIndex:0]];
            [[NSDocumentController sharedDocumentController]
             noteNewRecentDocumentURL: [panel.URLs objectAtIndex:0]];
            [self.window makeKeyAndOrderFront:self];
        } else {
            NSLog(@"CLOSE WINDOW!");
            [self.window close];
            [self release];   //  Needed to close main extraction window!
            // [[NSApplication sharedApplication] terminate:nil]; // This will terminate the program
        }
    }
    
    return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [errorCloseButton setBezelStyle:NSRoundedBezelStyle];
    [errorSheet setDefaultButtonCell:[errorCloseButton cell]];
    
    [yesButton setBezelStyle:NSRoundedBezelStyle];
    [overwriteSheet setDefaultButtonCell:[yesButton cell]];
}

- (IBAction)cancelClicked:(id)sender {
    if([unrar isRunning]) [unrar terminate];
    [self.window close];
}

- (IBAction)closeClicked:(id)sender {
    [NSApp stopModal];
}

- (IBAction)passwordOKClicked:(id)sender {
    NSData *d = [[passwordField.stringValue stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];

    [NSApp stopModal];
}

- (IBAction)renameOKClicked:(id)sender {
    NSData *d = [[renameFileName.stringValue stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (IBAction)overwriteYes:(id)sender {
    NSData *d = [@"Y\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (IBAction)overwriteNo:(id)sender {
    NSData *d = [@"N\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (IBAction)overwriteAll:(id)sender {
    NSData *d = [@"A\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (IBAction)overwriteRename:(id)sender {
    NSData *d = [@"R\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (IBAction)overwriteCancel:(id)sender {
    NSData *d = [@"Q\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
    [self.window close];

}

- (IBAction)overwriteNever:(id)sender {
    NSData *d = [@"E\n" dataUsingEncoding:NSUTF8StringEncoding];
    [[inputPipe fileHandleForWriting] writeData:d];
    
    [NSApp stopModal];
}

- (void)unrarFile:(NSURL *)file {
    NSMutableArray *args = [NSMutableArray array];
    taskPipe = [NSPipe pipe];
    inputPipe = [NSPipe pipe];
    unrar = [[NSTask alloc] init];
    NSString *command = @"x";
    NSString *recurse = @"-r";
    NSString *keepBroken = @"-kb";
    //NSString *password = @"-p";
        
    /* set standard I/O, here to a NSPipe */
    [unrar setStandardOutput:taskPipe];
    // [unrar setStandardError: [unrar standardOutput]]; // Get standard error output too
    [unrar setStandardError:taskPipe];  // Get standard error output too
    [unrar setStandardInput:inputPipe];
    
    /* set arguments */
    [args addObject:command];
    
    if([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"Extract recursively"]])
    {
       [args addObject:recurse];
    }
    
    if([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"Keep broken files"]])
    {
        //NSLog(@"Keep Broken Extracted Files");
        [args addObject:keepBroken];
    }
    
    /* NSLog(@"Checking Password");
    if(![[passwordField stringValue] isEqualTo:@""])
    {
        //NSLog(@"Password is not null");
        password = [password stringByAppendingString:[passwordField stringValue]];
        //NSLog(@"Password is %@", password);
        [args addObject:password];
        [passwordField setStringValue:@""];
    }*/
    
    //NSLog(@"Path is %@", path);
    //NSLog(@"Location is %@", location);
    
    //[args addObject:@"-idc"];  // Suppress unrar copyright notice
    //[args addObject:@"-pchocolate"];  // Add password
    
    [args addObject:[file path]];
    
    //if ([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"Extract files to the same directory as the archive"]]) {
      //  [args addObject:[[file path] stringByDeletingLastPathComponent]];
    //} else 
    if ([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"Ask for download directory"]]) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        panel.title = @"Select extraction directory…";
        [panel setCanChooseDirectories:YES]; 
        [panel setCanChooseFiles:NO]; 
        NSInteger ret = [panel runModal];
        NSLog(@"PANEL URLS: %@", panel.URLs);
        if(ret == NSFileHandlingPanelOKButton && [panel.URLs count] > 0) {
            [args addObject:[[panel.URLs objectAtIndex:0] path]];
            [self.window makeKeyAndOrderFront:self];
        } else {
            [self.window close];
            return;
        }
    } else if ([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"Use custom extraction directory"]]) {
        [args addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Custom extraction directory"]];
    } else {
            [args addObject:[[file path] stringByDeletingLastPathComponent]];
    }
    
    //[args addObject:location];
    [unrar setArguments:args];
    
    /* set the path of the executable */
    [unrar setLaunchPath:[[NSBundle mainBundle] pathForResource:@"unrar" ofType:nil]];
    
    /* we want taskPipe to send notifications to be able to grab the output */
    [[taskPipe fileHandleForReading] readInBackgroundAndNotify];
        
    //[progressBar startAnimation:self];
    
   [unrar launch];
    
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printTaskOutput:) name:NSFileHandleReadCompletionNotification object:[[unrar standardOutput] fileHandleForReading]];
    
    //[unrar waitUntilExit];
}

- (void)printTaskOutput:(NSNotification *)unrarNotification
{
    // there is Data from the task output or error file to print in the Sheet Window
    
    NSString *outputString;
     
    NSData *data = [[unrarNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    
    if (data && [data length])
    {
        outputString = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"'%@'", outputString);
        
        NSArray *mparsed = [UnRARParsingUtils parseTerminal:outputString];
        NSLog(@"PARSED: %@", mparsed);
               
        for(NSArray *parsed in mparsed) {
            if(parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"P"]) {
                if(!lastPercentageUpdate) {
                    lastPercentageUpdate = [[NSDate date] retain];
                } else {
                    if(averageTimeBetweenPercentageUpdates == 0.0) averageTimeBetweenPercentageUpdates = [[NSDate date] timeIntervalSinceDate:lastPercentageUpdate]*2.0;
                    
                    averageTimeBetweenPercentageUpdates = ((averageTimeBetweenPercentageUpdates*[[parsed objectAtIndex:1] doubleValue])+([[NSDate date] timeIntervalSinceDate:lastPercentageUpdate]))/([[parsed objectAtIndex:1] doubleValue]+1);
             
                    NSTimeInterval secondsLeft = averageTimeBetweenPercentageUpdates*(100-([[parsed objectAtIndex:1] intValue]));

                    [lastPercentageUpdate release];
                    lastPercentageUpdate = [[NSDate date] retain];
                    
                    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:secondsLeft];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

                    NSDateComponents *components = [gregorian components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date] toDate:endDate options:0];

                    NSInteger hours = [components hour];
                    NSInteger minutes = [components minute];
                    NSInteger seconds = [components second];

                    remainingTime.stringValue = [NSString stringWithFormat:@"%02ld:%02ld:%02ld left", (long)hours, (long)minutes, (long)seconds, nil];
                    [gregorian release];
                    
                    [self.progressbar setDoubleValue:[[parsed objectAtIndex:1] doubleValue]];
                    self.window.title = [[[parsed objectAtIndex:1] stringValue] stringByAppendingString:@"% - GollyGeeUnRAR"];
                }
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"F"]){
                [self.filename setStringValue:[[parsed objectAtIndex:1] lastPathComponent]];
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"O"]){
                overwriteFileName.stringValue = [[[parsed objectAtIndex:1] lastPathComponent] stringByAppendingString:@" already exists. Overwrite it?"];
                [NSApp beginSheet:overwriteSheet
                   modalForWindow:self.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
                [NSApp runModalForWindow:overwriteSheet];
                [NSApp endSheet:overwriteSheet];
                [overwriteSheet orderOut:self];
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"UCP"]){
                ucpFilename.stringValue = [@"Use current password for " stringByAppendingString:[[[parsed objectAtIndex:1] lastPathComponent] stringByAppendingString:@"?"]];
                [NSApp beginSheet:currentPasswordSheet
                   modalForWindow:self.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
                [NSApp runModalForWindow:currentPasswordSheet];
                [NSApp endSheet:currentPasswordSheet];
                [currentPasswordSheet orderOut:self];
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"PWD"]){
                passwordText.stringValue = [@"Please enter the password for:\n" stringByAppendingString:[[parsed objectAtIndex:1] lastPathComponent]];
                [NSApp beginSheet:passwordSheet
                   modalForWindow:self.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
                [NSApp runModalForWindow:passwordSheet];
                [NSApp endSheet:passwordSheet];
                [passwordSheet orderOut:self];
            }   else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"R"]){
                //passwordText.stringValue = [@"Please enter the password for:\n" stringByAppendingString:[[parsed objectAtIndex:1] lastPathComponent]];
                [NSApp beginSheet:renameSheet
                   modalForWindow:self.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
                [NSApp runModalForWindow:renameSheet];
                [NSApp endSheet:renameSheet];
                [renameSheet orderOut:self];
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"TOT"]){
                //[progressbar setHidden:YES];
                [progressbar stopAnimation:self];
                progressbar.doubleValue = 100.0;
                
                remainingTime.stringValue = [[parsed objectAtIndex:1] stringByAppendingString:@" errors"];
                [cancelButton setBezelStyle:NSRoundedBezelStyle];
                [self.window setDefaultButtonCell:[cancelButton cell]];
                [cancelButton setTitle:@"Close"];
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"AO"]){
                [progressbar stopAnimation:self];
                progressbar.doubleValue = 100.0;
                self.window.title = @"100% - GollyGeeUnRAR";
                
                remainingTime.stringValue = @"All OK";
                [cancelButton setBezelStyle:NSRoundedBezelStyle];
                [self.window setDefaultButtonCell:[cancelButton cell]];
                [cancelButton setTitle:@"Done"];
                filename.stringValue = @"";
            } else if (parsed != nil && [[parsed objectAtIndex:0] isEqualToString:@"NFTE"]){
                remainingTime.stringValue = @"No files to extract - Wrong Password!";
                [cancelButton setBezelStyle:NSRoundedBezelStyle];
                [self.window setDefaultButtonCell:[cancelButton cell]];
                [cancelButton setTitle:@"Close"];
            } else if (parsed != nil) {
                if ([[parsed objectAtIndex:0] isEqualToString:@"CRC"]) {
                    errorText.stringValue = [@"CRC failed:\n" stringByAppendingString:[[parsed objectAtIndex:1] lastPathComponent]];
                }
                
                if ([[parsed objectAtIndex:0] isEqualToString:@"FNF"]) {
                    errorText.stringValue = [@"File not found:\n" stringByAppendingString:[parsed objectAtIndex:1]];
                }
                [NSApp beginSheet:errorSheet
                   modalForWindow:self.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
                [NSApp runModalForWindow:errorSheet];
                [NSApp endSheet:errorSheet];
                [errorSheet orderOut:self];
            } 
        }
        
        [[unrarNotification object] readInBackgroundAndNotify];
    }
}
@end
