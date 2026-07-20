import Lean4Tutorial.i002_replicate_MP.Definitions
import Lean4Tutorial.i002_replicate_MP.Equilibrium
import Lean4Tutorial.i002_replicate_MP.Results
import Lean4Tutorial.i002_replicate_MP.Verification

set_option linter.style.header false

/-!
# Mortensen--Pissarides (1994) formalization

This is the entry-point module for the complete MP1994 development.  Build it
directly with:

```sh
lake build Lean4Tutorial.i002_replicate_MP
```

That target checks only this development and its dependencies; it does not
import the tutorial's `basic_examples` module.
-/
