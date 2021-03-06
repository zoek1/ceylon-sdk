"A promise represents a value that may not be available yet. 
 The primary method for interacting with a promise is its 
 [[compose]] method. A promise is a [[Completable]] element
 restricted to a single value."
by("Julien Viet")
shared abstract class Promise<out Value>() 
        satisfies Term<Value,[Value]> {
    
    "The context of this promise"
    shared formal ExecutionContext context;
    
    // todo optimize that and instead implement a Promise
    variable Conjunction<Value,Value,[]>? conjunction = null;
    
    function conj() {
        if (exists c = conjunction) {
            return c;
        } else {
            value valuePromise = context.fulfilledPromise([]);
            return conjunction = Conjunction(this, valuePromise);
        }
    }
    
    shared actual 
    Term<Value|Other,Tuple<Value|Other,Other,[Value]>> 
            and<Other>(Promise<Other> other) 
            => conj().and(other);
    
    promise => conj().promise;
    
}
