# Design Patterns in ABAP

![ABAP](https://img.shields.io/badge/language-ABAP-6a2c70?style=flat-square)
![ABAP Version](https://img.shields.io/badge/ABAP-7.40%2B-orange?style=flat-square)
![Patterns](https://img.shields.io/badge/patterns-25%20%2F%2023%20GoF-blue?style=flat-square)
![Level](https://img.shields.io/badge/level-beginner%20friendly-brightgreen?style=flat-square)

A hands-on introduction to the classic [Gang of Four](https://en.wikipedia.org/wiki/Design_Patterns) (GoF) design patterns, taught through runnable ABAP code. Every pattern lives in its own self-contained report — paste it into SE38 or ADT, activate, run, and watch it work.

> **Who this is for:** someone comfortable writing ABAP but new to object-oriented design. If terms like *interface*, *polymorphism*, or *abstract class* still feel fuzzy, read the [OOP primer](#new-to-oop-start-here) first — everything after it assumes you have.

<br>

## 🗺️ Pattern map

A bird's-eye view of everything in this repo. Click any name to jump to its full write-up, or the file icon to go straight to the code.

### 🏗️ Creational — *how objects get created*

| Pattern | Difficulty | One-liner | Code |
|---|:---:|---|:---:|
| [Singleton](#singleton) | 🟢 Beginner | Exactly one instance, one global access point | [📄](zdp_singleton.abap) |
| [Singleton Factory](#singleton-factory) | 🟡 Intermediate | A singleton that also decides *what* to build | [📄](zdp_singletonfactory.abap) |
| [Factory Method](#factory-method) | 🟢 Beginner | Subclasses decide which concrete class to create | [📄](zdp_factorymethod.abap) |
| [Abstract Factory](#abstract-factory) | 🟡 Intermediate | Create a whole family of matching objects | [📄](zdp_abstractfactory.abap) |
| [Builder](#builder) | 🟢 Beginner | Construct a complex object step by step | [📄](zdp_builder.abap) |
| [Prototype](#prototype) | 🟢 Beginner | Clone an existing object instead of building new | [📄](zdp_prototype.abap) |

### 🧱 Structural — *how objects are composed*

| Pattern | Difficulty | One-liner | Code |
|---|:---:|---|:---:|
| [Adapter](#adapter) | 🟢 Beginner | Make an incompatible interface fit | [📄](zdp_adapter.abap) |
| [Bridge](#bridge) | 🟡 Intermediate | Decouple an abstraction from its implementation | [📄](zdp_bridge.abap) |
| [Composite](#composite) | 🟡 Intermediate | Treat a single item and a tree of items the same | [📄](zdp_composite.abap) |
| [Decorator](#decorator) | 🟡 Intermediate | Add behaviour to one object at runtime | [📄](zdp_decorator.abap) |
| [Facade](#facade) | 🟢 Beginner | One simple front door to a complex subsystem | [📄](zdp_facade.abap) |
| [Flyweight](#flyweight) | 🔴 Advanced | Share state across huge numbers of objects | [📄](zdp_flyweight.abap) |
| [Proxy](#proxy) | 🟢 Beginner | A stand-in that controls access to the real object | [📄](zdp_proxy.abap) |

### 🎭 Behavioral — *how objects communicate*

| Pattern | Difficulty | One-liner | Code |
|---|:---:|---|:---:|
| [Chain of Responsibility](#chain-of-responsibility) | 🟡 Intermediate | Pass a request along a chain until someone handles it | [📄](zdp_chainofresp.abap) |
| [Command](#command) | 🟢 Beginner | Turn a request into an object you can queue or undo | [📄](zdp_command.abap) |
| [Interpreter](#interpreter) | 🔴 Advanced | Evaluate sentences in a small custom grammar | [📄](zdp_interpreter.abap) |
| [Iterator](#iterator) | 🟢 Beginner | Step through a collection without exposing its internals | [📄](zdp_iterator.abap) |
| [Mediator](#mediator) | 🟡 Intermediate | Route communication through one coordinator | [📄](zdp_mediator.abap) |
| [Memento](#memento) | 🟡 Intermediate | Save and restore state without breaking encapsulation | [📄](zdp_memento.abap) |
| [Observer](#observer) | 🟢 Beginner | Notify many dependents when one object changes | [📄](zdp_observer.abap) |
| [State](#state) | 🟡 Intermediate | Change behaviour as internal state changes | [📄](zdp_state.abap) |
| [Strategy](#strategy) | 🟢 Beginner | Swap interchangeable algorithms at runtime | [📄](zdp_strategy.abap) |
| [Template Method](#template-method) | 🟢 Beginner | Fix the algorithm's skeleton, let subclasses vary steps | [📄](zdp_templatemethod.abap) |
| [Visitor](#visitor) | 🔴 Advanced | Add new operations without touching existing classes | [📄](zdp_visitor.abap) |

<sub>🟢 Beginner &nbsp;·&nbsp; 🟡 Intermediate &nbsp;·&nbsp; 🔴 Advanced — a rough read on how much OOP background each pattern assumes, not on how useful it is.</sub>

<br>

## Table of Contents

- [New to OOP? Start here](#new-to-oop-start-here)
  - [Objects and classes](#objects-and-classes)
  - [Encapsulation](#encapsulation)
  - [Inheritance](#inheritance)
  - [Interfaces and polymorphism](#interfaces-and-polymorphism)
  - [Why design patterns exist](#why-design-patterns-exist)
- [The three families of pattern](#the-three-families-of-pattern)
- [How to run an example](#how-to-run-an-example)
- [Code style used in this repo](#code-style-used-in-this-repo)
- [Creational Patterns](#creational-patterns)
  - [Singleton](#singleton) · [Singleton Factory](#singleton-factory) · [Factory Method](#factory-method) · [Abstract Factory](#abstract-factory) · [Builder](#builder) · [Prototype](#prototype)
- [Structural Patterns](#structural-patterns)
  - [Adapter](#adapter) · [Bridge](#bridge) · [Composite](#composite) · [Decorator](#decorator) · [Facade](#facade) · [Flyweight](#flyweight) · [Proxy](#proxy)
- [Behavioral Patterns](#behavioral-patterns)
  - [Chain of Responsibility](#chain-of-responsibility) · [Command](#command) · [Interpreter](#interpreter) · [Iterator](#iterator) · [Mediator](#mediator) · [Memento](#memento) · [Observer](#observer) · [State](#state) · [Strategy](#strategy) · [Template Method](#template-method) · [Visitor](#visitor)
- [Which pattern do I actually need?](#which-pattern-do-i-actually-need)
- [Further reading](#further-reading)

---

## New to OOP? Start here

Design patterns are solutions to recurring problems in **object-oriented** code. Before any of them will make sense, you need four ideas solid: objects/classes, encapsulation, inheritance, and polymorphism. Already know these? Skip to [The three families of pattern](#the-three-families-of-pattern).

### Objects and classes

A **class** is a blueprint. It describes what data something holds (its *attributes*) and what it can do (its *methods*). An **object** (or *instance*) is one concrete thing built from that blueprint.

```abap
CLASS car DEFINITION.
  PUBLIC SECTION.
    DATA speed TYPE i.
    METHODS accelerate.
ENDCLASS.

DATA(my_car) = NEW car( ).   " my_car is an object -- one instance of the car class
my_car->accelerate( ).
```

One class, many objects: `NEW car( )` can be called as many times as you like, and each call gives you an independent object with its own `speed`.

### Encapsulation

Encapsulation means an object controls its own data — outside code interacts with it only through the methods it chooses to expose, never by poking at its internals directly. In the `car` example, if `speed` should never go negative, hiding it in `PRIVATE SECTION` and only allowing changes through a `brake( )` method that checks the value is what enforces that rule.

> 💡 **Why this matters for patterns:** so many patterns in this repo mark constructors `PRIVATE` or wrap state behind getter methods. It's not decoration — it's the object protecting its own correctness.

### Inheritance

Inheritance lets one class (a *subclass*) reuse and specialise another (its *superclass*).

```abap
CLASS vehicle DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS move ABSTRACT.
ENDCLASS.

CLASS car DEFINITION INHERITING FROM vehicle.
  PUBLIC SECTION.
    METHODS move REDEFINITION.
ENDCLASS.
```

`car` automatically has everything `vehicle` has, and `REDEFINITION` lets it provide its own version of `move`. An `ABSTRACT` class like `vehicle` above can't be instantiated directly (`NEW vehicle( )` is illegal) — it exists purely to be inherited from and to guarantee that every subclass implements `move`.

### Interfaces and polymorphism

An **interface** is a pure contract: a list of method signatures with no implementation. Any class can declare `INTERFACES my_interface` and must then implement every method that interface promises.

```abap
INTERFACE shape.
  METHODS area RETURNING VALUE(result) TYPE f.
ENDINTERFACE.

CLASS circle DEFINITION.
  PUBLIC SECTION.
    INTERFACES shape.
ENDCLASS.

CLASS square DEFINITION.
  PUBLIC SECTION.
    INTERFACES shape.
ENDCLASS.
```

**Polymorphism** is the payoff: code that only knows about `shape` can hold a reference to *either* a `circle` or a `square` and call `area( )` on it, without caring which one it actually is.

```abap
DATA(current_shape) = get_some_shape( ).   " returns REF TO shape -- caller doesn't know or care
cl_demo_output=>write( current_shape->area( ) ).
```

> 💡 **The idea behind almost every pattern in this repo:** write code against an interface or abstract type instead of a concrete class. When a pattern is described as "decoupling" two things, it almost always means: introduce an interface between them, so neither side needs to know the other's concrete class.

### Why design patterns exist

Left unchecked, object-oriented code tends to grow two problems as it gets bigger:

1. **Classes that know too much about each other.** If class `A` directly creates and calls concrete class `B`, then `A` cannot work with anything except `B` — a `C` or `D` alternative means rewriting `A`.
2. **Duplicated structure with no name.** Two developers solve the same shape of problem — "I need exactly one of these, shared everywhere" or "I need to undo this action later" — in two different, incompatible ways, because there's no shared vocabulary for the solution.

The [Gang of Four](https://en.wikipedia.org/wiki/Design_Patterns) book (1994) catalogued 23 solutions to these recurring problems and gave each one a name. That name is the real value: once you and a teammate both know what "Observer" means, you can say "just make it an Observer" instead of re-explaining the whole mechanism. This repo implements all 23, plus one extra combination pattern (Singleton Factory), in ABAP.

**[⬆ Back to top](#table-of-contents)**

---

## The three families of pattern

GoF patterns fall into three groups, based on **what problem they solve**:

| Category | Solves | Ask yourself |
|---|---|---|
| 🏗️ **Creational** | *How* objects get created | "Do I need control over object creation itself — limiting instances, hiding which concrete class gets built, or separating a complex build process from the object it produces?" |
| 🧱 **Structural** | How classes and objects are *composed* into larger structures | "Do I need to combine or wrap existing objects/classes into a bigger structure, without making that structure fragile or hard to change?" |
| 🎭 **Behavioral** | How objects *communicate* and share responsibility | "Do I need to manage how objects talk to each other, or how an algorithm's steps are distributed and made interchangeable?" |

## How to run an example

1. Open the `.abap` file you want to try.
2. Create a new report in SE38 or ADT (Eclipse) using the exact name in the file's `REPORT` statement (e.g. `zdp_singleton.abap` → report `ZDP_SINGLETON`).
3. Paste in the full contents, activate, and run (`F8`).
4. Read the output — each demo prints a running commentary of what the pattern is doing at each step, not just a final result.

> Each file's own header comment (the `*&---` block near the top) explains that specific implementation's classes and how they map onto the pattern's roles — read it alongside this README, not instead of it.

## Code style used in this repo

All reports follow modern ABAP (7.40+) conventions, applied consistently across every file:

| Convention | Instead of |
|---|---|
| Plain, descriptive names | Hungarian-notation prefixes (`lo_`, `iv_`, `rv_`, ...) |
| `NEW #( )` inline instance creation | `CREATE OBJECT` |
| `IS BOUND` / `IS NOT BOUND` | `IS INITIAL` on object references |
| `cl_demo_output` for demo output | `WRITE` |
| ABAP Doc header on every file | undocumented reports |

> ⚠️ Two files (`zdp_abstractfactory2.abap`, `zdp_composite2.abap`) are currently empty placeholders carried over from the original repo.

**[⬆ Back to top](#table-of-contents)**

---

## Creational Patterns

🏗️ Creational patterns take the decision of *which class to instantiate, and how* out of your regular business logic and give it a name and a home. Without them, "which concrete class do I build here?" tends to get answered by scattering `NEW SomeConcreteClass( )` calls throughout the codebase — which means every one of those call sites has to change if you ever need to build something differently.

### Singleton
`🟢 Beginner`

**Problem:** Some things genuinely should only exist once in a running program — a configuration object, a connection pool, a logger. If any code can call `NEW` on the class, nothing stops five different parts of the program from creating five separate "the one" configuration objects, each with different values.

**Solution:** Make the constructor private so `NEW` is impossible from outside the class, and expose one static method (`get_instance( )`) that creates the object on the first call and returns that same cached object on every call after.

> 🧭 **Analogy:** A country has exactly one government at a time. You don't "create a new government" every time you need to pass a law — you go through the one that already exists.

**Structure:** One class. A private static field holds the instance; a public static method returns it, creating it lazily on first access.

**When to use it:** Genuinely global, shared state — and sparingly. Overused, Singleton becomes a way to smuggle global variables into an OO program, which brings back the exact coupling problems OO was meant to avoid. Prefer passing a shared object explicitly (dependency injection) where you can; reach for Singleton when that's genuinely impractical.

**Trade-offs:** Easy to test in isolation, hard to test *with* — a singleton's state persists across test cases unless you explicitly reset it, which is a classic source of flaky tests.

📄 **Code:** [`zdp_singleton.abap`](zdp_singleton.abap)

### Singleton Factory
`🟡 Intermediate`

**Problem:** You want both guarantees at once — exactly one factory object in the whole program, and that factory should decide which concrete product class to build based on a runtime value, so calling code never names a concrete class itself.

**Solution:** Combine the two patterns directly. The factory class is itself a Singleton (private constructor, `get_instance( )`); its instance method is a Factory Method that switches on some input (a "channel" or "type" key in this repo's example) and returns the right concrete product, typed only as a shared interface.

> 🧭 **Analogy:** A single postal sorting office (there's only one, for your whole region) that reads the destination on each parcel and routes it to the right delivery van — the sender never picks the van themselves.

**When to use it:** When object creation is both expensive/stateful enough to warrant a single shared owner, *and* varied enough that a plain constructor call at every use site would be repetitive or fragile to change.

📄 **Code:** [`zdp_singletonfactory.abap`](zdp_singletonfactory.abap)

### Factory Method
`🟢 Beginner`

**Problem:** A class needs to create objects, but it shouldn't have to know the concrete type of what it's creating — that decision belongs to whoever specialises it later.

**Solution:** Define an abstract (or interface) creation method on a base class. Each subclass overrides that method to return its own concrete product. The rest of the base class's logic is written entirely against the abstract product type and never needs to change.

> 🧭 **Analogy:** A logistics company has a generic "deliver package" process, but a `RoadDelivery` branch creates trucks and an `AirDelivery` branch creates planes. The shared delivery process doesn't change — only which vehicle gets built does.

**Structure:** An abstract `Creator` declares the factory method; concrete creator subclasses each implement it to return a specific concrete `Product`.

**When to use it:** When a class can't anticipate which concrete class of object it needs to create, and you want subclasses to specify that.

> 📦 **Three variants in this repo**, showing the pattern from slightly different angles: an abstract-class creator, an interface-based creator, and a document/pages worked example.

📄 **Code:** [`zdp_factorymethod.abap`](zdp_factorymethod.abap) · [variant 2](zdp_factorymethod2.abap) · [variant 3](zdp_factorymethod3.abap)

### Abstract Factory
`🟡 Intermediate`

**Problem:** Factory Method gives you one product family member at a time. Sometimes you need to create a whole *family* of related objects together, and guarantee they're all mutually compatible — e.g. a UI toolkit that must produce a matching button, checkbox, and scrollbar for whichever operating system it's running on, never a Windows button next to a macOS checkbox.

**Solution:** Define one abstract factory interface with a creation method *per product type* in the family. Each concrete factory implementation (one per family/variant) implements all of them consistently.

> 🧭 **Analogy:** A furniture manufacturer with separate "Victorian" and "Modern" product lines. Ordering a Victorian factory gets you a Victorian chair, table, and sofa together — you can't accidentally mix a Victorian chair with a Modern sofa, because you always go through one factory or the other.

**Structure:** Multiple abstract product interfaces (`Chair`, `Table`); one abstract factory interface with a create method per product; one concrete factory class per family, each producing the whole matching set.

**When to use it:** When your system needs to stay independent of how its objects are created, composed, and represented, and you need to enforce that certain products are always used together.

**🔀 vs. Factory Method:** Factory Method is about *one* product with subclass-controlled creation. Abstract Factory is about creating a whole *family* of related products consistently — it's often implemented using several Factory Methods internally.

📄 **Code:** [`zdp_abstractfactory.abap`](zdp_abstractfactory.abap)

### Builder
`🟢 Beginner`

**Problem:** Some objects require many optional or interdependent construction steps, and a single giant constructor with a dozen parameters becomes unreadable and error-prone (which position was the third boolean again?).

**Solution:** Move the step-by-step construction logic into a separate `Builder` object with clearly named methods for each part (`add_topping`, `set_size`, ...), and a `build( )` method that assembles the final result. A `Director` can optionally encode common construction *recipes* so callers don't need to know the right order of steps themselves.

> 🧭 **Analogy:** Ordering a custom sandwich — you don't hand the shop one giant coded string describing every ingredient; you say "add lettuce", "add cheese", "no mayo" one instruction at a time, and then "make it" at the end.

**When to use it:** When object construction has many optional parts, or when the same step-by-step process should be able to produce different final representations.

**🔀 vs. Abstract Factory:** Abstract Factory returns a complete family of finished products in one call. Builder constructs *one* complex object incrementally, step by step, often over multiple method calls.

📄 **Code:** [`zdp_builder.abap`](zdp_builder.abap)

### Prototype
`🟢 Beginner`

**Problem:** Sometimes creating a new object is expensive (an expensive database lookup to populate it, for instance), but you already have an existing object that's almost exactly what you need.

**Solution:** Give the object a `clone( )` method that returns a copy of itself. New instances are produced by copying an existing prototype rather than by re-running expensive setup logic.

> 🧭 **Analogy:** Photocopying a filled-out form is faster than filling out a new blank one from scratch when 90% of the fields would be identical anyway.

**When to use it:** When the classes to instantiate are specified at runtime, or when creating a fresh instance is more costly than duplicating an existing, already-configured one.

📄 **Code:** [`zdp_prototype.abap`](zdp_prototype.abap)

**[⬆ Back to top](#table-of-contents)**

---

## Structural Patterns

🧱 Structural patterns are about composition: taking classes and objects — sometimes ones you don't control and can't change — and arranging them into larger structures without making the whole thing rigid or tightly coupled.

### Adapter
`🟢 Beginner`

**Problem:** You have a class with a perfectly good interface, but it's the *wrong* interface for the code that needs to use it — commonly because it's third-party code, or legacy code you can't rewrite.

**Solution:** Wrap the incompatible class in a new class that implements the interface your calling code expects, and translates each call through to the wrapped object's actual methods.

> 🧭 **Analogy:** A travel plug adapter — it doesn't change how the wall socket or the device plug work, it just sits between them so two incompatible shapes can connect.

**When to use it:** When you want to use an existing class, but its interface doesn't match what the rest of your code expects, and you can't (or shouldn't) modify that class directly.

📄 **Code:** [`zdp_adapter.abap`](zdp_adapter.abap)

### Bridge
`🟡 Intermediate`

**Problem:** An abstraction (say, "Shape") and its implementation (say, "how it's rendered on screen") can both vary independently, but inheritance alone forces you to create a new subclass for every *combination* — `RedCircle`, `BlueCircle`, `RedSquare`, `BlueSquare` — which multiplies out of control as both sides grow.

**Solution:** Split the abstraction and the implementation into two separate class hierarchies, connected by composition (the abstraction holds a reference to an implementation object) instead of inheritance. Either side can now grow independently without multiplying combinations.

> 🧭 **Analogy:** A TV remote (the abstraction) works the same regardless of TV brand (the implementation) because it talks to any TV through a shared, generic control interface — you don't need a different remote *design* for every brand.

**🔀 vs. Adapter:** Adapter is applied after the fact, to make two already-existing incompatible interfaces work together. Bridge is a design decision made up front, deliberately keeping two hierarchies separate so they can vary independently from day one.

📄 **Code:** [`zdp_bridge.abap`](zdp_bridge.abap)

### Composite
`🟡 Intermediate`

**Problem:** You have a tree of objects — folders containing files and other folders, for example — and you want calling code to treat a single leaf item and an entire branch of the tree identically, without constantly checking "is this one item, or a group?".

**Solution:** Give both the individual ("leaf") objects and the container ("composite") objects the same interface. A composite's implementation of each operation simply loops over its children and calls the same operation on each of them — which might themselves be composites, recursing naturally.

> 🧭 **Analogy:** A company org chart — asking "what's this person/team's total headcount?" works the same way whether you ask an individual contributor (answer: 1) or a department head (answer: sum of everyone under them).

**When to use it:** Whenever your data is naturally a part-whole tree, and you want client code to be able to ignore the difference between a single node and a whole subtree.

📄 **Code:** [`zdp_composite.abap`](zdp_composite.abap)

### Decorator
`🟡 Intermediate`

**Problem:** You want to add extra behaviour to an individual object at runtime — not to every instance of its class — without creating a combinatorial explosion of subclasses for every possible combination of extras (a coffee with milk, with sugar, with milk *and* sugar, ...).

**Solution:** Wrap the object in a decorator that implements the same interface, forwards calls through to the wrapped object, and adds its own behaviour before or after doing so. Decorators can be stacked, each one adding one more layer of behaviour.

> 🧭 **Analogy:** Layering clothing — a T-shirt, then a jacket, then a raincoat. Each layer wraps the one underneath and adds its own property (warmth, water resistance) without changing what's underneath.

**🔀 vs. Composite:** Composite trees combine multiple *different* children under one interface. Decorator wraps a *single* object in a chain, one layer at a time, each layer both extending and delegating to the one inside it.

📄 **Code:** [`zdp_decorator.abap`](zdp_decorator.abap)

### Facade
`🟢 Beginner`

**Problem:** A subsystem made of many interacting classes is powerful but painful to use directly — the caller has to know the correct order of calls across several objects just to do one common task.

**Solution:** Provide one simple class with a small set of high-level methods that internally coordinate the subsystem's classes correctly. Callers who just want the common case use the facade; callers who need fine control can still reach past it to the subsystem directly.

> 🧭 **Analogy:** A car's ignition button is a facade over a dozen coordinated subsystems (fuel, starter motor, spark plugs, electronics) — you press one button instead of operating each subsystem yourself.

**When to use it:** When you want to give a complex subsystem a simple, task-oriented entry point, especially at the boundary between subsystems or when wrapping a legacy system.

📄 **Code:** [`zdp_facade.abap`](zdp_facade.abap)

### Flyweight
`🔴 Advanced`

**Problem:** You need a very large number of similar objects (think: every character glyph in a large document, or every tree in a forest scene), and creating a full, independent object for each one would use far more memory than necessary — especially when most of their data is actually identical across instances.

**Solution:** Split each object's data into *intrinsic* state (shared, identical across many instances — kept inside one shared "flyweight" object) and *extrinsic* state (unique per use — passed in by the caller at the point of use, not stored in the shared object). A factory hands out the same shared flyweight object whenever the intrinsic state requested already exists.

> 🧭 **Analogy:** A print shop keeps one physical stencil per letter of the alphabet (intrinsic, shared) but applies it at a different position on the page each time (extrinsic, supplied by whoever's using it) — it doesn't cut a brand new stencil for every single letter printed.

**When to use it:** When an application needs to create a huge number of objects, most of whose state could be shared, and memory use is a real concern.

📄 **Code:** [`zdp_flyweight.abap`](zdp_flyweight.abap)

### Proxy
`🟢 Beginner`

**Problem:** You want to control access to an object — delaying its creation until it's actually needed, checking permissions before letting a call through, or adding logging — without changing the object itself or the code that uses it.

**Solution:** Create a proxy class implementing the same interface as the real object. Callers talk to the proxy exactly as if it were the real thing; the proxy decides when (and whether) to forward each call through to the real object, and can do extra work of its own around that call.

> 🧭 **Analogy:** A receptionist is a proxy for a busy executive — visitors interact with the receptionist using the same basic "I'd like to speak to someone" interface, and the receptionist decides whether, when, and how the request actually reaches the executive.

**🔀 vs. Adapter & Decorator:** All three wrap another object behind the same kind of interface, but for different reasons. Adapter changes an incompatible interface into a compatible one. Decorator adds new behaviour on top. Proxy controls *access* — same interface, same behaviour, but gatekept.

📄 **Code:** [`zdp_proxy.abap`](zdp_proxy.abap)

**[⬆ Back to top](#table-of-contents)**

---

## Behavioral Patterns

🎭 Behavioral patterns are about how responsibility is distributed and how objects communicate — algorithms, workflows, and messaging, as opposed to how objects are built (Creational) or structured (Structural).

### Chain of Responsibility
`🟡 Intermediate`

**Problem:** A request needs to be handled by one of several possible handlers, but the sender shouldn't need to know or care which one, and the set of handlers (and their order) should be easy to change.

**Solution:** Give each handler a reference to the next handler in the chain. Each handler either deals with the request itself, or passes it along to the next one. The sender just hands the request to the first handler and lets the chain sort out who deals with it.

> 🧭 **Analogy:** An expense approval process — a manager can approve small amounts, but anything over their limit automatically goes up to the next level, and so on, without the original requester needing to know the approval limits at every level.

**When to use it:** When more than one object may handle a request and the right handler isn't known in advance, or when you want to issue a request without specifying the receiver explicitly.

📄 **Code:** [`zdp_chainofresp.abap`](zdp_chainofresp.abap)

### Command
`🟢 Beginner`

**Problem:** You want to treat "an action to be performed" as a first-class thing you can store, pass around, queue, log, or undo — rather than as an immediate direct method call that's gone the instant it happens.

**Solution:** Wrap a request (an action plus the parameters it needs) in a command object with a standard `execute( )` method. The object issuing commands doesn't need to know what a command actually does — it just calls `execute( )` on whichever command it's holding. Storing executed commands enables undo/redo, logging, or queuing for later.

> 🧭 **Analogy:** A restaurant order slip — the waiter (invoker) doesn't cook, they just carry the slip (command object) to the kitchen (receiver), which knows how to actually execute it. The same slip could be queued, reprinted, or handed to a different cook.

**When to use it:** When you need to parameterise objects with an action to perform, queue or log requests, or support undoable operations.

📄 **Code:** [`zdp_command.abap`](zdp_command.abap)

### Interpreter
`🔴 Advanced`

**Problem:** You need to evaluate sentences in some small, well-defined language or grammar (a search filter syntax, a simple calculator expression, a rules engine condition) without pulling in a full parser generator.

**Solution:** Represent each grammar rule as a class with an `interpret( )` method. Complex expressions are built as a tree of these small classes (composed much like a Composite pattern), and evaluating the whole expression means calling `interpret( )` on the root, which recurses down through its children.

> 🧭 **Analogy:** A simple arithmetic expression like `3 + 4 * 2` can be represented as a small tree of "plus" and "times" objects, each of which knows how to evaluate itself and its two operands.

**When to use it:** For genuinely small, stable grammars — this pattern gets unwieldy fast for anything approaching the complexity of a real programming language, where a dedicated parser/lexer is the better tool.

📄 **Code:** [`zdp_interpreter.abap`](zdp_interpreter.abap)

### Iterator
`🟢 Beginner`

**Problem:** Code that wants to step through a collection's elements one at a time shouldn't need to know *how* that collection stores its data internally (array, tree, hash table) — but exposing that internal structure directly breaks encapsulation.

**Solution:** Provide a separate iterator object with a standard `has_next( )` / `get_next( )` (or similar) interface. The collection hands out an iterator on request; the calling code only ever talks to the iterator, never the collection's internals.

> 🧭 **Analogy:** A TV remote's channel-up button — you don't need to know how channels are stored or numbered internally, you just keep pressing "next" and get the next one.

**When to use it:** Whenever you want to traverse a collection's elements without exposing its internal representation, or need multiple independent traversals over the same collection at once.

📄 **Code:** [`zdp_iterator.abap`](zdp_iterator.abap)

### Mediator
`🟡 Intermediate`

**Problem:** A group of objects that all need to talk directly to each other ends up as a tangled web of references — every object knows about every other object, and adding one more participant means updating all of them.

**Solution:** Introduce a single mediator object that all participants talk to instead of talking to each other directly. Each participant only needs a reference to the mediator; the mediator is the only thing that needs to know about everyone.

> 🧭 **Analogy:** An air traffic control tower — pilots don't communicate plane-to-plane to coordinate landings, they all talk to the one tower, which coordinates everyone.

**🔀 vs. Facade:** Facade simplifies a one-way relationship (caller → subsystem). Mediator coordinates a *two-way*, many-to-many relationship between peers that would otherwise all reference each other directly.

📄 **Code:** [`zdp_mediator.abap`](zdp_mediator.abap)

### Memento
`🟡 Intermediate`

**Problem:** You want to be able to save an object's internal state and restore it later (undo functionality, checkpoints), without exposing that internal state to the outside world and breaking encapsulation.

**Solution:** The object itself (the "Originator") creates a Memento object containing a private snapshot of its own state — only the Originator that created a Memento can read what's inside it. A separate "Caretaker" can hold on to Mementos and hand them back later, without ever being able to look inside them.

> 🧭 **Analogy:** A video game's save file — the game itself decides what goes into a save and how to load one back; the file system storing the save file has no idea what's inside it, and doesn't need to.

**When to use it:** Whenever you need undo/rollback behaviour and want to avoid leaking an object's internals in the process.

📄 **Code:** [`zdp_memento.abap`](zdp_memento.abap)

### Observer
`🟢 Beginner`

**Problem:** When one object's state changes, other objects need to know about it and react — but you don't want the first object tightly wired to every possible thing that might care about its changes.

**Solution:** Interested objects ("observers") register themselves with the object they want to watch ("subject"). When the subject's state changes, it loops through its registered observers and notifies each one — without needing to know anything about what they actually do in response.

> 🧭 **Analogy:** A YouTube channel and its subscribers — the channel doesn't know or care who's subscribed or what they'll do with a new upload; it just notifies everyone on the list when something changes.

**When to use it:** Whenever a change to one object should trigger updates in an open-ended set of others, especially when that set can grow or shrink at runtime.

📄 **Code:** [`zdp_observer.abap`](zdp_observer.abap)

### State
`🟡 Intermediate`

**Problem:** An object's behaviour needs to change significantly depending on some internal state (e.g. an account behaves differently when overdrawn vs. in good standing), and representing that with `IF`/`CASE` statements scattered across every method becomes unmanageable as the number of states and transitions grows.

**Solution:** Give each state its own class implementing a shared interface. The context object holds a reference to its *current* state object and delegates behaviour to it. Transitioning to a new state is just swapping out which state object the context is pointing at.

> 🧭 **Analogy:** A traffic light — Red, Amber, and Green each define their own idea of "what happens next", and the light just asks its current state object what to do, rather than the light itself containing one giant nested conditional for every colour.

**🔀 vs. Strategy:** Structurally, State and Strategy look almost identical (both delegate behaviour to a swappable object behind an interface). The difference is *intent*: Strategy is chosen once by the client for a specific purpose and generally stays fixed; State is expected to change itself, driven by the object's own internal logic, as things happen.

> 📦 **Two variants in this repo**: a bare textbook version with two flip-flopping states, and a worked bank-account example where the state transition is driven by the account balance crossing a limit.

📄 **Code:** [`zdp_state.abap`](zdp_state.abap) · [variant 2 (bank account example)](zdp_state2.abap)

### Strategy
`🟢 Beginner`

**Problem:** You have several interchangeable ways to perform the same task (different sorting algorithms, different pricing rules, different payment methods), and hard-coding the choice with conditionals makes adding a new option require touching every place that conditional appears.

**Solution:** Extract each algorithm into its own class implementing a common interface. The object that needs the behaviour holds a reference to whichever strategy it's currently configured with, and calls it generically — swapping in a different strategy object changes the behaviour without touching the calling code.

> 🧭 **Analogy:** Choosing a route on a map app — walking, driving, and cycling are all different strategies for solving the same "get from A to B" request, selected independently of the app's core navigation logic.

**When to use it:** When you have many related classes that only differ in behaviour, and want to configure a class with one of several algorithms interchangeably, ideally chosen at runtime.

📄 **Code:** [`zdp_strategy.abap`](zdp_strategy.abap)

### Template Method
`🟢 Beginner`

**Problem:** Several classes need to follow the same overall multi-step process, but some individual steps genuinely differ between them, and you want to avoid duplicating the parts of the process that stay the same.

**Solution:** Define the overall algorithm once, as a sequence of method calls, in a base class method that subclasses do not override. Individual steps that vary are declared abstract (or given a default), and each subclass overrides only the steps it needs to customise.

> 🧭 **Analogy:** A recipe for "make a sandwich" always follows the same steps in the same order — add bread, add filling, add condiment, close it — but a "cheese sandwich" and a "club sandwich" subclass each fill in different specifics for the filling step.

**🔀 vs. Strategy:** Template Method uses inheritance — subclasses override individual *steps* of one fixed algorithm skeleton. Strategy uses composition — the entire algorithm is swapped out wholesale, from outside the class, as an interchangeable object.

📄 **Code:** [`zdp_templatemethod.abap`](zdp_templatemethod.abap)

### Visitor
`🔴 Advanced`

**Problem:** You need to add a new operation across a whole family of related classes, but you don't want to keep modifying every one of those classes each time you think of a new operation to support.

**Solution:** Move the operation out into a separate "visitor" object. Each element class gets one small, stable `accept( visitor )` method that calls back into the visitor, passing itself (`visitor->visit( me )`) — this is called *double dispatch*, because which `visit` overload actually runs depends on both the visitor's type and the element's type. New operations become new visitor classes; the element classes themselves rarely need to change again.

> 🧭 **Analogy:** A tax auditor "visiting" different kinds of business (retail, restaurant, freelancer) — each business type knows how to let the auditor in and hand over its records, but the actual auditing logic for each business type lives with the auditor, not duplicated inside every business.

**When to use it:** When you need to perform several unrelated operations across a stable set of classes, and adding new operations should be cheaper than adding new classes.

**Trade-offs:** Adding a *new operation* (visitor) is cheap. Adding a *new element type* is expensive — every existing visitor needs a new method to handle it. Use Visitor when your element hierarchy is stable but your operations are expected to grow.

📄 **Code:** [`zdp_visitor.abap`](zdp_visitor.abap)

**[⬆ Back to top](#table-of-contents)**

---

## Which pattern do I actually need?

A rough decision guide for when you're staring at a design problem and not sure which of the above applies:

| If you're thinking... | Reach for |
|---|---|
| "I need exactly one of these, shared everywhere." | [Singleton](#singleton) |
| "I don't want calling code to know which concrete class it's creating." | [Factory Method](#factory-method) (one product) or [Abstract Factory](#abstract-factory) (a matching family) |
| "This object takes many optional steps to build." | [Builder](#builder) |
| "Making a new one from scratch is expensive; copying an existing one is cheap." | [Prototype](#prototype) |
| "I have the wrong interface for this class and can't change it." | [Adapter](#adapter) |
| "This abstraction and its implementation both need to vary independently." | [Bridge](#bridge) |
| "I have a part-whole tree and want to treat single items and whole branches the same." | [Composite](#composite) |
| "I need to add extra behaviour to one specific object at runtime." | [Decorator](#decorator) |
| "This subsystem is powerful but painful to use directly." | [Facade](#facade) |
| "I need huge numbers of mostly-identical objects without running out of memory." | [Flyweight](#flyweight) |
| "I need to control or delay access to an object." | [Proxy](#proxy) |
| "A request should be handled by whichever of several handlers is appropriate." | [Chain of Responsibility](#chain-of-responsibility) |
| "I want to treat an action as an object I can queue, log, or undo." | [Command](#command) |
| "I need to evaluate sentences in a small custom grammar." | [Interpreter](#interpreter) |
| "I want to step through a collection without exposing how it's stored." | [Iterator](#iterator) |
| "A group of objects all need to coordinate, but shouldn't reference each other directly." | [Mediator](#mediator) |
| "I need undo/rollback without exposing an object's internals." | [Memento](#memento) |
| "Many objects need to react whenever one particular object changes." | [Observer](#observer) |
| "This object's behaviour should change based on its own internal state." | [State](#state) |
| "I need to swap between interchangeable algorithms, chosen by the client." | [Strategy](#strategy) |
| "Several classes share the same overall process but differ in a few steps." | [Template Method](#template-method) |
| "I need to add new operations to a stable set of classes without modifying them." | [Visitor](#visitor) |

## Further reading

- *Design Patterns: Elements of Reusable Object-Oriented Software* — Gamma, Helm, Johnson, Vlissides (the original "Gang of Four" book)
- [Refactoring.Guru's pattern catalogue](https://refactoring.guru/design-patterns) — language-agnostic explanations with diagrams, a good companion to the code here
- [SAP Clean ABAP style guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md) — the naming and syntax conventions this repo's code follows

## Contributing

Found a bug, or want to add a pattern that isn't here yet? PRs welcome — one pattern per PR keeps review simple.

**[⬆ Back to top](#table-of-contents)**
