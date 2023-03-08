# BitBuffer
A Buffer for bit-level manipulation.

## Type `NatLib`
``` motoko no-repl
type NatLib<A> = NatLib.NatLib<A>
```


## Class `BitBuffer<NatX>`

``` motoko no-repl
class BitBuffer<NatX>(natlib : NatLib<NatX>, init_bit_capacity : Nat)
```


### Function `size`
``` motoko no-repl
func size() : Nat
```

Returns the number of bits in the buffer


### Function `wordSize`
``` motoko no-repl
func wordSize() : Nat
```

Returns the number of bits in each word


### Function `capacity`
``` motoko no-repl
func capacity() : Nat
```

Returns the number of bits that can be stored in the buffer without
reallocation


### Function `bitcount`
``` motoko no-repl
func bitcount(bit : Bool) : Nat
```

Counts the number of bits that match the given bit


### Function `get`
``` motoko no-repl
func get(index : Nat) : Bool
```

Returns the bit at the given index


### Function `getBits`
``` motoko no-repl
func getBits(i : Nat, n : Nat) : NatX
```



### Function `getByte`
``` motoko no-repl
func getByte(i : Nat) : Nat8
```

Gets the byte from the given index


### Function `put`
``` motoko no-repl
func put(i : Nat, bit : Bool)
```

Sets the bit at the given index


### Function `putBits`
``` motoko no-repl
func putBits(i : Nat, n : Nat, bits : NatX)
```

Sets the bits at the given index


### Function `insert`
``` motoko no-repl
func insert(i : Nat, bit : Bool)
```



### Function `insertBits`
``` motoko no-repl
func insertBits(i : Nat, n : Nat, bits : NatX)
```



### Function `add`
``` motoko no-repl
func add(bit : Bool)
```

Adds a bit to the end of the buffer
```motoko
import Nat32 "mo:base/Nat32";
import BitBuffer "mo:bitbuffer/BitBuffer";

let bitbuffer = BitBuffer.BitBuffer<Nat32>(Nat32, 3);

bitbuffer.add(true);
bitbuffer.add(false);
bitbuffer.add(true);

assert bitbuffer.size() == 3;
assert bitbuffer.get(0) == true;
assert bitbuffer.get(1) == false;
assert bitbuffer.get(2) == true;
```


### Function `addBits`
``` motoko no-repl
func addBits(n : Nat, bits : NatX)
```

Adds bits to the end of the buffer up to the word_size


### Function `addByte`
``` motoko no-repl
func addByte(n : Nat8)
```



### Function `addBytes`
``` motoko no-repl
func addBytes(bytes : [Nat8])
```



### Function `append`
``` motoko no-repl
func append(other : BitBuffer<NatX>)
```

Appends the bits from the given buffer to the end of this buffer


### Function `removeLast`
``` motoko no-repl
func removeLast() : ?Bool
```



### Function `remove`
``` motoko no-repl
func remove(i : Nat) : Bool
```



### Function `removeBits`
``` motoko no-repl
func removeBits(i : Nat, n : Nat) : NatX
```



### Function `pad`
``` motoko no-repl
func pad(n : Nat)
```



### Function `byteAlign`
``` motoko no-repl
func byteAlign()
```



### Function `wordAlign`
``` motoko no-repl
func wordAlign()
```



### Function `invert`
``` motoko no-repl
func invert()
```

Flips all the bits in the buffer


### Function `clear`
``` motoko no-repl
func clear()
```

Removes all the bits in the buffer


### Function `clone`
``` motoko no-repl
func clone() : BitBuffer<NatX>
```



### Function `words`
``` motoko no-repl
func words() : Iter<NatX>
```



### Function `vals`
``` motoko no-repl
func vals() : Iter<Bool>
```


## Function `init`
``` motoko no-repl
func init<NatX>(natlib : NatLib<NatX>, buffer_size : Nat, val : Bool) : BitBuffer<NatX>
```


## Function `tabulate`
``` motoko no-repl
func tabulate<NatX>(natlib : NatLib<NatX>, buffer_size : Nat, f : (Nat) -> Bool) : BitBuffer<NatX>
```


## Function `fromBytes`
``` motoko no-repl
func fromBytes<NatX>(natlib : NatLib<NatX>, bytes : [Nat8]) : BitBuffer<NatX>
```


## Function `fromWords`
``` motoko no-repl
func fromWords<NatX>(natlib : NatLib<NatX>, words : [NatX]) : BitBuffer<NatX>
```


## Function `withNat8Word`
``` motoko no-repl
func withNat8Word(init_capacity : Nat) : BitBuffer<Nat8>
```


## Function `withNat16Word`
``` motoko no-repl
func withNat16Word(init_capacity : Nat) : BitBuffer<Nat16>
```


## Function `withNat32Word`
``` motoko no-repl
func withNat32Word(init_capacity : Nat) : BitBuffer<Nat32>
```


## Function `withNat64Word`
``` motoko no-repl
func withNat64Word(init_capacity : Nat) : BitBuffer<Nat64>
```


## Function `toBytes`
``` motoko no-repl
func toBytes<NatX>(bitbuffer : BitBuffer<NatX>) : [Nat8]
```


## Function `toWords`
``` motoko no-repl
func toWords<NatX>(bitbuffer : BitBuffer<NatX>) : [NatX]
```


## Function `bitcountNonZero`
``` motoko no-repl
func bitcountNonZero<NatX>(bitbuffer : BitBuffer<NatX>) : Nat
```


## Function `isByteAligned`
``` motoko no-repl
func isByteAligned<NatX>(bitbuffer : BitBuffer<NatX>) : Bool
```


## Function `isWordAligned`
``` motoko no-repl
func isWordAligned<NatX>(bitbuffer : BitBuffer<NatX>) : Bool
```

