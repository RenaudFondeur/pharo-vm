Class {
	#name : #WKBytecodeMethod,
	#superclass : #VMStructType,
	#instVars : [
		'selector',
		'isNative',
		'methodBytecode',
		'numberOfParameters',
		'bytecodeClass',
		'exceptionHandlers'
	],
	#category : #'Slang-Tests'
}

{ #category : #accessing }
WKBytecodeMethod >> methodLiteralAt: anInteger [
	<var: #bytecodeClass type: #WKBytecodeClass>
	
	^ bytecodeClass classLiteralAt: anInteger
]
