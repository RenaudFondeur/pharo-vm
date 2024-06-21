Class {
	#name : #SLFlexibleTypingTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #helpers }
SLFlexibleTypingTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : #running }
SLFlexibleTypingTest >> setUp [
	super setUp.
	ccg addClass: SLFlexibleTypingTestClass.
	ccg inferTypes.
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturn [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturn.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnAndConflict [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnAndConflict.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnAndConflictTranslation [
	"conflict so the return type default to sqInt"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnAndConflict.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self assert: translation equals: '/*	k introduce an error */
/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnAndConflict */
static sqInt
methodWithEarlyReturnAndConflict(void)
{
	sqInt i;
	char *j;
	int k;

	if (i == 5) {
		return NULL;
	}
	if (i == 6) {
		return NULL;
	}
	if (i == 7) {
		return NULL;
	}
	if (i == 8) {
		return k;
	}
	return j;
}'
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPositiveInteger [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPositiveInteger.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPositiveIntegerTranslation [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPositiveInteger.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/*	positive integers get a special traitment in Slang du to signed/unsigned 
	resolution, here they should be ignore anyways */
/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPositiveInteger */
static char *
methodWithEarlyReturnPositiveInteger(void)
{
	sqInt i;
	char *j;

	if (i == 5) {
		return NULL;
	}
	if (i == 6) {
		return NULL;
	}
	if (i == 7) {
		return NULL;
	}
	return j;
}'
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnTranslation [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturn.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLFlexibleTypingTestClass>>#methodWithEarlyReturn */
static char *
methodWithEarlyReturn(void)
{
	sqInt i;
	char *j;

	if (i == 5) {
		return NULL;
	}
	if (i == 6) {
		return NULL;
	}
	if (i == 7) {
		return NULL;
	}
	return j;
}'
]

{ #category : #helpers }
SLFlexibleTypingTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
