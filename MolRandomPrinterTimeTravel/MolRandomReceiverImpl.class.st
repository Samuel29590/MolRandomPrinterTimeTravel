Class {
	#name : #MolRandomReceiverImpl,
	#superclass : #BlTextElement,
	#traits : 'MolComponentImpl + MolRandomReceiver + MolRandomSenderEvents + TimeTravelEvents',
	#classTraits : 'MolComponentImpl classTrait + MolRandomReceiver classTrait + MolRandomSenderEvents classTrait + TimeTravelEvents classTrait',
	#category : #MolRandomPrinterTimeTravel
}

{ #category : #'life cycle' }
MolRandomReceiverImpl >> componentActivate [

	"here write the code corresponding to component activation phase"

	
	self getMolRandomSenderEventsSubscriber subscribe: self
]

{ #category : #'life cycle' }
MolRandomReceiverImpl >> componentInitialize [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ "Connection to the TimeTravel service."
		self forServices: TimeTravelServices useProvider: #default.
		"Subscription to the Time Travel event"
		self getTimeTravelEventsSubscriber subscribe: self.
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component notifies its creation" 
			self getTimeTravelServicesProvider creationOf: self ] ].
	"---------------------------------------------------------------"

	self openInNewSpace
		extent: 350 @ 50;
		title: 'RandomPrinter Receiver'.

	self
		text: 'Waiting the sender ...' asRopedText;
		defaultFontSize: 32;
		background: Color red;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
		
	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [
		self getTimeTravelServicesProvider isRestoring ifFalse: [ "Component saves its state." 
			self saveForTimeTravel ] ]
	"---------------------------------------------------------------"
]

{ #category : #'life cycle' }
MolRandomReceiverImpl >> componentPassivate [

	"here write the code corresponding to component passivation phase"

	self getMolRandomSenderEventsSubscriber unsubscribe: self

	
]

{ #category : #'life cycle' }
MolRandomReceiverImpl >> componentRemove [

	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [
			"Component saves its state."
			self saveForTimeTravel.
			"Component notifies its deletion"
			self getTimeTravelServicesProvider deletionOf: self ] ].
	"---------------------------------------------------------------"

	spaceReference space close

	
]

{ #category : #'component accessing' }
MolRandomReceiverImpl >> getMolRandomSenderEventsSubscriber [
	| eventsSymbol eventsSubscriber itf |
	itf := MolRandomSenderEvents.
	eventsSymbol := self eventsSubscribers at: itf ifAbsent: [^MolNotFoundEventsSubscriber new interface: itf name: nil].
	eventsSymbol isCollection
	 	ifTrue: 
			[eventsSubscriber := MolComponentManager default locatorServices 
						searchEventsSubscriberFor: MolRandomSenderEvents named: eventsSymbol ]. 
	^eventsSubscriber
]

{ #category : #'component accessing' }
MolRandomReceiverImpl >> getTimeTravelEventsSubscriber [
	| eventsSymbol eventsSubscriber itf |
	itf := TimeTravelEvents.
	eventsSymbol := self eventsSubscribers at: itf ifAbsent: [^MolNotFoundEventsSubscriber new interface: itf name: nil].
	eventsSymbol isCollection
	 	ifTrue: 
			[eventsSubscriber := MolComponentManager default locatorServices 
						searchEventsSubscriberFor: TimeTravelEvents named: eventsSymbol ]. 
	^eventsSubscriber
]

{ #category : #'component accessing' }
MolRandomReceiverImpl >> getTimeTravelServicesProvider [
	| servicesSymbol servicesProvider itf |

	itf := TimeTravelServices.
	servicesSymbol := self servicesProviders at: itf ifAbsent: [nil].
	(servicesSymbol isNil or:[servicesSymbol isSymbol not]) ifTrue: [ ^ MolNotFoundServicesProvider new interface: itf name: nil ].

	servicesProvider := MolComponentManager default locatorServices searchServicesProviderFor: TimeTravelServices named: servicesSymbol.
	^servicesProvider
]

{ #category : #printing }
MolRandomReceiverImpl >> printRandomIntegerSmallerThan: anInteger [

	self text:
		(Random new nextIntegerBetween: 1 and: anInteger) asString
			asRopedText.
			
	"--------------------------Time Travel--------------------------"
	(MolUtils instanceOf: MolTimeTravel named: #default) ifNotNil: [ 
		self getTimeTravelServicesProvider isRestoring ifFalse: [ 
			self getTimeTravelServicesProvider
				saveEvent: #printRandomIntegerSmallerThan:
				performBy: self
				withParameters: { anInteger } ] ]
	"---------------------------------------------------------------"
]