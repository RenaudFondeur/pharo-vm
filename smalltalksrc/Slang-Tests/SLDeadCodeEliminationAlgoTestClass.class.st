Class {
	#name : 'SLDeadCodeEliminationAlgoTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method [

	
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method: arg [
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
