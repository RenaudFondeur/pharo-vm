Class {
	#name : #SLTypeHarmonizationTest,
	#superclass : #SlangAbstractTestCase,
	#instVars : [
		'types'
	],
	#category : #'Slang-Tests'
}

{ #category : #utilities }
SLTypeHarmonizationTest >> add: type [ 
	types at: type put: 1
]

{ #category : #utilities }
SLTypeHarmonizationTest >> harmonizeReturnTypesIn: aDictionaryOfTypes [

	| constantIntegerNodes |
	constantIntegerNodes := Dictionary new.
	(aDictionaryOfTypes keys select: [ :element | element isInteger ]) do: [
		:each | constantIntegerNodes at: each put: Set new ].
	^ ccg
		  harmonizeReturnTypesIn: aDictionaryOfTypes asDictionary
		  notify: constantIntegerNodes
]

{ #category : #running }
SLTypeHarmonizationTest >> setUp [
	super setUp.
	types := Dictionary new.
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedChar [
	"cast a char to an int"
	| result |
	self add: #char.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedCharAndInt [
	| result |
	self add: #int.
	self add: #char.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedCharAndUnknown [
	| result |
	self add: #unknown.
	self add: #char.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedCharPtr [
	"doesn't change the type"
	| result |
	self add: #'char *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'char *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedEmptyRetrunType [
	"unknowned type doesn't get any transformation"
	| result |
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedInt [
	| result |
	self add: #int.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndLongNotWorking [
	"the type are not merged"
	| result |
	self add: #int.
	self add: #long.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #long ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndLonglongNotWorking [
	"the type are not merged"
	| result |
	self add: #int.
	self add: #'long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndShort [
	| result |
	self add: #int.
	self add: #short.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntAndLonglongNotAndUnsignedlonglongWorking [
	"default to signed type"
	| result |
	self add: #int.
	self add: #'unsigned int'.
	self add: #'long long'.
	self add: #'unsigned long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntAndLonglongNotWorking [
	"default to signed type"
	| result |
	self add: #int.
	self add: #'unsigned int'.
	self add: #'long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntNotWorking [
	"default to signed type"
	| result |
	self add: #int.
	self add: #'unsigned int'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedIntPtr [
	"doesn't change the type"
	| result |
	self add: #'int *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'int *' ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedKnownTypeAndNotKnownAndUnsignedIntNotWorking [
	"if at least one of the type isn't in #(char short int #'long long' #'unsigned char' #'unsigned short' #'unsigned int' #'unsigned long long') then it will remain unmerged"
	| result |
	self add: #int.
	self add: #'unsigned int'.
	self add: #unknown.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedKnownTypeAndNotKnownNotWorking [
	"if at least one of the type isn't in #(char short int #'long long' #'unsigned char' #'unsigned short' #'unsigned int' #'unsigned long long') then it will remain unmerged"
	| result |
	self add: #int.
	self add: #short.
	self add: #unknown.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedLong [
	"long type doesn't get any transformation, it counts as unknown"
	| result |
	self add: #long.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #long ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedLongAndUnsignedLongNotWorking [
	"doesn't merge the type"
	| result |
	self add: #long.
	self add: #'unsigned long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #long ; add: #'unsigned long' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedLongPtr [
	"doesn't change the type"
	| result |
	self add: #'long *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'long *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedLonglong [
	| result |
	self add: #'long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedLonglongPtr [
	"doesn't change the type"
	| result |
	self add: #'long long*'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'long long*' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedNumber [
	| result |
	self add: 7.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedNumberAndAnything [
	"doesn't harmonize and produce a notification"
	| result |
	self add: 7.
	self add: #anything.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #anything ; add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedNumbers [
	| result |
	self add: 7.
	self add: 8.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedShort [
	"cast short to int"
	| result |
	self add: #short.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedShortPtr [
	"doesn't change the type"
	| result |
	self add: #'short *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'short *' ; yourself ).
	
	
]

{ #category : #harmonizeSignedAndUnsigned }
SLTypeHarmonizationTest >> testHarmonizedSignedUnsignedIntNotWorking [
	| result |
	self add: #int.
	self add: #'unsigned int'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeSignedAndUnsigned }
SLTypeHarmonizationTest >> testHarmonizedSignedUnsignedNotWorking [
	"ignore the unsigned long long in the merge operation"
	| result |
	self add: #int.
	self add: #'unsigned int'.
	self add: #'unsigned long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnknown [
	"unknowned type doesn't get any transformation"
	| result |
	self add: #unknown.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnknownPtr [
	"doesn't change the type"
	| result |
	self add: #'unknown *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unknown *' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedIntPtr [
	"doesn't change the type"
	| result |
	self add: #'unsigned int *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned int *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedchar [
	"cast an unsigned char to an usqInt"
	| result |
	self add: #'unsigned char'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'usqInt' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedcharPtr [
	"doesn't change the type"
	| result |
	self add: #'unsigned char *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned char *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedint [
	| result |
	self add: #'unsigned int'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlong [
	"unsigned long type doesn't get any transformation, it counts as unknown"
	| result |
	self add: #'unsigned long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlongPtr [
	"doesn't change the type"
	| result |
	self add: #'unsigned long *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlonglong [
	| result |
	self add: #'unsigned long long'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'usqLong' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlonglongPtr [
	"doesn't change the type"
	| result |
	self add: #'unsigned long long*'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long long*' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedshort [
	| result |
	self add: #'unsigned short'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedshortPtr [
	"doesn't change the type"
	| result |
	self add: #'unsigned short *'.
	result := self harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned short *' ; yourself ).
	
	
]
