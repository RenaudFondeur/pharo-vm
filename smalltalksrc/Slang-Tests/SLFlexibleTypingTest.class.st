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
SLFlexibleTypingTest >> testMethodWithEarlyReturnEarlyReturnPtrAndNil [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNil.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPositiveIntegerTranslation [
	"maybe useless, produce a conflict"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNilPositiveInteger.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/*	positive integers get a special traitment in Slang du to signed/unsigned 
	resolution, here they should be ignore anyways */
/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPtrAndNilPositiveInteger */
static sqInt
methodWithEarlyReturnPtrAndNilPositiveInteger(void)
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
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndIntTranslation [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndInt.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPtrAndInt */
static sqInt
methodWithEarlyReturnPtrAndInt(void)
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

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndNilConflict [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNilConflict.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndNilConflictTranslation [
	"conflict so the return type default to sqInt"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNilConflict.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self assert: translation equals: '/*	k introduce a conflict */
/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPtrAndNilConflict */
static sqInt
methodWithEarlyReturnPtrAndNilConflict(void)
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
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndNilPositiveInteger [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNilPositiveInteger.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndNilPositiveIntegerConflict [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNilPositiveIntegerConflict.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : #'translation-ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndNilTranslation [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndNil.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPtrAndNil */
static char *
methodWithEarlyReturnPtrAndNil(void)
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
SLFlexibleTypingTest >> testMethodWithEarlyReturnPtrAndSelfTranslation [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnPtrAndSelf.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLFlexibleTypingTestClass>>#methodWithEarlyReturnPtrAndSelf */
static sqInt
methodWithEarlyReturnPtrAndSelf(void)
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
