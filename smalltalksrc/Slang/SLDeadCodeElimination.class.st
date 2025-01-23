Class {
	#name : 'SLDeadCodeElimination',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator',
		'workList',
		'markedElements',
		'markedElementsAsExpression',
		'currentMethod'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'cleaning' }
SLDeadCodeElimination >> clean [

	currentMethod nodesDo: [ :n |
		((markedElements includes: n) or: [
			 markedElementsAsExpression includes: n ]) ifFalse: [
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

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> initMarkAndWorkList [

	currentMethod parseTree nodesDo: [ :node |
		node isSend ifTrue: [ self mayMarkSendNode: node ].

		node isAssignment ifTrue: [ self mayMarkAssignementNode: node ].

		node isReturn ifTrue: [
			self markAsStatementAndAddToWorkList: node.
			self markAsExpressionAndAddToWorkList: node expression ].

		node isGoTo ifTrue: [
			self markAsStatementAndAddToWorkList: node.
			self markAsStatement: node label ].

		node isLabel ifTrue: [ self markAsStatementAndAddToWorkList: node ] ]
]

{ #category : 'initialization' }
SLDeadCodeElimination >> initialize [

	markedElements := IdentitySet new: 300.
	markedElementsAsExpression := IdentitySet new: 300.
	workList := OrderedCollection new
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsExpression: aNode [

	markedElementsAsExpression add: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsExpressionAndAddToWorkList: aNode [

	(markedElementsAsExpression includes: aNode) ifFalse: [
		workList add: aNode ].
	self markAsExpression: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsStatement: aNode [

	markedElements add: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsStatementAndAddToWorkList: aNode [

	(markedElements includes: aNode) ifFalse: [
		workList add: aNode ].
	self markAsStatement: aNode
]

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> mayMarkAssignementNode: anAssignmentNode [

	| variable |
	variable := anAssignmentNode variable.
	(currentMethod locals includes: variable name) ifTrue: [ ^ self ].
	self visitAssignmentNode: anAssignmentNode
]

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> mayMarkSendNode: aSendNode [

	(aSendNode hasSideEffect not or: [
		 aSendNode isSelectorWithNoSideEffect ]) ifTrue: [ ^ self ].
	self visitSendNode: aSendNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> propagateMarkedElement: node [
	"if a node has been marked useful, mark its dependences and add them to the workList via a visitor pattern, behavior may change if we are marked as an expression or not "

	| parent |
	
	self visit: node.

	parent := node parent.
	(parent isNil or: [
		 parent isTMethod or: [
			 (markedElements includes: parent) or: [
				 markedElementsAsExpression includes: parent ] ] ]) ifFalse: [
		self markAsStatementAndAddToWorkList: parent ]
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeInCurrentMethod [

	| i |
	self initMarkAndWorkList.
	[ workList isEmpty ] whileFalse: [
		i := workList removeFirst.
		self propagateMarkedElement: i ].
	self clean.
	self initialize
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeUsing: aCodeGen [

	codeGenerator := aCodeGen.
	UIManager default
		displayProgress: 'dead code elimation'
		from: 0
		to: codeGenerator methods size
		during: [ :bar |
			codeGenerator methods doWithIndex: [ :m :i |
				bar value: i.
				currentMethod := m.
				codeGenerator currentMethod: m.
				self removeDeadCodeInCurrentMethod ] ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visit: aNode [

	aNode accept: self
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitAssignmentNode: anAssignmentNode [

	self markAsStatementAndAddToWorkList: anAssignmentNode.
	self markAsExpressionAndAddToWorkList: anAssignmentNode variable.
	self markAsExpressionAndAddToWorkList: anAssignmentNode expression
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitCaseStatementNode: aCaseStmtNode [

	self markAsStatement: aCaseStmtNode.
	self markAsExpressionAndAddToWorkList: aCaseStmtNode expression.

	aCaseStmtNode cases do: [ :case |
		self markAsExpressionAndAddToWorkList: case ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitConstantNode: aConstantNode [
	"nothing to do for an already marked constant"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitGoToNode: aTGotoNode [
	"nothing to do for an already marked TGotToNode"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitInlineNode: anInlineNode [

	self markAsStatement: anInlineNode.
	(markedElementsAsExpression includes: self) ifTrue: [
		self markAsExpressionAndAddToWorkList: anInlineNode method parseTree ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitLabeledCommentNode: aLabeledCommentNode [
	"nothing to do for an already marked label or comment"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitReturnNode: aReturnNode [
	"should't be called : return are handled in the first pass of the algorithm"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitSendNode: aSendNode [

	self markAsStatementAndAddToWorkList: aSendNode.
	self markAsExpressionAndAddToWorkList: aSendNode receiver.

	aSendNode arguments do: [ :arg |
		self markAsExpressionAndAddToWorkList: arg ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitStatementListNode: aStatementsListNode [
	"node statements are either marked from a children, for example [ 5.self method.true ] then we don't need to do anythings since the node and the useful branch(es) are already being marked.
	When it is marked from a parent (as expression), for example ^ [ 5.self method.true ] or ^ [ 5 ], in this case to keep the correct behavior, the last expression is kept."

	| statements |
	statements := aStatementsListNode statements.
	((markedElementsAsExpression includes: aStatementsListNode) and: [
		 aStatementsListNode isEmptyStmtListNode not ]) ifTrue: [
		self markAsExpressionAndAddToWorkList:
			aStatementsListNode lastNonCommentStatement ].
	statements do: [ :n | "keep the comments"
		n isComment ifTrue: [ self markAsStatement: n ] ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitSwitchStatementNode: aSwitchStatementNode [

	self markAsStatement: aSwitchStatementNode.
	self markAsExpressionAndAddToWorkList:
		aSwitchStatementNode expression.

	aSwitchStatementNode cases do: [ :c |
		| caseLabels caseStatements |
		caseLabels := c first.
		caseStatements := c second.
		caseLabels do: [ :label |
			self markAsExpressionAndAddToWorkList: label ].
		self markAsExpressionAndAddToWorkList: caseStatements ].

	aSwitchStatementNode otherwiseOrNil ifNotNil: [
		self markAsExpressionAndAddToWorkList:
			aSwitchStatementNode otherwiseOrNil ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitVariableNode: aVariableNode [

	currentMethod nodesDo: [ :n |
		(n isAssignment and: [ n variable isSameAs: aVariableNode ])
			ifTrue: [ self visitAssignmentNode: n ] ]
]
