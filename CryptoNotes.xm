#import <UIKit/UIKit.h>
#import "NSString+AESCrypt.h"

@interface NoteContentLayer : UIView
@property(assign, nonatomic) BOOL containsCJK;
@property(readonly, assign) UITextView* textView;
-(id) contentAsPlainText:(BOOL)text;
-(void) setContent:(id)content isPlainText:(BOOL)text isCJK:(BOOL)cjk;
-(void) textViewDidChange:(id)textView;
@end

@interface NotesDisplayController : UINavigationController <UIAlertViewDelegate, UIActionSheetDelegate>
-(void) saveNote;
-(void) createNote;
-(void) setContentFromNote;
-(void) noteContentLayerContentDidChange:(id)noteContentLayerContent updatedTitle:(BOOL)title;
-(void) noteContentLayerContentDidChange:(id)noteContentLayerContent;
-(void) cryptoNote;
-(void) encrypt;
-(void) decrypt;
-(void) updateNote:(id)n;
-(void) updateNoteTitle;
@property(strong, nonatomic) id note;
@end

%hook NotesDisplayController

-(void) loadView {
	%orig;
	NSMutableArray *rightNavItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
	UIButton *cryptoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cryptoButton setTitle:@"Crypto" forState:UIControlStateNormal];
	[cryptoButton addTarget:self action:@selector(cryptoNote) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.titleView = cryptoButton;
}

%new

-(void) cryptoNote {
	UIAlertController *view = [UIAlertController alertControllerWithTitle:@"CryptoNotes" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *en = [UIAlertAction actionWithTitle:@"Encrypt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[view dismissViewControllerAnimated:1 completion:nil];
		[self encrypt];
	}];
	UIAlertAction *de = [UIAlertAction actionWithTitle:@"Decrypt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[view dismissViewControllerAnimated:1 completion:nil];
		[self decrypt];
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[view dismissViewControllerAnimated:1 completion:nil];
	}];
	[view addAction:en];
	[view addAction:de];
	[view addAction:cancel];
	view.popoverPresentationController.sourceView = self.view;
	view.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 100, 100);
	[self presentViewController:view animated:1 completion:nil];
}

%new

-(void) encrypt {
	UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Encrypt" message:nil preferredStyle:UIAlertControllerStyleAlert];
	__weak UIAlertController *ref = view;
	UIAlertAction *en = [UIAlertAction actionWithTitle:@"Encrypt" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSString *pass = ((UITextField *)[ref.textFields objectAtIndex:0]).text;
		NoteContentLayer *contentLayer = MSHookIvar<NoteContentLayer*>(self, "_contentLayer");
		NSString *msg = [contentLayer contentAsPlainText:1];
		NSString *cryptoMsg = [msg AES256EncryptWithKey:pass];
		[contentLayer setContent:cryptoMsg isPlainText:1 isCJK:contentLayer.containsCJK];
		[self noteContentLayerContentDidChange:contentLayer updatedTitle:1];
		[self updateNote:self.note];
		[self updateNoteTitle];
		[self saveNote];
		[view dismissViewControllerAnimated:1 completion:nil];
	}];
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[view dismissViewControllerAnimated:1 completion:nil];
	}];
	[view addAction:en];
	[view addAction:cancel];
	[view addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"passphrase";
	}];
	[self presentViewController:view animated:1 completion:nil];
}

%new

-(void) decrypt {
	UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Decrypt" message:nil preferredStyle:UIAlertControllerStyleAlert];
	__weak UIAlertController *ref = view;
	UIAlertAction *en = [UIAlertAction actionWithTitle:@"Decrypt" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSString *pass = ((UITextField *)[ref.textFields objectAtIndex:0]).text;
		NoteContentLayer *contentLayer = MSHookIvar<NoteContentLayer*>(self, "_contentLayer");
		NSString *msg = [contentLayer contentAsPlainText:1];
		NSString *cryptoMsg = [msg AES256DecryptWithKey:pass];
		[contentLayer setContent:cryptoMsg isPlainText:1 isCJK:contentLayer.containsCJK];
		[self noteContentLayerContentDidChange:contentLayer updatedTitle:1];
		[self updateNote:self.note];
		[self updateNoteTitle];
		[self saveNote];
		[view dismissViewControllerAnimated:1 completion:nil];
	}];
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[view dismissViewControllerAnimated:1 completion:nil];
	}];
	[view addAction:en];
	[view addAction:cancel];
	[view addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"passphrase";
	}];
	[self presentViewController:view animated:1 completion:nil];
}

%end