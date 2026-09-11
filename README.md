# Design Patterns in ABAP

A collection of the classic [Gang of Four](https://en.wikipedia.org/wiki/Design_Patterns) (GoF) design patterns, each implemented as a standalone, runnable ABAP report. Every file is self-contained: paste it into SE38 / ADT, activate, and run — the `START-OF-SELECTION` block at the bottom demonstrates the pattern in action via `cl_demo_output`.

## Style

All reports follow modern ABAP (7.40+) conventions:

- Plain, descriptive names — no Hungarian-notation prefixes (`lo_`, `iv_`, `rv_`, ...)
- `NEW #( )` inline instance creation instead of `CREATE OBJECT`
- `IS BOUND` / `IS NOT BOUND` for object reference checks
- `cl_demo_output` for demo output instead of `WRITE`
- An ABAP Doc header on every file explaining the pattern's **intent** and **how that specific file implements it**

Two files (`zdp_abstractfactory2.abap`, `zdp_composite2.abap`) are currently empty placeholders left over from the original repo.

## Patterns

### Creational
Patterns concerned with object creation — abstracting away *how* objects get instantiated so the rest of the code doesn't depend on concrete classes.

| Pattern | Intent | File |
|---|---|---|
| **Singleton** | Ensure a class has only one instance, and provide a single global point of access to it. | [`zdp_singleton.abap`](zdp_singleton.abap) |
| **Singleton Factory** | Ensure a class has only one instance and provide a global point of access to it, and let that single instance decide which concrete class to instantiate for a requested type, so clients create products without naming their classes. | [`zdp_singletonfactory.abap`](zdp_singletonfactory.abap) |
| **Factory Method** | Define an interface for creating an object, but let subclasses decide which class to instantiate. Factory Method lets a class defer instantiation to subclasses. | [`zdp_factorymethod.abap`](zdp_factorymethod.abap) · [variant 2](zdp_factorymethod2.abap) · [variant 3](zdp_factorymethod3.abap) |
| **Abstract Factory** | Provide an interface for creating families of related or dependent objects without specifying their concrete classes. | [`zdp_abstractfactory.abap`](zdp_abstractfactory.abap) |
| **Builder** | Separate the construction of a complex object from its representation, so that the same construction process can create different representations. | [`zdp_builder.abap`](zdp_builder.abap) |
| **Prototype** | Specify the kinds of objects to create using a prototypical instance, and create new objects by copying that prototype. | [`zdp_prototype.abap`](zdp_prototype.abap) |

### Structural
Patterns concerned with how classes and objects are composed into larger structures, while keeping those structures flexible and efficient.

| Pattern | Intent | File |
|---|---|---|
| **Adapter** | Convert the interface of a class into another interface clients expect. Adapter lets classes work together that could not otherwise because of incompatible interfaces. | [`zdp_adapter.abap`](zdp_adapter.abap) |
| **Bridge** | Decouple an abstraction from its implementation so that the two can vary independently. | [`zdp_bridge.abap`](zdp_bridge.abap) |
| **Composite** | Compose objects into tree structures to represent part-whole hierarchies. Composite lets clients treat individual objects and compositions of objects uniformly. | [`zdp_composite.abap`](zdp_composite.abap) |
| **Decorator** | Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality. | [`zdp_decorator.abap`](zdp_decorator.abap) |
| **Facade** | Provide a unified interface to a set of interfaces in a subsystem. Facade defines a higher-level interface that makes the subsystem easier to use. | [`zdp_facade.abap`](zdp_facade.abap) |
| **Flyweight** | Use sharing to support large numbers of fine-grained objects efficiently, by keeping the state they have in common inside the shared object and passing the rest in. | [`zdp_flyweight.abap`](zdp_flyweight.abap) |
| **Proxy** | Provide a surrogate or placeholder for another object to control access to it. | [`zdp_proxy.abap`](zdp_proxy.abap) |

### Behavioral
Patterns concerned with how objects communicate and distribute responsibility — algorithms and the assignment of behaviour between objects.

| Pattern | Intent | File |
|---|---|---|
| **Chain of Responsibility** | Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it. | [`zdp_chainofresp.abap`](zdp_chainofresp.abap) |
| **Command** | Encapsulate a request as an object, thereby letting you parameterise clients with different requests, queue or log requests, and support undoable operations. | [`zdp_command.abap`](zdp_command.abap) |
| **Interpreter** | Given a language, define a representation for its grammar along with an interpreter that uses the representation to interpret sentences in the language. | [`zdp_interpreter.abap`](zdp_interpreter.abap) |
| **Iterator** | Provide a way to access the elements of an aggregate object sequentially without exposing its underlying representation. | [`zdp_iterator.abap`](zdp_iterator.abap) |
| **Mediator** | Define an object that encapsulates how a set of objects interact. Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary their interaction independently. | [`zdp_mediator.abap`](zdp_mediator.abap) |
| **Memento** | Without violating encapsulation, capture and externalise an object's internal state so that the object can be restored to this state later. | [`zdp_memento.abap`](zdp_memento.abap) |
| **Observer** | Define a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically. | [`zdp_observer.abap`](zdp_observer.abap) |
| **State** | Allow an object to alter its behaviour when its internal state changes. The object will appear to change its class. | [`zdp_state.abap`](zdp_state.abap) · [variant 2 (bank account example)](zdp_state2.abap) |
| **Strategy** | Define a family of algorithms, encapsulate each one, and make them interchangeable. Strategy lets the algorithm vary independently from the clients that use it. | [`zdp_strategy.abap`](zdp_strategy.abap) |
| **Template Method** | Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template Method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure. | [`zdp_templatemethod.abap`](zdp_templatemethod.abap) |
| **Visitor** | Represent an operation to be performed on the elements of an object structure. Visitor lets you define a new operation without changing the classes of the elements on which it operates. | [`zdp_visitor.abap`](zdp_visitor.abap) |

## Running an example

1. Copy a file's contents into a new report in SE38 or ADT (Eclipse), using the same name as the `REPORT` statement at the top of the file (e.g. `ZDP_SINGLETON`).
2. Activate and run (F8).
3. The demo output explains what the pattern is doing at each step.

## Contributing

Found a bug, or want to add a pattern that isn't here yet? PRs welcome — one pattern per PR keeps review simple.
