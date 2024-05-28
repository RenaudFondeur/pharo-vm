Class {
	#name : #WKBytecodeClass,
	#superclass : #WKBytecodeElement,
	#instVars : [
		'methods',
		'superclass',
		'name',
		'interpreter',
		'numberOfSlots'
	],
	#category : #'Slang-Tests'
}

{ #category : #accessing }
WKBytecodeClass >> classLiteralAtNotAbstract: anInteger [

	^ literals at: anInteger
]
