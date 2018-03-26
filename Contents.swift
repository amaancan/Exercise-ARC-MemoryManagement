// ARC & Memory Management

import UIKit

// ARC: a mechanism - an object is deinit & deallocate when obj's ref. count = 0 -->  when it is no longer required.

/* OBJECT LIFE CYCLE:
 
 1. Allocation (memory taken from stack or heap)
 2. Initialization (init code runs)
 3. Usage (the object is used)
 4. Deinitialization (deinit code runs)
 5. Deallocation (memory returned to stack or heap) */

do { // The playground itself never goes out of scope. Need to close the scope for the object to be deinitialized at the end of scope --> removed from memory.
    
    /*** PART 1 */
    class User {
        var name: String
        var subscriptions: [CarrierSubscription] = []
        
        init(name: String) {
            self.name = name
            print("User \(name) is initialized")
        }
        
        deinit {
            
            print("User \(name) is being deallocated\n") // NO DIRECT HOOKS (e.g. ViewDidLoad) into allocation and deallocation, you can use print statements in init and deinit as a PROXY for monitoring those processes
        }
        
        private(set) var phones: [Phone] = []
        
        // clients are forced to use add(phone:) - ensures that correct owner is set when you add Phone to User
        func add(phone: Phone) {
            phones.append(phone)
            phone.owner = self
        }
        
    }
    
    do { // Add a scope --> the object is being deinitialized at the end of the scope.
        print("-----STRONG REFERENCE: deinit after scope finishes-----\n")
        let user1 = User(name: "John")
    }
    
    
    
    
    /*** PART 2 - WEAK REFERENCES:
     1) are always declared as optional types: can be nil when it's ARC = 0
     2) must be 'var' since can change to nil
     ***/
    // E.g. Strong reference cycle = memory leak: two objects are no longer required, but each reference one another --> ARC = 1 --> deallocation, of both objects, can never occur.
    class Phone {
        let model: String
        weak var owner: User? // weak ref: Phone --> User : avoids retain cycle
        
        init(model: String) {
            self.model = model
            print("Phone \(model) is initialized")
        }
        
        deinit {
            print("Phone \(model) is being deallocated\n")
        }
        
        // Carrier properties and methods
        var carrierSubscription: CarrierSubscription?
        
        func provision(carrierSubscription: CarrierSubscription) {
            self.carrierSubscription = carrierSubscription
        }
        
        func decommission() {
            self.carrierSubscription = nil
        }
    }
    
    do {
        print("-----WEAK REFERNCE: deinit after scope finishes-----\n")
        let user2 = User(name: "Tina")
        let iPhone = Phone(model: "iPhone 6s Plus")
        user2.add(phone: iPhone) // retain cycle since both objs referencing ea. other
    }
    
    
    
    
    /*** PART 3 - UNOWNED REFERENCES:
     - Never optional: If you try to access an unowned property that refers to a deinitialized object, you will trigger a runtime error comparable to force unwrapping a nil optional type!
     - can be 'var' or 'let'
     ***/
    class CarrierSubscription {
        let name: String
        let countryCode: String
        let number: String
        unowned let user: User
        // Contextually: it doesn't make sense for a subscription obj to exist w/o a user --> can't do 'weak var user: User?' since user can be nil.
        // Technically: *** if using unowned, NEED TO make sure at the time/scope of accessing that object, it won't be nil/deinit, otherwise ERROR! In this case it deinits outside of 'do' scope and we access don't access the unowned obj outside of 'do' scope, so we're good.
        
        // TODO: Q - is context the only determining factor when picking between weak vs. unowned?
        
        init(name: String, countryCode: String, number: String, user: User) {
            self.name = name
            self.countryCode = countryCode
            self.number = number
            self.user = user
            user.subscriptions.append(self)
            print("CarrierSubscription \(name) is initialized")
        }
        
        deinit {
            print("CarrierSubscription \(name) is being deallocated\n")
        }
        
        // 'lazy' because it’s using self.countryCode and self.number, which aren’t available until after the initializer runs
        lazy var completePhoneNumber: () -> String = {
            self.countryCode + " " + self.number
        }
    }
    
    do {
        print("-----UNOWNED REFERNCE: deinit after scope finishes-----\n")
        let user3 = User(name: "Bill")
        let iPhone2 = Phone(model: "iPhone 7S Plus")
        user3.add(phone: iPhone2)
        let subscription1 = CarrierSubscription(name: "Telus", countryCode: "0032", number: "31415926", user: user3)
        iPhone2.provision(carrierSubscription: subscription1)
        print("Complete phone number is:", subscription1.completePhoneNumber())

    }
    
    /*** PART 4 - REFERENCE CYCLES WTIH CLOSURES:
     
     ***/
    class WWDCGreeting {
        let who: String
        
        init(who: String) {
            self.who = who
        }
        
        lazy var greetingMaker: () -> String = {
            [weak self] in
            guard let strongSelf = self else {
                return "No greeting available."
            }
            return "Hello \(strongSelf.who)."
        }
    }
    
    let greetingMaker: () -> String
    
    do {
        let mermaid = WWDCGreeting(who: "caffinated mermaid")
        greetingMaker = mermaid.greetingMaker
    }
    
    greetingMaker()
    
    //The variable x is in the capture list, so a copy of x is made at the point the closure is defined. It is said to be captured by value. On the other hand, y is not in the capture list, and is instead captured by reference. This means that when the closure runs, y will be whatever it is at that point, rather than at the point of capture.
    
    //This adds [unowned self] to the capture list for the closure. It means that self is captured as an unowned reference instead of a strong reference.
    
    //Here, newID is an unowned copy of self. Outside the closure’s scope, self keeps its original meaning. In the short form, which you used above, a new self variable is created which shadows the existing self variable just for the closure’s scope.
    
    //In your code, the relationship between self and the completePhoneNumber closure is unowned. If you are sure that a referenced object from a closure will never deallocate, you can use unowned. If it does deallocate, you are in trouble.
    
    // This example may seem contrived, but it can easily happen in real life such as when you use closures to run something much later, such as after an asynchronous network call has finished.
}

