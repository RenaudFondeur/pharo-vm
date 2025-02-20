Class {
	#name : 'SlangAbstractTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'ccg'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'asserting' }
SlangAbstractTestCase >> assertReturnTypeOf: aMethod equalsHarmonized: expectedType [

	"The type inferencer harmonizes return types converting them to the closer sq* integer (either signed or unsigned)"
	| harmonizedTypes |
	harmonizedTypes := ccg harmonizeReturnTypesIn: { expectedType } asSet.
	self assert: harmonizedTypes size = 1 description: 'There seems to be a type conflict'.
	self assert: aMethod returnType equals: harmonizedTypes anyOne.
]
