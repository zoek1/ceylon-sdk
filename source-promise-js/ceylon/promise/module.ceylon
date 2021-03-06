"Support for promises. If an operation cannot return a value 
 immediately without blocking, it may instead return a 
 _promise_ of the value. A promise is an object that 
 represents the return value or the thrown exception that 
 the operation eventually produces. Such an operation is
 sometimes called a _long-running operation_.
 
 This module provides following abstractions:
 
 - The [[Completable]] interface abstracts objects which
   promise one or more values, accommodating the possibility
   of failure.
 - The [[Term]] interface abstracts `Completable`s that may
   be combined to form a compound promise that produces 
   multiple values.
 - The [[Promise]] class, a `Completable` that produces a 
   single value, or fails.
 - The [[Deferred]] class, providing support for operations
   which return instances of the `Promise` interface.
 - The [[Future]] class, providing support for clients who
   wish to block which awaiting a `Promise`. 
 
 ## Promises
 
 A [[Promise]] exists in one of three states:
 
 - In the _promised_ state, the operation has not yet 
   terminated.
 - In the _fulfilled_ state, the operation has produced
   a value.
 - In the _rejected_ state, the operation has terminated 
   without producing a value. This situation is represented
   as an [[exception|Throwable]].
 
 The method [[Promise.onComplete]] allows interested 
 parties to be notified when the promise makes a 
 transition from the _promised_ state to the _fulfilled_ or 
 the _rejected_ state:
 
     Promise<Document> promise = queryDocumentById(id);
     promise.onComplete {
         (d) => print(\"Got the document: \" + d.title);
         (e) => print(\"Document was not received: \" + e.message);
     };
 
 The first function is called the `onFulfilled` callback and 
 the second function is called the `onRejected` callback. 
 The `onRejected` function is always optional. 
 
 ## Returning promises
 
 A [[Deferred]] object is a factory that provides an 
 instance of the `Promise` class and manages its lifecycle,
 providing operations to force its transition to a 
 _fulfilled_ or _rejected_ state.
 
 The instance of `Deferred` should remain private to the 
 long-running operation, only the `Promise` should be
 exposed to the caller.

 The `Promise` of a deferred can be retrieved from its 
 [[promise|Deferred.promise]] field:
 
     value deferred = Deferred<String>();
     return deferred.promise;
 
 The `Deferred` object implements the [[Resolver]] interface 
 which provides two methods for controlling the state of the 
 promise:
 
 - [[fulfill()|Resolver.fulfill]] fulfills the promise with 
   a _value_, and
 - [[reject()|Resolver.reject]] rejects the promise with a
   _reason_ of type [[Throwable]].
 
 For example:
 
     value deferred = Deferred<String>();
     void doOperation() {
         try {
             String val = getValue();
             deferred.fulfill(val);
         }
         catch (Throwable e) {
             deferred.reject(e);
         }
     }
 
 ## Chaining promises
 
 When composition is needed the method [[Completable.compose]]
 should be used instead of the [[Completable.onComplete]]
 method. 
 
 When invoking the [[Completable.compose]] method the 
 `onFulfilled` and `onRejected` callbacks can return a value. 
 The `compose()` method returns a new promise that will be 
 fulfilled with the value of the callback. This promise will 
 be rejected if the callback invocation fails.
 
 For example:
 
     Promise<Integer> promiseOfInteger = promiseOfInteger();
     Promise<String> promiseOfString = promiseOfInteger.compose((i) => i.string);
     promiseOfString.compose((s) => print(\"Completed with \" + s));
 
 Or, more concisely:
 
     promiseOfInteger()
         .compose((i) => i.string)
         .compose((s) => print(\"Completed with \" + s));
 
 ## Composing promises
 
 Promises can be composed into a single promise that is 
 fulfilled when every one of the individual composed 
 promises is fulfilled. If one of the promise is rejected 
 then the composed promise is rejected.
 
     Promise<String> promiseOfInteger = promiseOfString();
     Promise<Integer> promiseOfString = promiseOfInteger();
     (promiseOfInteger and promiseOfString).onCompletion {
         (i, s) => print(\"All fulfilled\");
         (e) => print(\"One failed\");
     };
 
 Notice that:
 
 - The order of the parameters in the callback is in reverse 
   order in which the corresponding promises are chained.
 - The return type of combined promise is not [[Promise]] 
   but [[Completable]].
 
 ## The `always()` method
 
 The [[always()|Completable.always]] method of a promise 
 allows a single callback to be notified when the promise is 
 fulfilled or rejected.
 
     Promise<Document> promise = queryDocumentById(id);
     promise.always {
         void (Document|Throwable result) {
             switch (result)
             case (Document) { print(\"Fulfilled\"); }
             case (Throwable) { print(\"Rejected\"); }
         };
      };
 
 `always()` is most useful for implementing a finally clause 
 in a chain of promises.
 
 ## Feeding with a promise
 
 `Deferred` can be transitioned with a promise instead of a 
 value:
 
     Deferred<String> deferred1 = getDeferred1();
     Deferred<String> deferred2 = getDeferred2();
     deferred1.fulfill(deferred2);
 
 Similarly the callback may return a promise instead of a 
 value:
 
     Deferred<String> deferred = Deferred<String>();
     promise.compose((s) => deferred.promise);
 
 ## Futures
 
 Sometimes it is convenient to block until a promise is 
 resolved. For this purpose a promise may be transformed
 into a [[Future]] via the attribute [[Promise.future]]:
 
     Promise<String> promise = getPromise();
     Future<String> future = promise.future;
     String|Throwable resolution = future.get(10k); //wait for 10 sec
 
 Keep in mind that this is not the usual way you should use 
 promises as this defeats the non blocking model. Nevertheless
 there are times when it is useful to block, for instance,
 in unit tests.
 
 ## Thread safety
 
 The implementation is thread safe and uses a non blocking 
 algorithm for maintaining the state of a `Deferred` object.
 
 ## Relationship to the A+ specification
 
 This module is loosely based upon the A+ specification,
 with the following differences:
 
 - The `then()` method is named `compose()` in Ceylon
 - The requirement that _`then()` must return before 
   `onFulfilled` or `onRejected` is called_ is not 
   implemented. Therefore the invocation occurs inside the 
   invocation of `compose()`.
 - The _Promise Resolution Procedure_ is implemented for 
   objects or promises but not for _thenables_ since that 
   would require a language with dynamic typing."
by("Julien Viet")
license("Apache Software License")
module ceylon.promise "1.1.1" {
}
