#import <AppKit/AppKit.h>

@class DVTSourceTextView;
@class DVTTextStorage;
@class IDEEditor;
@class IDEEditorArea;
@class IDESourceCodeDocument;
@class IDEEditorContext;
@class IDEWorkspaceWindowController;

@interface DTXcodeUtils : NSObject
+ (NSWindow *)currentWindow;
+ (NSResponder *)currentWindowResponder;
+ (NSMenu *)mainMenu;
+ (IDEWorkspaceWindowController *)currentWorkspaceWindowController;
+ (IDEEditorArea *)currentEditorArea;
+ (IDEEditorContext *)currentEditorContext;
+ (IDEEditor *)currentEditor;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;
+ (DVTSourceTextView *)currentSourceTextView;
+ (DVTTextStorage *)currentTextStorage;
+ (NSScrollView *)currentScrollView;

+ (NSMenuItem *)getMainMenuItemWithTitle:(NSString *)title;

+ (IDEWorkspaceWindowController *)workspaceWindowControllerForController:(id)controller;
+ (IDESourceCodeDocument *)sourceCodeDocumentForEditor:(id)editor;
+ (NSArray *)sourceCodeDocuments;
+ (DVTSourceTextView *)sourceTextViewForEditor:(id)editor;
+ (NSArray *)ideEditors;
+ (DVTTextStorage *)textStorageForEditor:(id)editor;

@end
