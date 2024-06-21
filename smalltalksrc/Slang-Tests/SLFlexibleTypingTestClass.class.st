Class {
	#name : #SLFlexibleTypingTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndInt [

	<var: #j type: #'char *'>
	| i j |
	i == 5 ifTrue: [ ^ -1 ].
	i == 6 ifTrue: [ ^ -1 ].
	i == 7 ifTrue: [ ^ -1 ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndNil [

	<var: #j type: #'char *'>
	| i j |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ nil ].
	i == 7 ifTrue: [ ^ nil ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndNilConflict [
	"k introduce a conflict"
	<var: #k type: #int>
	<var: #j type: #'char *'>
	| i j k |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ nil ].
	i == 7 ifTrue: [ ^ nil ].
	i == 8 ifTrue: [ ^ k ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndNilPositiveInteger [
	"positive integers get a special traitment in Slang du to signed/unsigned resolution, here they should be ignore anyways"

	<var: #j type: #'char *'>
	| i j |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ nil ].
	i == 7 ifTrue: [ ^ 0 ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndNilPositiveIntegerConflict [
	"k introduce a conflict"
	<var: #k type: #int>
	<var: #j type: #'char *'>
	| i j k |
	i == 5 ifTrue: [ ^ nil ].
	i == 6 ifTrue: [ ^ nil ].
	i == 7 ifTrue: [ ^ 0 ].
	i == 8 ifTrue: [ ^ k ].
	^ j
]

{ #category : #'ignore-early-return' }
SLFlexibleTypingTestClass >> methodWithEarlyReturnPtrAndSelf [

	<var: #j type: #'char *'>
	| i j |
	i == 5 ifTrue: [ ^ self ].
	i == 6 ifTrue: [ ^ self ].
	i == 7 ifTrue: [ ^ self ].
	^ j
]
