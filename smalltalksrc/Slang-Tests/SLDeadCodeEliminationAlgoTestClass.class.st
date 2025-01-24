Class {
	#name : 'SLDeadCodeEliminationAlgoTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> isValidObjStackPage: objStackPage myIndex: myx [
	"Just check the page itself."

	<inline: false>
	| objStackInvalidBecause invalidObjStackPage ObjStackPageSlots ObjStackMyx marking |
	(self classIndexOf: objStackPage) = self wordSizeClassIndexPun
		ifFalse: [
			objStackInvalidBecause := 'wrong class index'.
			invalidObjStackPage := objStackPage.
			^ false ].
	(self formatOf: objStackPage) = self wordIndexableFormat ifFalse: [
		objStackInvalidBecause := 'wrong format'.
		invalidObjStackPage := objStackPage.
		^ false ].
	(self numSlotsOfAny: objStackPage) = ObjStackPageSlots ifFalse: [
		objStackInvalidBecause := 'wrong num slots'.
		invalidObjStackPage := objStackPage.
		^ false ].
	myx = (self fetchPointer: ObjStackMyx ofObject: objStackPage)
		ifFalse: [
			objStackInvalidBecause := 'wrong myx'.
			invalidObjStackPage := objStackPage.
			^ false ].
	(marking and: [ (self isMarked: objStackPage) not ]) ifTrue: [
		objStackInvalidBecause := 'marking but page is unmarked'.
		invalidObjStackPage := objStackPage.
		^ false ].
	^ true
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> methReturnInt [
	
	^ 5
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method [

	
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method: arg [
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> methodWithCCoerceInExpression [

	<var: #i type: #'char *'>
	| i |
	i := self methReturnInt.
	^ i
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTestClass >> methodWithEmptyCaseOfSendInReceiver [

	<returnTypeC: #void>
	self method caseOf: {
			([ 4 ] -> [ ^ 5 ]).
			([ 6 ] -> [  ]) }
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTestClass >> methodWithOnlyUselessAssignment [

	<returnTypeC: #void>
	| i j |
	i := 5.
	j := i
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessAssignment [

	| i j k l |
	k := 6.
	l := k + 1.
	i := 5.
	j := i.
	^ j
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> pop: nItems thenPushBool: boolean [

	<returnTypeC: #sqInt>
	| trueObj falseObj |
	self pop: nItems.
	self push: (boolean
			 ifTrue: [ trueObj ]
			 ifFalse: [ falseObj ])
]
