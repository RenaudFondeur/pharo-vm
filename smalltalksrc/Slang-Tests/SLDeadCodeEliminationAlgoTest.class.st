Class {
	#name : 'SLDeadCodeEliminationAlgoTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLDeadCodeElimination'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTest >> testMethodWithEmptyCaseOfSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyCaseOfSendInReceiver.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithEmptyCaseOfSendInReceiver */
static void
methodWithEmptyCaseOfSendInReceiver(void)
{
	switch (method()) {
		case 4:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testMethodWithOnlyUselessAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyUselessAssignment.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithOnlyUselessAssignment */
static void
methodWithOnlyUselessAssignment(void)
{
}'
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(sqInt anInt)
{
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessAssignment.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessAssignment */
static sqInt
methodWithUselessAssignment(void)
{
	int i;
	sqInt j;

	i = 5;
	j = i;
	return j;
}'
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTest >> translate: tast [

	^ String streamContents: [ :str |
		  self astTranslate: tast inStream: str ]
]
