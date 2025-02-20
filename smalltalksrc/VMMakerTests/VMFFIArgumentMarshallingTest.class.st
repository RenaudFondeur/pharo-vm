Class {
	#name : 'VMFFIArgumentMarshallingTest',
	#superclass : 'VMAbstractFFITest',
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'private' }
VMFFIArgumentMarshallingTest class >> isAbstract [
	
	^ self == VMFFIArgumentMarshallingTest
]

{ #category : 'implementation' }
VMFFIArgumentMarshallingTest >> doTestFuntionWithArgumentType: argumentType smalltalkValue: smalltalkValue expectedValue: expectedValue [

	self subclassResponsibility 
]

{ #category : 'implementation' }
VMFFIArgumentMarshallingTest >> doTestFuntionWithArgumentType: argumentType smalltalkValue: smalltalkValue failsWith: expectedErrorCode [

	self subclassResponsibility 
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> newLargeIntegerForValue: aValue [

	| newLargeInteger byteSize class |
	byteSize := ((aValue abs log: 2) + 1 roundUpTo: 8) / 8.
	class := aValue > 0 ifTrue: [ ClassLargePositiveIntegerCompactIndex ] ifFalse: [ ClassLargeNegativeIntegerCompactIndex ].
	
	newLargeInteger := memory
		                   eeInstantiateSmallClassIndex: class
		                   format: (memory byteFormatForNumBytes: byteSize)
		                   numSlots:
		                   (byteSize / memory bytesPerOop) ceiling asInteger.

	0 to: byteSize do: [ :i | 
		memory
			storeByte: i
			ofObject: newLargeInteger
			withValue: (aValue byteAt: i + 1) ].
	^ newLargeInteger
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithCharacterArgumentIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI char
		smalltalkValue: (memory characterObjectOf: 17)
		expectedValue: 17
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithDoubleArgumentIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI double
		smalltalkValue: (memory floatObjectOf: 17.0)
		expectedValue: 17.0
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithFloatArgumentIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI float
		smalltalkValue: (memory floatObjectOf: 17.0)
		expectedValue: 17.0
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithPointerArgumentIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI pointer
		smalltalkValue: (self newExternalAddress: 17)
		expectedValue: 17
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT16ArgumentWithNegativeValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint16
		smalltalkValue: (memory integerObjectOf: -42)
		expectedValue: -42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT16ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint16
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT16NegativeOutOfRangeProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint16
		smalltalkValue: (memory integerObjectOf: INT16_MIN - 1)
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT16PositiveOutOfRangeProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint16
		smalltalkValue: (memory integerObjectOf: INT16_MAX + 1)
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32ArgumentWithLargeNegativeValueIsMarshalledCorrectly [

	| aValue aValueToStore |

	aValue := -16r40000000 - 2.

	aValueToStore := self wordSize = 8
		                ifTrue: [ memory integerObjectOf: aValue ]
		                ifFalse: [ self newLargeIntegerForValue: aValue ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint32
		smalltalkValue: aValueToStore
		expectedValue: aValue
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32ArgumentWithLargePositiveHigherThan4BytesFails [

	| aValue |

	aValue := self wordSize = 8
		                ifTrue: [ memory integerObjectOf: UINT32_MAX * 2 ]
		                ifFalse: [ self newLargeIntegerForValue: UINT32_MAX * 2 ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint32
		smalltalkValue: aValue
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32ArgumentWithNegativeValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint32
		smalltalkValue: (memory integerObjectOf: -42)
		expectedValue: -42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint32
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32NegativeOutOfRangeProducesBadArgument [

	| valueToStore |
	valueToStore := self wordSize = 8 
		ifTrue: [ memory integerObjectOf: INT32_MIN - 1 ]
		ifFalse: [ memory signed32BitIntegerFor: INT32_MIN - 1 ].


	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint32
		smalltalkValue: valueToStore
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT32PositiveOutOfRangeProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint32
		smalltalkValue: (memory signed32BitIntegerFor: INT32_MAX + 1)
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT64ArgumentWithLargeNegativeValueIsMarshalledCorrectly [

	| aValue |
	aValue := interpreter objectMemory minSmallInteger - 2.

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint64
		smalltalkValue: (interpreter signed64BitIntegerFor: aValue)
		expectedValue: aValue
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT64ArgumentWithLargePositiveHigherThan8BytesFails [

	| aValue newLargeInteger |
	aValue := UINT64_MAX * 2.
	newLargeInteger := memory
							eeInstantiateSmallClassIndex: ClassLargePositiveIntegerCompactIndex
							format: (memory byteFormatForNumBytes: aValue size)
							numSlots: (aValue size / memory bytesPerOop) ceiling asInteger.

	0 to: 8 do: [ :i | 
		memory storeByte: i ofObject: newLargeInteger withValue: (aValue byteAt: i + 1) ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint64
		smalltalkValue: newLargeInteger
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT64ArgumentWithLargePositiveValueIsMarshalledCorrectly [

	| aValue |
	aValue := interpreter objectMemory maxSmallInteger + 2.

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint64
		smalltalkValue: (interpreter signed64BitIntegerFor: aValue)
		expectedValue: aValue

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT64ArgumentWithNegativeValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint64
		smalltalkValue: (memory integerObjectOf: -42)
		expectedValue: -42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT64ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint64
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT8ArgumentWithNegativeValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint8
		smalltalkValue: (memory integerObjectOf: -42)
		expectedValue: -42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT8ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI sint8
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT8NegativeOutOfRangeProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint8
		smalltalkValue: (memory integerObjectOf: INT8_MIN - 1)
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithSINT8PositiveOutOfRangeProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI sint8
		smalltalkValue: (memory integerObjectOf: INT8_MAX + 1)
		failsWith: PrimErrBadArgument

]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithStructByteArrayArgumentIsMarshalledCorrectly [

	| oop ptr storedValue |

	storedValue := #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16].

	oop := memory instantiateClass: memory classByteArray indexableSize: 16.
	ptr := memory cCoerce: (memory firstIndexableField: oop) to: #'char *'.
	memory memcpy: ptr _: storedValue _: storedValue size. 
	
	self
		doTestFuntionWithArgumentType: (interpreter libFFI structWith: { interpreter libFFI double. interpreter libFFI double })
		smalltalkValue: oop
		expectedValue: storedValue
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithStructPointerArgumentIsMarshalledCorrectly [

	| oop ptr storedValue |

	storedValue := #[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16].

	oop := memory instantiateClass: memory classByteArray indexableSize: 16.
	ptr := memory cCoerce: (memory firstIndexableField: oop) to: #'char *'.
	memory memcpy: ptr _: storedValue _: storedValue size. 
	
	self
		doTestFuntionWithArgumentType: (interpreter libFFI structWith: { interpreter libFFI double. interpreter libFFI double })
		smalltalkValue: (self newExternalAddress: ptr asInteger)
		expectedValue: storedValue
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT16ArgumentWithNegatieValueFails [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint16
		smalltalkValue: (memory integerObjectOf: -42)
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT16ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint16
		smalltalkValue: (memory integerObjectOf: 8)
		expectedValue: 8
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT16WithPositiveOutOfRangeFailsWithPrimErrBadArgument [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint16
		smalltalkValue: (memory integerObjectOf: UINT16_MAX + 1)
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT32ArgumentWithLargePositiveHigherThan4BytesFails [

	| aValue |

	aValue := self wordSize = 8
		                ifTrue: [ memory integerObjectOf: UINT32_MAX * 2 ]
		                ifFalse: [ self newLargeIntegerForValue: UINT32_MAX * 2 ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint32
		smalltalkValue: aValue
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT32ArgumentWithLargePositiveValueIsMarshalledCorrectly [

	| aValue |

	aValue := self wordSize = 8
		                ifTrue: [ memory integerObjectOf: 16r3FFFFFFF + 2 ]
		                ifFalse: [ self newLargeIntegerForValue: 16r3FFFFFFF + 2 ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint32
		smalltalkValue: aValue
		expectedValue: 16r3FFFFFFF + 2
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT32ArgumentWithNegatieValueFails [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint32
		smalltalkValue: (memory integerObjectOf: -42)
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT32ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint32
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT32WithPositiveOutOfRangeFailsWithPrimErrBadArgument [

	| valueToStore |

	valueToStore := self wordSize = 8
		                ifTrue: [ memory integerObjectOf: UINT32_MAX + 1 ]
		                ifFalse: [ self newLargeIntegerForValue: UINT32_MAX + 1 ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint32
		smalltalkValue: valueToStore
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT64ArgumentWithLargePositiveHigherThan8BytesFails [

	| aValue newLargeInteger |
	aValue := UINT64_MAX * 2.
	newLargeInteger := memory
							eeInstantiateSmallClassIndex: ClassLargePositiveIntegerCompactIndex
							format: (memory byteFormatForNumBytes: aValue size)
							numSlots: (aValue size / memory bytesPerOop) ceiling asInteger.

	0 to: 8 do: [ :i | 
		memory storeByte: i ofObject: newLargeInteger withValue: (aValue byteAt: i + 1) ].

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint64
		smalltalkValue: newLargeInteger
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT64ArgumentWithLargePositiveValueIsMarshalledCorrectly [

	| aValue |
	aValue := interpreter objectMemory maxSmallInteger + 2.

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint64
		smalltalkValue: (interpreter signed64BitIntegerFor: aValue)
		expectedValue: aValue
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT64ArgumentWithNegatieValueFails [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint64
		smalltalkValue: (memory integerObjectOf: -42)
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT64ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint64
		smalltalkValue: (memory integerObjectOf: 42)
		expectedValue: 42
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT8ArgumentWithNegatieValueFails [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint8
		smalltalkValue: (memory integerObjectOf: -42)
		failsWith: PrimErrBadArgument
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT8ArgumentWithPositiveValueIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint8
		smalltalkValue: (memory integerObjectOf: 8)
		expectedValue: 8
]

{ #category : 'tests - parameters marshalling' }
VMFFIArgumentMarshallingTest >> testCalloutWithUINT8WithPositiveOutOfRangeFailsWithPrimErrBadArgument [

	self
		doTestFuntionWithArgumentType: interpreter libFFI uint8
		smalltalkValue: (memory integerObjectOf: UINT8_MAX + 1)
		failsWith: PrimErrBadArgument
]
