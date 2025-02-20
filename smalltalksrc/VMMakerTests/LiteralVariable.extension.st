Extension { #name : 'LiteralVariable' }

{ #category : '*VMMakerTests' }
LiteralVariable >> forMemory: aMemory inMethod: anObject [

	| aVariable |
	aVariable := aMemory
		             allocateSlotsInOldSpace: 2
		             format: aMemory nonIndexablePointerFormat
		             classIndex: self class hash.

	aMemory
		storePointer: 0
		ofObject: aVariable
		withValue: (name forMemory: aMemory inMethod: nil).
	aMemory
		storePointer: 1
		ofObject: aVariable
		withValue: aMemory nilObject.

	^ aVariable
]
