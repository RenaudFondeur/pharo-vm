Class {
	#name : #SLFlexibleTypingTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturn [

	<var: #j type: #'char *'>
	| i j |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ self ].
	i == 7 ifTrue: [ ^ -1 ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnAndConflict [
	"k introduce an error"
	<var: #k type: #int>
	<var: #j type: #'char *'>
	| i j k |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ self ].
	i == 7 ifTrue: [ ^ -1 ].
	i == 8 ifTrue: [ ^ k ].
	^ j
]
