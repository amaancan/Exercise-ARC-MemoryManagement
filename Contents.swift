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
    
    class User {
        var name: String
        
        init(name: String) {
            self.name = name
            print("User \(name) is initialized")
        }
        
        deinit {
            
            print("User \(name) is being deallocated") // NO DIRECT HOOKS (e.g. ViewDidLoad) into allocation and deallocation, you can use print statements in init and deinit as a PROXY for monitoring those processes
        }
        
        private(set) var phones: [Phone] = []
        
        // clients are forced to use add(phone:) - ensures that correct owner is set when you add Phone to User
        func add(phone: Phone) {
            phones.append(phone)
            phone.owner = self
        }
        
    }
    
    do { // Add a scope --> the object is being deinitialized at the end of the scope.
        let user1 = User(name: "John")
    }
    
    
    // E.g. Strong reference cycle = memory leak: two objects are no longer required, but each reference one another --> ARC = 1 --> deallocation, of both objects, can never occur.
    class Phone {
        let model: String
        
        /* *** WEAK REFERENCES:
         1) are always declared as optional types: can be nil when it's ARC = 0
         2) must be 'var' since can change to nil */
        weak var owner: User? // weak ref: Phone --> User : avoids retain cycle
        
        init(model: String) {
            self.model = model
            print("Phone \(model) is initialized")
        }
        
        deinit {
            print("Phone \(model) is being deallocated")
        }
    }
    
    
    do {
        let user2 = User(name: "Tina")
        let iPhone = Phone(model: "iPhone 6s Plus")
        user2.add(phone: iPhone) // retain cycle since both objs referencing ea. other
    }
    
    /* UNOWNED REFERENCES:
     Never optional: If you try to access an unowned property that refers to a deinitialized object, you will trigger a runtime error comparable to force unwrapping a nil optional type!  */
    
    
}

