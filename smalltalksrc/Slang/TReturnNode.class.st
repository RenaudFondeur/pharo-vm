Class {
	#name : 'TReturnNode',
	#superclass : 'TParseNode',
	#instVars : [
		'expression'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'generated' }
TReturnNode class >> expression: anExpression [

	^ self new
		expression: anExpression;
		yourself
]

{ #category : 'comparing' }
TReturnNode >> = aNode [

	super = aNode ifFalse: [ ^false ].
	aNode isReturn ifFalse: [ ^false ].
	expression = aNode expression ifFalse: [ ^ false ].
	^ true
]

{ #category : 'visiting' }
TReturnNode >> accept: aVisitor [
	
	^ aVisitor visitReturnNode: self
]

{ #category : 'tranforming' }
TReturnNode >> asCASTIn: aBuilder [

	| cast |
	(expression isSwitch or: [expression isCaseStmt]) ifTrue: [
		^ expression asCASTIn: aBuilder addToEndOfCases: self ].

	'void' = aBuilder currentMethod returnType ifTrue: [
		"If the function is void, don't say 'return x' instead say ' x; return' "
		| statements |
		statements := OrderedCollection new.
		expression isLeaf ifFalse: [
			statements add: (expression asCASTIn: aBuilder) ].
		statements add: CReturnStatementNode new.
		^ (CCompoundStatementNode statements: statements)
			needsBrackets: false "Slang compatibility";
			yourself ].
	
	cast := expression asCASTExpressionIn: aBuilder.
	
	"If the expression is a sequence, inject the return at the last element.
	It may be more clean to do that at the TAST level instead of the CAST level. I dunno."
	cast isCompoundStatement ifTrue: [
		cast last: (CReturnStatementNode expression: cast last).
		^ cast ].
		
	"Or else build a return"
	^ CReturnStatementNode expression: cast.
]

{ #category : 'transformations' }
TReturnNode >> asReturnNode [
	^self
]

{ #category : 'transformations' }
TReturnNode >> bindVariableUsesIn: aDictionary [

	self expression: (expression bindVariableUsesIn: aDictionary)
]

{ #category : 'transformations' }
TReturnNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound."
	| newExpression |
	newExpression := expression bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen.
	^newExpression = expression
		ifTrue: [self]
		ifFalse:
			[self shallowCopy
				setExpression: newExpression;
				yourself]
]

{ #category : 'transformations' }
TReturnNode >> bindVariablesIn: aDictionary [

	self expression: (expression bindVariablesIn: aDictionary)
]

{ #category : 'transformations' }
TReturnNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].	
	self expression: (expression bindVariablesIn: aDictionary unless: cautionaryBlock)
]

{ #category : 'accessing' }
TReturnNode >> children [

	^ { expression }
]

{ #category : 'transformations' }
TReturnNode >> copyWithoutReturn [
	"called when inlining happens, if the expression is in a cast, it may be no longer needed and will produce a warning by the C compiler if the expression isn't use as an expression anymore"

	(self isNotExpression and: [
		 expression isSend and: [ expression selector beginsWith: #cCoerce ] ])
		ifTrue: [ ^ expression arguments first ].
	^ expression
]

{ #category : 'testing' }
TReturnNode >> endsWithReturn [

	^true
]

{ #category : 'accessing' }
TReturnNode >> expression [

	^expression
]

{ #category : 'accessing' }
TReturnNode >> expression: anExpression [

	expression := anExpression.
	expression parent: self.
]

{ #category : 'testing' }
TReturnNode >> isReturn [

	^true
]

{ #category : 'comparing' }
TReturnNode >> isSameAs: aTParseNode [

	aTParseNode isReturn ifFalse: [ ^ false ].
	^ expression isSameAs: aTParseNode expression
]

{ #category : 'enumerating' }
TReturnNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock.
	aBlock value: self
]

{ #category : 'enumerating' }
TReturnNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock parent: self.
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TReturnNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	expression nodesDo: aBlock parent: self unless: cautionaryBlock.
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TReturnNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	expression nodesDo: aBlock unless: cautionaryBlock.
	aBlock value: self.
]

{ #category : 'copying' }
TReturnNode >> postCopy [

	self expression: expression copy
]

{ #category : 'C code generation' }
TReturnNode >> prependCASTIn: aBuilder expression: nodeExp [

	^ CReturnStatementNode expression:
		  (nodeExp asCASTExpressionIn: aBuilder)
]

{ #category : 'printing' }
TReturnNode >> printOn: aStream level: level [

	aStream nextPut: $^.
	expression printOn: aStream level: level.
]

{ #category : 'transformations' }
TReturnNode >> removeAssertions [
	expression removeAssertions
]

{ #category : 'transformations' }
TReturnNode >> replaceChild: aNode with: aReplacementNode [

	expression == aNode ifFalse: [ self error: 'Node is not a child of current node' ].
	self expression: aReplacementNode
]

{ #category : 'transformations' }
TReturnNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		self expression: (expression replaceNodesIn: aDictionary).
		self]
]

{ #category : 'accessing' }
TReturnNode >> setExpression: aNode [

	self expression: aNode
]

{ #category : 'type inference' }
TReturnNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	^expression typeOrNilFrom: aCodeGenerator in: aTMethod
]
