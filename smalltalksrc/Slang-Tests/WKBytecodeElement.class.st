Class {
	#name : #WKBytecodeElement,
	#superclass : #VMStructType,
	#instVars : [
		'literals'
	],
	#category : #'Slang-Tests'
}

{ #category : #examples }
WKBytecodeElement >> abstractMethod [ 
	self subclassResponsibility 
]

{ #category : #accessing }
WKBytecodeElement >> classLiteralAt: anInteger [

	^ literals at: anInteger
]
