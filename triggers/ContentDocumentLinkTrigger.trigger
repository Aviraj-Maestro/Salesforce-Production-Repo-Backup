trigger ContentDocumentLinkTrigger on ContentDocumentLink (After insert) {
	ContentDocumentLinkHandler.contentDocumentLinkHandlerAfterInsert(trigger.new);
}