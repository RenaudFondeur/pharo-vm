Class {
	#name : #SlangStructureTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #helpers }
SlangStructureTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : #helpers }
SlangStructureTest >> getTMethodFrom: selector [

	"Generate a TMethod from a SlangBasicTranslationTestClass method."

	ccg addClass: SlangBasicTranslationTestClass.
	ccg inferTypes.
	^ ccg methodNamed: selector
]

{ #category : #running }
SlangStructureTest >> setUp [
	super setUp.
	ccg addStructClass: WKBytecodeElement.
	ccg addStructClass: WKBytecodeClass.
	ccg addStructClass: WKBytecodeMethod.
	ccg prepareMethods.
	ccg inferTypes.
]

{ #category : #'experiment-struct' }
SlangStructureTest >> testClassLiteralAt [
	| tMethod |
	tMethod := ccg methodNamed: #classLiteralAt:.
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : #'experiment-struct' }
SlangStructureTest >> testClassLiteralAtInliNing [
	| tMethod translation |
	tMethod := ccg methodNamed: #classLiteralAt:.
	self assert: tMethod isNotNil.
	
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: false.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* WKBytecodeElement>>#classLiteralAt: */
static sqInt
classLiteralAt(WKBytecodeElement * self_in_classLiteralAt, sqInt anInteger)
{
	return literals()[anInteger];
}'
]

{ #category : #'experiment-struct' }
SlangStructureTest >> testMethodLiteralAt [
	| tMethod |
	tMethod := ccg methodNamed: #methodLiteralAt:.
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : #'experiment-struct' }
SlangStructureTest >> testMethodLiteralAtInliNing [
	| tMethod translation methodList |
	tMethod := ccg methodNamed: #methodLiteralAt:.
	self assert: tMethod isNotNil.
	
	tMethod recordDeclarationsIn: ccg.
	
	methodList := ccg sortMethods: ccg methods.
	methodList do: [:m | ccg checkForGlobalUsage: (m removeUnusedTempsAndNilIfRequiredIn: ccg) in: m].
	ccg localizeGlobalVariables.
	ccg doBasicInlining: false.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* WKBytecodeMethod>>#methodLiteralAt: */
static sqInt
methodLiteralAt(WKBytecodeMethod * self_in_methodLiteralAt, sqInt anInteger)
{
	return classLiteralAt(bytecodeClass(), anInteger);
}'
]

{ #category : #helpers }
SlangStructureTest >> translate: tast [

	^ String streamContents: [ :str |
		  self astTranslate: tast inStream: str ]
]
