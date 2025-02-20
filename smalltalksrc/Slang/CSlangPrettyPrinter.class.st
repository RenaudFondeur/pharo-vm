Class {
	#name : 'CSlangPrettyPrinter',
	#superclass : 'CAbstractNodeVisitor',
	#instVars : [
		'stream',
		'level'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'accessing' }
CSlangPrettyPrinter >> contents [
	
	^ stream contents
]

{ #category : 'testing' }
CSlangPrettyPrinter >> expressionListHasNonCommentStatementAfter: expressions futureIndex: startingIndex [
	"Find a begin inlining comment in an expressionList starting at futureIndex.
	Sometimes the last statements of an expression list are a sequence of comments.
	We iterate the next elements to see if there is an actual statement after otherwise the next part is not an element of the list"

	startingIndex to: expressions size do: [ :e |
		| current |
		current := expressions at: e.
		(current isComment not and: [ current isEmpty not ]) ifTrue: [
			^ true ] ].

	^ false
]

{ #category : 'testing' }
CSlangPrettyPrinter >> expressionListNeedAComma: expressions current: e futureIndex: futureIndex commentSeries: commentSeries [
	"handle space, comma and comment in visitExpressionList, comments only comes from inlining in an expressionList. ensure comments are not considered as element of the list and are linked to theirs respective methods. if the list contains an empty inlined method we can have a potential series of comments  that shouldn't be considered as element, hence the boolean commentSeries. Return if a comma is needed and if the comment series continue/start.
	"

	| next currentRequiredEndSeparator futureRequireBeginningSeparator continueCommentSeries currentIsEndComment nextIsBeginComment |
	futureIndex > expressions size ifTrue: [ ^ { false. false } ].
	next := expressions at: futureIndex.

	currentIsEndComment := e isComment and: [
		                       e comment beginsWith: #' end' ].
	nextIsBeginComment := next isComment and: [
		                      next comment beginsWith: #' begin' ].

	(currentIsEndComment and: [
		 nextIsBeginComment and: [ commentSeries ] ]) ifTrue: [
		^ { false. true } ].

	continueCommentSeries := (commentSeries and: [
		                          e isComment and: [ next isComment ] ])
		                         or: [ nextIsBeginComment ].
	currentRequiredEndSeparator := e isEmpty not and: [
		                               e isComment not or: [
			                               currentIsEndComment ] ].
	futureRequireBeginningSeparator := next isEmpty not and: [
		                                   next isComment not or: [
			                                   nextIsBeginComment and: [
				                                   self
					                                   expressionListHasNonCommentStatementAfter:
					                                   expressions
					                                   futureIndex: futureIndex ] ] ].

	^ {
		  (currentRequiredEndSeparator and: [
			   futureRequireBeginningSeparator ]).
		  continueCommentSeries }
]

{ #category : 'initialization' }
CSlangPrettyPrinter >> initialize [

	super initialize.
	stream := '' writeStream.
	level := 0
]

{ #category : 'visiting' }
CSlangPrettyPrinter >> printComments: aListOfComments [

	aListOfComments do: [ :e |
		stream
			nextPutAll: '/* ';
			nextPutAll: e;
			nextPutAll: ' */'.
	] separatedBy: [ stream cr ].
]

{ #category : 'generated' }
CSlangPrettyPrinter >> printExpression: cAST [

	(cAST isLeaf
		"Cast expressions already contain their own parentheses"
		or: [ cAST isCastExpression 
			"An unary expression that has a leaf expression dosen't need parentheses aroud expression"
			or: [cAST isUnaryOperation and: [cAST expression isLeaf or: [ cAST needsParentheses]]]])
		ifTrue: [ cAST acceptVisitor: self ]
		ifFalse: [ 
			stream nextPut: $(.
			cAST acceptVisitor: self.
			stream nextPut: $) ]
	
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitArray: anArrayAcess [

	anArrayAcess array acceptVisitor: self.
	stream nextPut: $[.
	anArrayAcess index acceptVisitor: self.
	stream nextPut: $]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitArrayDeclarator: anArrayDeclarator [

	anArrayDeclarator declarator acceptVisitor: self.
	stream nextPut: $[.
	anArrayDeclarator size ifNotNil: [ :size |
		stream nextPutAll: size asString ].
	stream nextPut: $]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitArrow: aPointerAccess [

	aPointerAccess needsParentheses ifTrue:  [ stream nextPut: $(].
	self printExpression: aPointerAccess structurePointer.
	stream nextPutAll: '->'.
	aPointerAccess member acceptVisitor: self.
	aPointerAccess needsParentheses ifTrue:  [ stream nextPut: $)].
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitAssignment: anAssignment [

	anAssignment needsParentheses ifTrue: [ stream nextPut: $( ].
	anAssignment lvalue acceptVisitor: self.
	stream
		nextPutAll: ' ';
		nextPutAll: anAssignment operator;
		nextPutAll: ' '.
	anAssignment rvalue acceptVisitor: self.
	anAssignment needsParentheses ifTrue: [ stream nextPut: $) ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitBinary: aBinary [
	
	aBinary needsParentheses ifTrue: [ stream nextPut: $( ].
	self printExpression: aBinary left.
	
	stream
		nextPutAll: ' ';
		nextPutAll: aBinary operator;
		nextPutAll: ' '.
		
	self printExpression: aBinary right.
	aBinary needsParentheses ifTrue: [ stream nextPut: $) ].
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitBreakStatement: aBreakStatement [

	stream nextPutAll: 'break'
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitCall: aCall [
	
	aCall identifier isIdentifier ifFalse: [ stream nextPut: $( ].
	aCall identifier acceptVisitor: self.
	aCall identifier isIdentifier ifFalse: [ stream nextPut: $) ].
	stream nextPutAll: '('.
	aCall arguments do: [ :arg | arg acceptVisitor: self ] separatedBy: [ stream nextPutAll: ', '].
	stream nextPutAll: ')'.
		
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitCastExpression: aCastExpression [

	| nbParentheses |
	nbParentheses := aCastExpression needsParentheses ifTrue: [ 2 ] ifFalse: [ 1 ].
	"Wrap everything between parentheses to avoid ambiguities"
	stream next: nbParentheses put: $(.
	
	"Print the type between parentheses"
	stream nextPut: $(.
	aCastExpression type acceptVisitor: self.
	stream nextPutAll: ') '.
	
	"Print the expression to cast"
	self printExpression: aCastExpression expression.
	stream space.
	stream next: nbParentheses put: $)
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitComment: aComment [

	stream nextPutAll: '/*'.
	stream nextPutAll: aComment comment.
	stream nextPutAll: '*/'
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitCompoundStatement: aCompoundStatement [

	| first |
	first := true.
	aCompoundStatement needsBrackets ifTrue: [ 
		"If we print brackets, then the first was already printed"
		first := false.
		stream nextPutAll: '{'.
		stream cr.
		level := level + 1 ].

	aCompoundStatement declarations do: [ :e |
		first
			ifTrue: [ first := false. ]
			ifFalse: [ stream tab: level ].
			e acceptVisitor: self.
			e needsSeparator ifTrue: [ stream nextPut: $; ].
			stream cr. ].
	
	"Put at least one empty line to separate declarations and statements.
	This is required for the current GNUisation to work, which searches for empty lines"
	aCompoundStatement declarations ifNotEmpty: [
		stream cr.
	].

	aCompoundStatement statements do: [ :e |
		first
			ifTrue: [ first := false. ]
			ifFalse: [ stream tab: level ].
			e acceptVisitor: self.
			e needsSeparator ifTrue: [ stream nextPut: $; ]]
		separatedBy: [ stream cr ].

	aCompoundStatement needsBrackets ifTrue: [ 
		level := level - 1.
		(aCompoundStatement statements, aCompoundStatement declarations)
			ifNotEmpty: [ stream cr ].
		stream tab: level.
		stream nextPut: $} ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitConstant: aConstant [

	stream nextPutAll: aConstant value asString
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitDeclaration: aDeclaration [

	aDeclaration specifiers do: [ :e | 
		stream nextPutAll: e.
		stream space ].

	aDeclaration hasRawPrototype ifFalse: [ 
		aDeclaration declarators
			do: [ :e | e acceptVisitor: self ]
			separatedBy: [ stream nextPutAll: ', ' ] ].
	aDeclaration isFunctionPrototype ifTrue: [ stream nextPut: $; ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitDeclarator: aDeclarator [

	aDeclarator qualifiers do: [ :e | 
		stream nextPutAll: e.
		stream space ].

	aDeclarator pointers do: [ :e | stream nextPutAll: e ].

	aDeclarator declarator acceptVisitor: self
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitDecrement: anDecrementNode [
	| visit |
	visit := [ anDecrementNode object acceptVisitor: self ].
	anDecrementNode prefix ifFalse: visit.
	stream nextPutAll: '--'.
	anDecrementNode prefix ifTrue: visit.
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitDoStatement: aDoStatement [

	stream nextPutAll: 'do'.
	aDoStatement statement acceptVisitor: self.
	stream nextPutAll: 'while('.
	aDoStatement while acceptVisitor: self.
	stream nextPut: $)
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitEmptyStatement: anEmptyStatement [
	"Nothing to print."
	self printComments: anEmptyStatement comments
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitExpressionList: anExpressionList [

	| needCommaAndCommentSeries futureIndex expressions commentSeries |
	stream nextPut: $(.
	futureIndex := 1.
	expressions := anExpressionList expressions.
	commentSeries := true.
	expressions
		do: [ :e |
			e acceptVisitor: self.
			futureIndex := futureIndex + 1.
			needCommaAndCommentSeries := self
				                             expressionListNeedAComma: expressions
				                             current: e
				                             futureIndex: futureIndex
				                             commentSeries: commentSeries.
			commentSeries := needCommaAndCommentSeries second ]
		separatedBy: [
			needCommaAndCommentSeries first
				ifFalse: [ stream nextPutAll: ' ' ]
				ifTrue: [
					stream nextPutAll: ', '.
					anExpressionList printOnMultipleLines ifTrue: [ stream cr ] ] ].
	stream nextPut: $)
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitForStatement: aForStatement [

	stream nextPutAll: 'for ('.
	aForStatement init
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: '; '.
	aForStatement until acceptVisitor: self.
	stream nextPutAll: '; '.
	aForStatement step
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: ') '.
	aForStatement statement acceptVisitor: self
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitFunctionDeclarator: aFunctionDeclarator [

	aFunctionDeclarator declarator acceptVisitor: self.
	stream nextPut: $(.
	aFunctionDeclarator parameters
		do: [ :arg | arg acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $)
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitFunctionDefinition: aFunction [

	aFunction specifiers
		do: [ :e | stream nextPutAll: e ]
		separatedBy: [ stream space ].
	stream cr.
	aFunction hasRawPrototype ifFalse: [ 
		aFunction declarator acceptVisitor: self ].
	stream cr.
	aFunction body acceptVisitor: self.
	stream cr.
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitGotoStatement: aGoToStatement [

	stream nextPutAll: 'goto ';
			 nextPutAll: aGoToStatement label name
	
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitIdentifier: anIdentifier [

	stream nextPutAll: anIdentifier name
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitIfStatement: anIf [

	stream nextPutAll: 'if ('.
	anIf if acceptVisitor: self.
	stream nextPutAll: ') '.
	anIf then isCompoundStatement ifFalse: [ stream crtab: level + 1 ].
	anIf then acceptVisitor: self.
	anIf then needsTrailingSemicolon ifTrue: [ stream nextPut: $; ].
	anIf else ifNotNil: [ :e | 
		anIf then isCompoundStatement ifFalse: [ stream crtab: level ].
		stream nextPutAll: ' else '.
		anIf else isCompoundStatement ifFalse: [ stream crtab: level + 1 ].
		e acceptVisitor: self.
		anIf else needsTrailingSemicolon ifTrue: [ stream nextPut: $; ]]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitIncrement: anIncrementNode [
	| visit |
	visit := [ anIncrementNode object acceptVisitor: self ].
	anIncrementNode prefix ifFalse: visit.
	stream nextPutAll: '++'.
	anIncrementNode prefix ifTrue: visit.
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitInitDeclarator: anInitDeclarator [

	anInitDeclarator declarator acceptVisitor: self.
	stream nextPutAll: ' = '.
	anInitDeclarator initializer acceptVisitor: self.
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitInitializer: anInitializer [

	stream
		nextPut: ${;
		crtab: level + 1.
	anInitializer initializers
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream crtab: level.
	stream nextPut: $}
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitLabeledStatement: aLabeledStatement [

	"Case and labels are overloaded in the same node..."

	aLabeledStatement case ifNotNil: [ 
		aLabeledStatement case = 'default'
			ifTrue: [ stream nextPutAll: 'default' ]
			ifFalse: [ 
				stream nextPutAll: 'case '.
				aLabeledStatement case acceptVisitor: self ] ].

	aLabeledStatement label ifNotNil: [ 
		stream nextPutAll: aLabeledStatement label name ].

	(aLabeledStatement case notNil or: [ aLabeledStatement label notNil ]) 
		ifTrue: [ stream nextPutAll: ':'.
			aLabeledStatement comments ifNotEmpty: [ stream cr ] ].

	self printComments: aLabeledStatement comments.

	stream crtab: level.

	aLabeledStatement statement acceptVisitor: self.

	"Close the statement here to keep compatibility with slang"
	((aLabeledStatement case notNil or: [ aLabeledStatement label notNil ]) 
		 and: [ aLabeledStatement statement needsSeparator ]) ifTrue: [ 
		stream nextPutAll: ';' ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitParameterDeclaration: aParameter [

	"Raw declaration wins over a normal declaration."
	aParameter rawDeclaration
		ifNotNil: [ stream nextPutAll: aParameter rawDeclaration ]
		ifNil: [ 
			aParameter specifiers do: [ :e | 
				stream nextPutAll: e.
				stream space ].
			aParameter declarator acceptVisitor: self ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitPoint: aMemberAccess [

	aMemberAccess needsParentheses ifTrue:  [ stream nextPut: $(].
	self printExpression: aMemberAccess object.
	stream nextPut: $..
	aMemberAccess member acceptVisitor: self.
	aMemberAccess needsParentheses ifTrue:  [ stream nextPut: $)].
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitPreprocessorDefine: aPreprocessorDefine [

	stream nextPutAll: '#define '.
	aPreprocessorDefine token acceptVisitor: self.
	stream space.
	"Raw declaration wins over a normal declaration."
	aPreprocessorDefine rawMacro
		ifNotNil: [ stream nextPutAll: aPreprocessorDefine rawMacro ]
		ifNil: [ aPreprocessorDefine expression acceptVisitor: self ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitPreprocessorIf: anIf [

	| previousLevel tabbing |
	previousLevel := level.
	level := anIf isArgument ifTrue: [ 
			tabbing := level + 1.
			level + 2 ]
		ifFalse: [ 
			tabbing := level ].

	stream
		cr;
		nextPut: $#;
		next: tabbing * 2 put: Character space;
		nextPutAll: 'if '.
	anIf if acceptVisitor: self.
	stream crtab: level.
	anIf then acceptVisitor: self.
	
	anIf else ifNotNil: [ :e | 
		stream
			cr;
			nextPut: $#;
			next: tabbing * 2 put: Character space;
			nextPutAll: 'else /* '.
		anIf if acceptVisitor: self.
		stream
			nextPutAll: ' */';
			crtab: level.
		e acceptVisitor: self ].
	stream
		cr;
		nextPut: $#;
		next: tabbing * 2 put: Character space;
		nextPutAll: 'endif /* '.
	anIf if acceptVisitor: self.
	stream
		nextPutAll: ' */'.
	anIf isArgument ifTrue: [ stream crtab: level ].
	level := previousLevel.
]

{ #category : 'visiting' }
CSlangPrettyPrinter >> visitRawCode: aCRawCodeNode [ 
	
	stream nextPutAll: aCRawCodeNode code asString
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitReturnStatement: aReturn [

	stream nextPutAll: 'return'.
	aReturn expression ifNotNil: [ :exp |
		stream space.
		exp acceptVisitor: self ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitStringLiteral: aStringLiteral [

	aStringLiteral needsDoubleQuotes ifTrue: [ stream nextPut: $" ].
	stream nextPutAll: aStringLiteral value.
	aStringLiteral needsDoubleQuotes ifTrue: [ stream nextPut: $" ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitSwitchStatement: aSwitchStatement [

	stream nextPutAll: 'switch ('.
	aSwitchStatement if acceptVisitor: self.
	stream nextPutAll: ') '.
	aSwitchStatement statement acceptVisitor: self.
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitTernary: aTernary [

	stream nextPutAll: '(('.
	aTernary condition acceptVisitor: self.
	stream nextPut: $).
	aTernary printOnMultipleLines ifTrue: [ 
		level := level + 1.
		stream crtab: level ].
	stream nextPutAll: ' ? '.
	aTernary then acceptVisitor: self.
	aTernary printOnMultipleLines ifTrue: [ stream crtab: level ].
	stream nextPutAll: ' : '.
	aTernary else acceptVisitor: self.
	stream nextPut: $).
	aTernary printOnMultipleLines ifTrue: [ level := level - 1 ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitTypename: aTypename [

	stream nextPutAll: aTypename symbol
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitUnaryOperator: anUnary [

	| avoidParentheses |
	anUnary needsParentheses ifTrue: [ stream nextPut: $( ].
	avoidParentheses := anUnary expression isCastExpression or: [ 
		                    anUnary expression isConstant or: [ 
			                    anUnary expression isIdentifier or: [ 
				                    anUnary expression isLeaf ] ] ].
	stream nextPutAll: anUnary operator.
	avoidParentheses ifFalse: [ stream nextPut: $( ].
	anUnary expression acceptVisitor: self.
	avoidParentheses ifFalse: [ stream nextPut: $) ].
	anUnary needsParentheses ifTrue: [ stream nextPut: $) ]
]

{ #category : 'generated' }
CSlangPrettyPrinter >> visitWhileStatement: aWhileStatement [

	stream nextPutAll: 'while ('.
	aWhileStatement while acceptVisitor: self.
	stream nextPutAll: ') '.
	aWhileStatement statement acceptVisitor: self
]

{ #category : 'accessing' }
CSlangPrettyPrinter >> writeStream: aWriteStream [

	stream := aWriteStream 
]
