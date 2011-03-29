//
//  GeeUnRARAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "ExtractionWindowController.h"

@interface GeeUnRARAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSMenuItem *brokenFiles;
    NSMenuItem *askForDirectory;
    NSMenuItem *sameDirectory;
    NSMenuItem *extractRecursively;
    NSMenuItem *extractTo;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenuItem *brokenFiles;
@property (assign) IBOutlet NSMenuItem *askForDirectory;
@property (assign) IBOutlet NSMenuItem *sameDirectory;
@property (assign) IBOutlet NSMenuItem *extractRecursively;
@property (assign) IBOutlet NSMenuItem *extractTo;
- (IBAction)openClicked:(id)sender;
- (IBAction)brokenFilesToggled:(id)sender;
- (IBAction)askForDirectoryToggled:(id)sender;
- (IBAction)sameDirectoryToggled:(id)sender;
- (IBAction)extractRecursivelyToggled:(id)sender;
- (IBAction)extractToToggled:(id)sender;

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;

+ (void)setStateOnUserDefaults:(NSInteger)state forKey:(id)key;
+ (void)setToggledStateOnUserDefaults:(NSInteger)state forKey:(id)key;
+ (void)setStateOnCheckBox:(id)checkBox forKey:(id)key;
+ (void)toggleCheckBox:(id)checkBox;
@end
