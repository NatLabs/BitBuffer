# NatLib

## Type `NatLib`
``` motoko no-repl
type NatLib<NatX> = module { add : (NatX, NatX) -> NatX; bitand : (NatX, NatX) -> NatX; bitclear : (NatX, Nat) -> NatX; bitcountNonZero : NatX -> NatX; bitshiftLeft : (NatX, NatX) -> NatX; bitshiftRight : (NatX, NatX) -> NatX; bitnot : NatX -> NatX; bitor : (NatX, NatX) -> NatX; bitset : (NatX, Nat) -> NatX; bittest : (NatX, Nat) -> Bool; div : (NatX, NatX) -> NatX; fromNat : Nat -> NatX; subWrap : (NatX, NatX) -> NatX; toNat : NatX -> Nat; toText : NatX -> Text }
```


## Function `getMax`
``` motoko no-repl
func getMax<NatX>(NatLib : NatLib<NatX>) : NatX
```


## Function `bits`
``` motoko no-repl
func bits<NatX>(NatLib : NatLib<NatX>) : Nat
```


## Function `getMask`
``` motoko no-repl
func getMask<NatX>(NatLib : NatLib<NatX>, i : Nat, n : Nat) : NatX
```


## Function `slice`
``` motoko no-repl
func slice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat) : NatX
```


## Function `clearSlice`
``` motoko no-repl
func clearSlice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat) : NatX
```


## Function `replaceSlice`
``` motoko no-repl
func replaceSlice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat, value : NatX) : NatX
```

