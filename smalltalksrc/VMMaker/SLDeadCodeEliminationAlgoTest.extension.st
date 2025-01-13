Extension { #name : 'SLDeadCodeEliminationAlgoTest' }

{ #category : '*VMMaker' }
SLDeadCodeEliminationAlgoTest >> setUp [

	super setUp.
	ccg addClass: SLDeadCodeEliminationAlgoTestClass.
	ccg inferTypes.
	sLDeadCodeElimination := SLDeadCodeElimination new codeGenerator: ccg
]
