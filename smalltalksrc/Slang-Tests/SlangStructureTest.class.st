Class {
	#name : #SlangStructureTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #running }
SlangStructureTest >> setUp [
	super setUp.
	ccg addClass: WKBytecodeElement.
	ccg addClass: WKBytecodeClass.
	ccg addClass: WKBytecodeMethod.
	
	ccg inferTypes.
]

{ #category : #'experiment-struct' }
SlangStructureTest >> testClassLiteralAt [
	| tMethod |
	self halt.
	tMethod := ccg methodNamed: #classLiteralAt.
	tMethod 
]
