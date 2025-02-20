Class {
	#name : 'VMByteCodesTest',
	#superclass : 'VMInterpreterTests',
	#instVars : [
		'contextOop',
		'context',
		'callingFrame',
		'topFrame'
	],
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'helper-assertions' }
VMByteCodesTest >> assert: aBlock pop: anOop intoTemporary: anIndex [
	| oldStackSize |
	oldStackSize := interpreter stackPointer.
	
	aBlock value.
	
	self assert: interpreter stackPointer equals: oldStackSize + memory wordSize.
	self assert: (interpreter temporary: anIndex in: interpreter framePointer) equals: anOop
]

{ #category : 'helper-assertions' }
VMByteCodesTest >> assert: aBlock pushed: anOop [
	| oldStackSize |
	oldStackSize := interpreter stackPointer.
	
	aBlock value.
	
	self assert: interpreter stackPointer equals: oldStackSize - memory wordSize.
	self assert: interpreter stackTop equals: anOop.
	
]

{ #category : 'helper-assertions' }
VMByteCodesTest >> assert: aBlock returned: anOop [
	| callerSP |
	callerSP := interpreter frameCallerSP: interpreter framePointer.
	
	aBlock value.
	
	self assert: interpreter stackPointer equals: callerSP - memory wordSize.
	self assert: interpreter stackTop equals: anOop.
	
]

{ #category : 'helper-assertions' }
VMByteCodesTest >> assertPopped: aBlock [
	| oldStackSize |
	oldStackSize := interpreter stackPointer.
	
	aBlock value.
	
	self assert: interpreter stackPointer equals: oldStackSize + memory wordSize.
	
]

{ #category : 'helpers-bytecode-table' }
VMByteCodesTest >> firstPushTemporaryVariableBytecode [
	"in v3 bytecode table"
	^ 16
]

{ #category : 'helpers-bytecode-table' }
VMByteCodesTest >> firstStoreAndPopTemporaryVariableBytecode [
	^ 104
]

{ #category : 'helper-interpret' }
VMByteCodesTest >> interpret: aBlock [

	aBlock value
]

{ #category : 'tests-simd' }
VMByteCodesTest >> interpretNextBytecode [

	| count |
	count := 0.
	interpreter interpretWhile: [ 
		count := count + 1.
		count = 1 ]
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> interpretWithFrame: aBlock [

	callingFrame := stackBuilder addNewFrame method:
		                methodBuilder newMethod buildMethod.
	topFrame := stackBuilder addNewFrame method:
		            methodBuilder newMethod buildMethod.
	stackBuilder buildStack.

	self interpret: aBlock
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> pushTempTest: index [
	
	stackBuilder addNewFrame tempAt: index put: (memory integerObjectOf: 42).
	stackBuilder buildStack.
	interpreter currentBytecode: (self pushTemporaryVariableBytecodeAt: index).
	
	"first we push something, so there is something to duplicate"
	self
		assert: [ self interpret: [ interpreter pushTemporaryVariableBytecode ] ]
		pushed: (memory integerObjectOf: 42).

]

{ #category : 'helpers-bytecode-table' }
VMByteCodesTest >> pushTemporaryVariableBytecodeAt: offset [
	^ self firstPushTemporaryVariableBytecode + offset.
	
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> pushThisContextTopFrame [

	self interpretWithFrame: [ interpreter pushActiveContextBytecode ].

	contextOop := interpreter stackTop.
	context := VMContext
		newOnContext: contextOop
		withInterpreter: interpreter
]

{ #category : 'tests-simd' }
VMByteCodesTest >> setUp [ 

	super setUp.
	self installFloat64RegisterClass
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> storeAndPopTemporaryIntoTempTest: index [
	
	stackBuilder addNewFrame
		tempAt: index put: (memory nilObject) ;
		stack: { memory integerObjectOf: 42 } .
	stackBuilder buildStack.
	
	interpreter currentBytecode: (self storeAndPopTemporaryVariableBytecodeAt: index).
	
	"first we push something, so there is something to duplicate"
	self assert: [ self interpret: [ interpreter storeAndPopTemporaryVariableBytecode ] ]
		pop: (memory integerObjectOf: 42)
		intoTemporary: index
]

{ #category : 'helpers-bytecode-table' }
VMByteCodesTest >> storeAndPopTemporaryVariableBytecodeAt: anInteger [ 
	^ self firstStoreAndPopTemporaryVariableBytecode + anInteger
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testAccessingSenderOfContextShouldReturnContextOfSender [
	| oldMaybeSenderContext newMaybeSenderContext |
	self interpretWithFrame: [ interpreter pushActiveContextBytecode. ].
	oldMaybeSenderContext := interpreter instVar: SenderIndex ofContext: interpreter stackTop.
	interpreter pushActiveContextBytecode.
	newMaybeSenderContext := interpreter instVar: SenderIndex ofContext: interpreter stackTop.
	self assert: oldMaybeSenderContext equals: newMaybeSenderContext
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testAddVectorBytecode [
	| index v0 v1 result firstTerm size |
	
	index := 0.

	firstTerm := 1.0 to: 2.0.
	size := firstTerm size.

	v0 := self new64BitIndexableFromArray: firstTerm.
	v1 := self new64BitIndexableFromArray: (firstTerm collect: [:i | i + size]).
	result := self new64BitIndexableOfSize: size. 
		
	stackBuilder addNewFrame
		stack: { v0. v1 } .
	stackBuilder buildStack.
	
	self interpret: [ interpreter addFloat64VectorBytecode ].
	
	result := interpreter stackTop.
	
	self deny: result equals: memory nilObject.
	self assert: (memory fetchFloat64: 0 ofObject: result) equals: 4.0.
	self assert: (memory fetchFloat64: 1 ofObject: result) equals: 6.0.
	
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testArraySumUsingVectorBytecode [
	| cm x y result simulatedMethod z |

	x := self new64BitIndexableFromArray: #(1.0 2.0).
	y := self new64BitIndexableFromArray: #(10.0 20.0).
	z := self new64BitIndexableOfSize: 2.
	
	cm := IRBuilder buildMethod: [ :builder |
		builder
				numArgs: 3; 		
				addTemps: { #firstVector. #secondVector. #thirdVector };
				pushLiteral: 0;
				pushTemp: #firstVector;
				pushFloat64ArrayToRegister;
				pushLiteral: 0;
				pushTemp: #secondVector;
				pushFloat64ArrayToRegister;
				addFloat64Vector;
				pushLiteral: 0;
				pushTemp: #thirdVector;
				storeFloat64RegisterIntoArray;
				returnTop
		 ].
	
	simulatedMethod := methodBuilder fillFromPharoMethod: cm;
		          buildMethod.
	
	stackBuilder addNewFrame
		method: simulatedMethod;
		temps: { x. y. z.}.
	stackBuilder buildStack.
	
	interpreter interpretUntilReturn.
	
	result := interpreter stackTop.

	self assert: (memory fetchFloat64: 0 ofObject: result) equals: 11.0.
	self assert: (memory fetchFloat64: 1 ofObject: result) equals: 22.0.
	
]

{ #category : 'tests-complex' }
VMByteCodesTest >> testBytecodePopIntoReceiverWithReadOnlySendsAttemptToAssignMethod [

	| class object objectToPutInSlot attemptToAssignMethod attemptToAssignSelector aMethodDictionary |
	class := self
		         newClassInOldSpaceWithSlots: 0
		         instSpec: memory arrayFormat.
	object := memory instantiateClass: class indexableSize: 1.
	attemptToAssignSelector := memory integerObjectOf: 2.
	attemptToAssignMethod := methodBuilder newMethod
		                         numberOfArguments: 2;
		                         buildMethod.
	self setUpMethodDictionaryIn: class.
	aMethodDictionary := memory
		                     fetchPointer: MethodDictionaryIndex
		                     ofObject: class.
	self
		installSelector: attemptToAssignSelector
		method: attemptToAssignMethod
		inMethodDictionary: aMethodDictionary.

	memory splObj: SelectorAttemptToAssign put: attemptToAssignSelector.

	memory setIsImmutableOf: object to: true.

	objectToPutInSlot := memory instantiateClass: class indexableSize: 1.

	stackBuilder addNewFrame
		receiver: object;
		stack: { objectToPutInSlot }.
	stackBuilder buildStack.

	interpreter methodDictLinearSearchLimit: 3.
	interpreter setBreakSelector: nil.
	interpreter currentBytecode: 200.

	self interpret: [ interpreter storeAndPopReceiverVariableBytecode ].

	topFrame := VMStackFrame
		            newFramePointer: interpreter framePointer
		            withInterpreter: interpreter.
	self assert: topFrame method equals: attemptToAssignMethod
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testCallMappedInlinedPrimitiveBytecode [

	| v0 v1 result method |
	v0 := self new64BitIndexableOfSize: 2.
	v1 := self new64BitIndexableOfSize: 2.
	memory storeFloat64: 0 ofObject: v0 withValue: 1.0.
	memory storeFloat64: 1 ofObject: v0 withValue: 2.0.
	memory storeFloat64: 0 ofObject: v1 withValue: 3.0.
	memory storeFloat64: 1 ofObject: v1 withValue: 4.0.
	
	method := methodBuilder newMethod
		          bytecodes: #[ "callMappedInlinedPrimitiveBytecode" 236 "addVectorBytecode" 0 ];
		          buildMethod.
	stackBuilder addNewFrame
		method: method;
		stack: { v0. v1 }.
	stackBuilder buildStack.
	
	self interpretNextBytecode.
	
	result := interpreter stackTop.
	self deny: result equals: memory nilObject.
	self assert: (memory fetchFloat64: 0 ofObject: result) equals: 4.0.
	self assert: (memory fetchFloat64: 1 ofObject: result) equals: 6.0
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testDuplicateStackTop [

	stackBuilder addNewFrame ; buildStack.
	
	"first we push something, so there is something to duplicate"
	self
		assert: [ self interpret: [ interpreter pushConstantOneBytecode ] ]
		pushed: (memory integerObjectOf: 1).

	"then we duplicate it"
	self
		assert: [ self interpret: [ interpreter duplicateTopBytecode  ] ]
		pushed: (memory integerObjectOf: 1).
	
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPopStackTopBytecode [

	stackBuilder addNewFrame ; buildStack.
	
	"first we push something"
	self
		assert: [ self interpret: [ interpreter pushConstantOneBytecode ] ]
		pushed: (memory integerObjectOf: 1).
	
	"then we pop it"
	self
		assertPopped: [ self interpret: [ interpreter popStackBytecode ] ]
	
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testPushArrayToRegisterBytecode [
	| array index result |

	array := self new64BitIndexableOfSize: 4.
	memory storeFloat64: 0 ofObject: array withValue: 1.0. 
	memory storeFloat64: 1 ofObject: array withValue: 2.0.
	memory storeFloat64: 2 ofObject: array withValue: 3.0.
	memory storeFloat64: 3 ofObject: array withValue: 4.0. 
	
	index := memory integerObjectOf: 2.
	
	stackBuilder addNewFrame
		stack: { index. array } .
	stackBuilder buildStack.
	
	self interpret: [ interpreter pushFloat64ArrayToRegisterBytecode ].
	
	result := interpreter stackTop.
	
	self assert: (memory fetchFloat64: 0 ofObject: result) equals: 3.0.
	self assert: (memory fetchFloat64: 1 ofObject: result) equals: 4.0.
	
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantFalseBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantFalseBytecode ] ]
		pushed: memory falseObject
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantMinusOneBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantMinusOneBytecode ] ]
		pushed: (memory integerObjectOf: -1)
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantNilBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantNilBytecode ] ]
		pushed: memory nilObject
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantOneBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantOneBytecode ] ]
		pushed: (memory integerObjectOf: 1)
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantReceiverBytecode [
	| intReceiver |
	intReceiver := memory integerObjectOf: 42.
	
	stackBuilder addNewFrame receiver: intReceiver.
	stackBuilder buildStack.

	self
		assert: [ self interpret: [ interpreter pushReceiverBytecode ] ]
		pushed: intReceiver
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantTrueBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantTrueBytecode ] ]
		pushed: memory trueObject
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantTwoBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantTwoBytecode ] ]
		pushed: (memory integerObjectOf: 2)
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushConstantZeroBytecode [
	stackBuilder addNewFrame ; buildStack.
	self
		assert: [ self interpret: [ interpreter pushConstantZeroBytecode ] ]
		pushed: (memory integerObjectOf: 0)
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp0 [
	self pushTempTest: 0
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp1 [
	self pushTempTest: 1
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp10 [
	self pushTempTest: 10
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp11 [
	self pushTempTest: 11
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp2 [
	self pushTempTest: 2
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp3 [
	self pushTempTest: 3
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp4 [
	self pushTempTest: 4
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp5 [
	self pushTempTest: 5
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp6 [
	self pushTempTest: 6
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp7 [
	self pushTempTest: 7
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp8 [
	self pushTempTest: 8
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testPushTemp9 [
	self pushTempTest: 9
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextIsContext [

	self pushThisContextTopFrame.
	self assert: (memory isContext: interpreter stackTop).
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextPushesValidInstructionPointer [

	self pushThisContextTopFrame.
	self assert: (interpreter objectMemory isIntegerObject: context instructionPointer).
	self
		assert: (interpreter withoutSmallIntegerTags: context instructionPointer)
		equals: (interpreter frameCallerFP: interpreter framePointer)
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextPushesValidPointerToTheFramePointer [
	
	self pushThisContextTopFrame.
	self
		assert: (interpreter objectMemory isIntegerObject: context sender).
	self
		assert: (interpreter withoutSmallIntegerTags: context sender)
		equals: interpreter framePointer
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextPushesValidReceiver [

	self pushThisContextTopFrame.
	self assert: topFrame receiver equals: context receiver
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextSetContextToFrame [

	self pushThisContextTopFrame.
	self assert: (interpreter frameContext: interpreter framePointer) equals: interpreter stackTop.
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextSetFlagContextToFrame [

	self pushThisContextTopFrame.
	self assert: (interpreter frameHasContext: interpreter framePointer).
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testPushThisContextTwiceMarriesOnce [
	| previousTop newTop |
	self interpretWithFrame: [ 
		interpreter pushActiveContextBytecode.
		previousTop := interpreter stackTop.
		interpreter pushActiveContextBytecode.
		newTop := interpreter stackTop.
		 ].
	self assert: newTop equals: previousTop.
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testReturnFalse [

	"We need to return to a method.
	So the method of the first stack should have a compiled method in the method field of the stack.
	using memory trueObject simulates that behavior."

	stackBuilder addNewFrame method: methodBuilder newMethod buildMethod.
	stackBuilder addNewFrame.
	stackBuilder buildStack.

	self
		assert: [ self interpret: [ interpreter returnFalse ] ]
		returned: memory falseObject
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testReturnTrue [

	"We need to return to a method.
	So the method of the first stack should have a compiled method in the method field of the stack.
	using memory trueObject simulates that behavior."

	stackBuilder addNewFrame method: methodBuilder newMethod buildMethod.
	stackBuilder addNewFrame.
	stackBuilder buildStack.

	self
		assert: [ self interpret: [ interpreter returnTrue ] ]
		returned: memory trueObject
]

{ #category : 'tests-pushThisContext' }
VMByteCodesTest >> testReturnsMarriedFrameWidowsContext [
	| topFrameContext |
	self interpretWithFrame: [ 
		interpreter pushActiveContextBytecode.
		interpreter returnTopFromMethod.
		].
	topFrameContext := interpreter stackTop.
	"The interpreter does not update the pages, they are updated on demand. 
	Before checking a frame isWindowed we have to synchronize the interpreter variables with the stackPages"
	interpreter writeBackHeadFramePointers.
	self assert: (interpreter isWidowedContext: topFrameContext)
]

{ #category : 'tests-send' }
VMByteCodesTest >> testSendMessageWithTwoArgumentsMakeAFrame [

	| selectorOop aMethod aMethodToActivate receiver receiverClass aMethodDictionary arg1 arg2 |
	selectorOop := memory integerObjectOf: 42.
	methodBuilder newMethod literals: { selectorOop }.
	aMethod := methodBuilder buildMethod.
	aMethodToActivate := methodBuilder newMethod
		                     numberOfArguments: 2;
		                     buildMethod.
	receiver := memory integerObjectOf: 41.
	receiverClass := self setSmallIntegerClassIntoClassTable.
	self setUpMethodDictionaryIn: receiverClass.
	aMethodDictionary := memory
		                     fetchPointer: MethodDictionaryIndex
		                     ofObject: receiverClass.

	self
		installSelector: selectorOop
		method: aMethodToActivate
		inMethodDictionary: aMethodDictionary.
	arg1 := memory integerObjectOf: 1.
	arg2 := memory integerObjectOf: 2.
	stackBuilder addNewFrame
		method: aMethod;
		stack: { 
				receiver.
				arg1.
				arg2 }.
	stackBuilder buildStack.

	interpreter methodDictLinearSearchLimit: 3.
	interpreter setBreakSelector: nil.
	interpreter method: aMethod.
	interpreter currentBytecode: 240.

	self interpret: [ interpreter sendLiteralSelector2ArgsBytecode ].


	self
		assert: (VMStackFrame
				 newFramePointer: interpreter framePointer
				 withInterpreter: interpreter) receiver
		equals: receiver.
	self assert: interpreter stackTop equals: receiver
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary0 [
	self storeAndPopTemporaryIntoTempTest: 0
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary1 [
	self storeAndPopTemporaryIntoTempTest: 1
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary2 [
	self storeAndPopTemporaryIntoTempTest: 2
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary3 [
	self storeAndPopTemporaryIntoTempTest: 3
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary4 [
	self storeAndPopTemporaryIntoTempTest: 4
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary5 [
	self storeAndPopTemporaryIntoTempTest: 5
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary6 [
	self storeAndPopTemporaryIntoTempTest: 6
]

{ #category : 'tests-push-simple' }
VMByteCodesTest >> testStoreAndPopTemporary7 [
	self storeAndPopTemporaryIntoTempTest: 7
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testStoreRegisterIntoArrayBytecode [
	| register index array result |
	
	array := self new64BitIndexableOfSize: 4.
	memory storeFloat64: 0 ofObject: array withValue: 1.0. 
	memory storeFloat64: 1 ofObject: array withValue: 2.0.
	memory storeFloat64: 2 ofObject: array withValue: 3.0.
	memory storeFloat64: 3 ofObject: array withValue: 4.0. 
	
	register := self new64BitIndexableOfSize: 2.
	memory storeFloat64: 0 ofObject: register withValue: 5.0. 
	memory storeFloat64: 1 ofObject: register withValue: 6.0.
	
	index := memory integerObjectOf: 2.
	
	stackBuilder addNewFrame
		stack: { register. index. array }.
	stackBuilder buildStack.
	
	self interpret: [ interpreter storeFloat64RegisterIntoArrayBytecode ].
	
	result := interpreter stackTop.
	
	self assert: (memory fetchFloat64: 2 ofObject: result) equals: 5.0.
	self assert: (memory fetchFloat64: 3 ofObject: result) equals: 6.0.
	
	self assert: (memory fetchFloat64: 2 ofObject: array) equals: 5.0.
	self assert: (memory fetchFloat64: 3 ofObject: array) equals: 6.0.
]

{ #category : 'tests-simd' }
VMByteCodesTest >> testSubVectorBytecode [
	| index vector0 vector1 result |
	
	index := 0.

	vector0 := self new64BitIndexableOfSize: 2.
	memory storeFloat64: 0 ofObject: vector0 withValue: 5.0. 
	memory storeFloat64: 1 ofObject: vector0 withValue: 3.0. 

	vector1 := self new64BitIndexableOfSize: 2.
	memory storeFloat64: 0 ofObject: vector1 withValue: 2.0. 
	memory storeFloat64: 1 ofObject: vector1 withValue: 1.0. 
		
	stackBuilder addNewFrame
		stack: { vector0. vector1 } .
	stackBuilder buildStack.
	
	self interpret: [ interpreter subFloat64VectorBytecode ].
	
	result := interpreter stackTop.
	
	self deny: result equals: memory nilObject.
	self assert: (memory fetchFloat64: 0 ofObject: result) equals: 3.0.
	self assert: (memory fetchFloat64: 1 ofObject: result) equals: 2.0.
	
]
