#import "DTXcodeUtils.h"

#import "DTXcodeHeaders.h"

@implementation DTXcodeUtils


+ (IDEWorkspaceWindowController *)workspaceWindowControllerForController:(id)controller {
    if ([controller isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return (IDEWorkspaceWindowController *)controller;
    } else {
        return nil;
    }
}


+ (IDESourceCodeDocument *)sourceCodeDocumentForEditor:(id)editor {
    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return ((IDESourceCodeEditor *)editor).sourceCodeDocument;
    } else if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDEEditorDocument *document =
        ((IDESourceCodeComparisonEditor *)editor).primaryDocument;
        if ([document isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            return (IDESourceCodeDocument *)document;
        }
    }
    return nil;
}


+ (NSArray *)sourceCodeDocuments {
    NSMutableArray *docs = [@[] mutableCopy];
    for (IDEEditor *editor in [self ideEditors]) {
        IDESourceCodeDocument *doc = [self sourceCodeDocumentForEditor:editor];
        if (doc != nil) {
            [docs addObject:doc];
        }
    }
    return docs;
}


+ (NSArray *)ideEditors {
    NSMutableArray *editors = [@[] mutableCopy];
    for (NSWindow *w in [NSApplication sharedApplication].windows) {
        IDEWorkspaceWindowController *wsController = [self workspaceWindowControllerForController:w.windowController];
        if (wsController != nil) {
            IDEEditorArea *area = wsController.editorArea;
            IDEEditorContext *context = area.lastActiveEditorContext;
            IDEEditor *editor = context.editor;
            [editors addObject:editor];
        }
    }
    return editors;
}


+ (NSWindow *)currentWindow {
  return [[NSApplication sharedApplication] keyWindow];
}

+ (NSResponder *)currentWindowResponder {
  return [[self currentWindow] firstResponder];
}

+ (NSMenu *)mainMenu {
  return [NSApp mainMenu];
}

+ (NSMenuItem *)getMainMenuItemWithTitle:(NSString *)title {
  return [[self mainMenu] itemWithTitle:title];
}

+ (IDEWorkspaceWindowController *)currentWorkspaceWindowController {
    return [self workspaceWindowControllerForController:[self currentWindow].windowController];
}

+ (IDEEditorArea *)currentEditorArea {
  return [self currentWorkspaceWindowController].editorArea;
}

+ (IDEEditorContext *)currentEditorContext {
  return [self currentEditorArea].lastActiveEditorContext;
}

+ (IDEEditor *)currentEditor {
  return [self currentEditorContext].editor;
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument {
    return [self sourceCodeDocumentForEditor:[self currentEditor]];
}

+ (DVTSourceTextView *)currentSourceTextView {
    return [self sourceTextViewForEditor:[self currentEditor]];
}

+ (DVTSourceTextView *)sourceTextViewForEditor:(id)editor {
    if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return ((IDESourceCodeEditor *)editor).textView;
    } else if ([[self currentEditor] isKindOfClass:
                NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        return ((IDESourceCodeComparisonEditor *)editor).keyTextView;
    } else if ([editor isKindOfClass:NSClassFromString(@"IDEPlaygroundEditor")]) {
        return ((IDEPlaygroundEditor *)editor).textView;
    }
    return nil;
}

+ (DVTTextStorage *)currentTextStorage {
  NSTextView *textView = [self currentSourceTextView];
  if ([textView.textStorage isKindOfClass:NSClassFromString(@"DVTTextStorage")]) {
    return (DVTTextStorage *)textView.textStorage;
  }
  return nil;
}

+ (DVTTextStorage *)textStorageForEditor:(id)editor {
    NSTextView *textView = [self sourceTextViewForEditor:editor];
    if ([textView.textStorage isKindOfClass:NSClassFromString(@"DVTTextStorage")]) {
        return (DVTTextStorage *)textView.textStorage;
    }
    return nil;
}

+ (NSScrollView *)currentScrollView {
  NSView *view = [self currentSourceTextView];
  return [view enclosingScrollView];
}

@end
