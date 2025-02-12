---
title: Try Catch
keywords:
  - try
  - catch
  - finally

---

#### Synopsis

Try to execute a statement and catch resulting exceptions.

#### Syntax

```rascal
try
   _Statement~1~_;
catch _PatternWithAction~1~_;
catch _PatternWithAction~2~_;
...
catch: _Statement~2~_;
finally: _Statement~3~_;
```

#### Types

#### Function

#### Description

A try catch statement has as purpose to catch any [Exceptions]((Library:module:Exception)) that are raised 
during the execution of _Statement_~1~.
These exceptions may caused by:

*  The execution of an explicit ((Throw)) statement.

*  The Rascal system that discovers an abnormal condition, e.g., an out of bounds error when accessing a list element.


Note that all elements of the try catch statement are optional but that at least one has to be present. 
Their meaning is as follows:

*  If a pattern of some _PatternWithAction~i~_ matches, the corresponding action is executed.

*  Otherwise, _Statement~2~_ is executed (when present).

*  Before leaving the try catch statement _Statement~3~_ is always executed (when present).

#### Examples

Let's define a variant of the [head]((Library:List-head)) function that returns the first element of a list,
but throws an exception when the list is empty. Our variant will return `0` for an empty list:
```rascal-shell
import List;
import Exception;
int hd(list[int] x) { try return head(x); catch: return 0; }
hd([1,2,3]);
hd([]);
```
We can also be more specific and catch the `EmptyList` exception
(which is available here since we have imported the `Exception` module):
```rascal-shell,continue
int hd2(list[int] x) { try return head(x); catch EmptyList(): return 0; }
hd2([]);
```


#### Benefits

#### Pitfalls

