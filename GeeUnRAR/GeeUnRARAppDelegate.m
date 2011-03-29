//
//  GeeUnRARAppDelegate.m
//  GeeUnRAR
//
//  Created by Giuliano A. Montecarlo on 3/27/11.
//  Copyright 2011 Giuliano A. Montecarlo. All rights reserved.
//
//  GeeUnRAR - Mac OS X GUI for unrar
//  Copyright (C) 2011  Giuliano A. Montecarlo
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



#import "GeeUnRARAppDelegate.h"

@implementation GeeUnRARAppDelegate

@synthesize window;
@synthesize brokenFiles;
@synthesize askForDirectory;
@synthesize sameDirectory;
@synthesize extractRecursively;
@synthesize extractTo;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*[self.window close];
    ExtractionWindowController * test = [[ExtractionWindowController alloc] 
                                               initWithWindowNibName:@"ExtractionWindow"];
    [test showWindow:self];
     */    
    
    [GeeUnRARAppDelegate setStateOnCheckBox:brokenFiles forKey:@"Keep broken files"];
    [GeeUnRARAppDelegate setStateOnCheckBox:extractRecursively forKey:@"Extract recursively"];
    [GeeUnRARAppDelegate setStateOnCheckBox:askForDirectory forKey:@"Ask for download directory"];
    [GeeUnRARAppDelegate setStateOnCheckBox:sameDirectory forKey:@"Extract files to the same directory as the archive"];
    [GeeUnRARAppDelegate setStateOnCheckBox:extractTo forKey:@"Use custom extraction directory"];
    [extractTo setTitle:[@"Extract to: " stringByAppendingString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Custom extraction directory"] lastPathComponent]]];
}

- (IBAction)openClicked:(id)sender {
    ExtractionWindowController *test = [[ExtractionWindowController alloc] 
                                         initWithWindowNibName:@"ExtractionWindow"];
    [test showWindow:self];
   // [test autorelease];
}


- (IBAction)brokenFilesToggled:(id)sender {
    [GeeUnRARAppDelegate toggleCheckBox:sender];
    [GeeUnRARAppDelegate setStateOnUserDefaults:[sender state] forKey:@"Keep broken files"];
}

- (IBAction)askForDirectoryToggled:(id)sender {
    if([sender state] == NSOnState) return;
    [GeeUnRARAppDelegate toggleCheckBox:sender];
    [GeeUnRARAppDelegate setStateOnUserDefaults:[sender state] forKey:@"Ask for download directory"];
    [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Extract files to the same directory as the archive"];
    [GeeUnRARAppDelegate setStateOnCheckBox:sameDirectory forKey:@"Extract files to the same directory as the archive"];
    [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Use custom extraction directory"];
    [GeeUnRARAppDelegate setStateOnCheckBox:extractTo forKey:@"Use custom extraction directory"];
}

- (IBAction)sameDirectoryToggled:(id)sender {
    if([sender state] == NSOnState) return;
    [GeeUnRARAppDelegate toggleCheckBox:sender];
    [GeeUnRARAppDelegate setStateOnUserDefaults:[sender state] forKey:@"Extract files to the same directory as the archive"];
    [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Ask for download directory"];
    [GeeUnRARAppDelegate setStateOnCheckBox:askForDirectory forKey:@"Ask for download directory"];
    
    [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Use custom extraction directory"];
    [GeeUnRARAppDelegate setStateOnCheckBox:extractTo forKey:@"Use custom extraction directory"];
}

- (IBAction)extractRecursivelyToggled:(id)sender {
    [GeeUnRARAppDelegate toggleCheckBox:sender];
    [GeeUnRARAppDelegate setStateOnUserDefaults:[sender state] forKey:@"Extract recursively"];
}

- (IBAction)extractToToggled:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.title = @"Select extraction directory…";
    [panel setCanChooseDirectories:YES]; 
    [panel setCanChooseFiles:NO]; 
    NSInteger ret = [panel runModal];
    NSLog(@"PANEL URLS: %@", panel.URLs);
    if(ret == NSFileHandlingPanelOKButton && [panel.URLs count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[[panel.URLs objectAtIndex:0] path] forKey:@"Custom extraction directory"];
        [GeeUnRARAppDelegate toggleCheckBox:sender];
        [GeeUnRARAppDelegate setStateOnUserDefaults:[sender state] forKey:@"Use custom extraction directory"];
        
        
        
        [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Ask for download directory"];
        [GeeUnRARAppDelegate setStateOnCheckBox:askForDirectory forKey:@"Ask for download directory"];
        [GeeUnRARAppDelegate setToggledStateOnUserDefaults:[sender state] forKey:@"Extract files to the same directory as the archive"];
        [GeeUnRARAppDelegate setStateOnCheckBox:sameDirectory forKey:@"Extract files to the same directory as the archive"];
        [self.window makeKeyAndOrderFront:self];
        
        [sender setTitle:[@"Extract to: " stringByAppendingString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Custom extraction directory"] lastPathComponent]]];
    }
}


- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    ExtractionWindowController *test = [[ExtractionWindowController alloc] 
                                         initWithWindowNibName:@"ExtractionWindow" withFile:filename];
    [test showWindow:self];
   // [test autorelease];
    NSLog(@"Open File: %@", filename);
    return YES;

}

- (IBAction)chooseDirectoryClicked:(id)sender {
}

+ (void)setStateOnUserDefaults:(NSInteger)state forKey:(id)key {
    if (state == NSOnState) {
        [[NSUserDefaults standardUserDefaults]
         setObject:@"YES" forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults]
         setObject:@"NO" forKey:key];
    }
}

+ (void)setToggledStateOnUserDefaults:(NSInteger)state forKey:(id)key {
    if (state == NSOffState) {
        [[NSUserDefaults standardUserDefaults]
         setObject:@"YES" forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults]
         setObject:@"NO" forKey:key];
    }
}

+ (void)setStateOnCheckBox:(id)checkBox forKey:(id)key {
    if ([@"YES" isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:key]]) {
        [checkBox setState:NSOnState];
    } else {
        [checkBox setState:NSOffState];
    }
}

+ (void)toggleCheckBox:(id)checkBox {
    if ([checkBox state] == NSOnState) {
        [checkBox setState:NSOffState];
    } else {
        [checkBox setState:NSOnState];
    }
}

@end
