Class {
	#name : 'SLDeadCodeElimination',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator',
		'workList',
		'markedElements',
		'currentMethod'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'cleaning' }
SLDeadCodeElimination >> clean [

	currentMethod nodesDo: [ :n |
		(markedElements anySatisfy: [ :e | n = e ]) ifFalse: [
			n parent ifNotNil: [ :parent | parent removeUnusedNodesInBranch: n ] ] ]
]

{ #category : 'accessing' }
SLDeadCodeElimination >> codeGenerator [

	^ codeGenerator
]

{ #category : 'accessing' }
SLDeadCodeElimination >> codeGenerator: aCodeGen [

	codeGenerator := aCodeGen
]

{ #category : 'accessing' }
SLDeadCodeElimination >> currentMethod [

	^ currentMethod
]

{ #category : 'accessing' }
SLDeadCodeElimination >> currentMethod: aTMethod [

	currentMethod := aTMethod
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> initMarkAndWorkList [

	currentMethod parseTree nodesDo: [ :node |
		node isSend ifTrue: [ self mayMarkSendNode: node ].
		node isAssignment ifTrue: [ self mayMarkAssignementNode: node ].
		node isReturn ifTrue: [
			self markAndAddToWorkList: node.
			self markAndAddToWorkList: node expression ] ]
]

{ #category : 'initialization' }
SLDeadCodeElimination >> initialize [

	markedElements := Set new.
	workList := OrderedCollection new
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAndAddToWorkList: aNode [

	markedElements add: aNode.
	workList add: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAssignmentNode: anAssignmentNode [
	"mark the node and expresssion, assume the lvalue is already marked"

	(markedElements includes: anAssignmentNode) ifTrue: [ ^ self ].
	self markAndAddToWorkList: anAssignmentNode.
	self markAndAddToWorkList: anAssignmentNode expression
]

{ #category : 'mark' }
SLDeadCodeElimination >> markSendNode: aSendNode [

	markedElements add: aSendNode.
	self markAndAddToWorkList: aSendNode receiver.

	aSendNode arguments do: [ :arg | self markAndAddToWorkList: arg ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> markSwitchStatementNode: aSwitchStatementNode [

	markedElements add: aSwitchStatementNode
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> mayMarkAssignementNode: anAssignmentNode [

	| variable |
	variable := anAssignmentNode variable.
	(currentMethod locals includes: variable name) ifTrue: [ ^ self ].
	self markAndAddToWorkList: variable.
	self markAssignmentNode: anAssignmentNode
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> mayMarkSendNode: aSendNode [

	(aSendNode hasSideEffect not or: [
		 aSendNode isSelectorWithNoSideEffect ]) ifTrue: [ ^ self ].
	self markSendNode: aSendNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> propagateMarkedElement: node [
	"if a node has been marked useful, mark its children and parent and add them to the workList "

	| parent |
	node isSend ifTrue: [ self markSendNode: node ].

	node isVariable ifTrue: [
		currentMethod nodesDo: [ :n |
			(n isAssignment and: [ n variable isSameAs: node ]) ifTrue: [
				self markAssignmentNode: n ] ] ].

	node isSwitch ifTrue: [ self markSwitchStatementNode: node ].

	parent := node parent.
	((markedElements includes: parent) or: [parent isTMethod or: [ parent isNil ]]) ifFalse: [
		self markAndAddToWorkList: parent ]
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeInCurrentMethod [

	| i |
	self initMarkAndWorkList.
	[ workList isEmpty ] whileFalse: [
		i := workList at: 1.
		workList remove: i.
		self propagateMarkedElement: i ].
	self clean.
	currentMethod := nil.
	markedElements := Set new.
	workList := OrderedCollection new
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeUsing: aCodeGen [

	codeGenerator := aCodeGen.
	codeGenerator methods do: [ :m |
		currentMethod := m.
		codeGenerator currentMethod: m.
		self removeDeadCodeInCurrentMethod ]
]
