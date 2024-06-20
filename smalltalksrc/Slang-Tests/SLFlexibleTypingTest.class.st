Class {
	#name : #SLFlexibleTypingTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #running }
SLFlexibleTypingTest >> setUp [
	super setUp.
	ccg addClass: SLFlexibleTypingTestClass.
	ccg inferTypes.
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturn [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturn.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTest >> testMethodWithEarlyReturnAndConflict [
	| tMethod |
	tMethod := ccg methodNamed: #methodWithEarlyReturnAndConflict.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #'char *'
]
