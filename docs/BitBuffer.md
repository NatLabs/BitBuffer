# BitBuffer
A Buffer for bit-level and byte-level manipulation.

## Class `BitBuffer`

``` motoko no-repl
class BitBuffer(init_bits : Nat)
```


### Function `bitSize`
``` motoko no-repl
func bitSize() : Nat
```

Returns the number of bits in the buffer


### Function `bitCapacity`
``` motoko no-repl
func bitCapacity() : Nat
```

Returns the max number of bits the buffer can hold without resizing


### Function `byteSize`
``` motoko no-repl
func byteSize() : Nat
```

Returns the number of bytes in the buffer


### Function `byteCapacity`
``` motoko no-repl
func byteCapacity() : Nat
```

Returns the max number of bytes the buffer can hold without resizing


### Function `bitcount`
``` motoko no-repl
func bitcount(bit : Bool) : Nat
```

Returns the number of bits that match the given bit


### Function `addBit`
``` motoko no-repl
func addBit(bit : Bool)
```

Adds a single bit to the bitbuffer


### Function `addBits`
``` motoko no-repl
func addBits(n : Nat, bits : Nat)
```

Adds the given bits to the bitbuffer


### Function `getBit`
``` motoko no-repl
func getBit(i : Nat) : Bool
```

Returns the bit at the given index as a `Bool`


### Function `getBits`
``` motoko no-repl
func getBits(i : Nat, n : Nat) : Nat
```

Returns the bits at the given index as a `Nat`


### Function `dropBit`
``` motoko no-repl
func dropBit()
```

Drops the first bit from the buffer.


### Function `dropBits`
``` motoko no-repl
func dropBits(n : Nat)
```

Drops the first `n` bits from the bitbuffer.
Trap if `n` is greater than the number of bits in the bitbuffer.


### Function `invert`
``` motoko no-repl
func invert()
```

Flips all the bits in the buffer


### Function `clear`
``` motoko no-repl
func clear()
```



### Function `bits`
``` motoko no-repl
func bits() : Iter<Bool>
```

Returns an iterator over the bits in the buffer


### Function `bytes`
``` motoko no-repl
func bytes() : Iter<Nat8>
```

Returns an iterator over the bytes in the buffer


### Function `byteAlign`
``` motoko no-repl
func byteAlign()
```

Aligns the buffer to the next byte boundary

## Function `new`
``` motoko no-repl
func new() : BitBuffer
```

Initializes an empty bitbuffer

## Function `withByteCapacity`
``` motoko no-repl
func withByteCapacity(byte_capacity : Nat) : BitBuffer
```

Initializes a bitbuffer with the given byte capacity

## Function `init`
``` motoko no-repl
func init(bit_capacity : Nat, ones : Bool) : BitBuffer
```

Initializes a bitbuffer with `bit_capacity` bits and fills it with `ones` if `true` or `zeros` if `false`.

## Function `tabulate`
``` motoko no-repl
func tabulate(bit_capacity : Nat, f : (Nat) -> Bool) : BitBuffer
```

Initializes a bitbuffer with `bit_capacity` bits and fills it with the bits returned by the function `f`.

## Function `isByteAligned`
``` motoko no-repl
func isByteAligned(bitbuffer : BitBuffer) : Bool
```

Checks if the bits in the buffer are byte aligned

## Function `bitcountNonZero`
``` motoko no-repl
func bitcountNonZero(bitbuffer : BitBuffer) : Nat
```

Returns the number of bits that are set to `true` or `1` in the buffer

## Function `addByte`
``` motoko no-repl
func addByte(bitbuffer : BitBuffer, byte : Nat8)
```


## Function `getByte`
``` motoko no-repl
func getByte(bitbuffer : BitBuffer, bit_index : Nat) : Nat8
```


## Function `dropByte`
``` motoko no-repl
func dropByte(bitbuffer : BitBuffer)
```


## Function `fromBytes`
``` motoko no-repl
func fromBytes(bytes : [Nat8]) : BitBuffer
```


## Function `addBytes`
``` motoko no-repl
func addBytes(bitbuffer : BitBuffer, bytes : [Nat8])
```


## Function `addBytesIter`
``` motoko no-repl
func addBytesIter(bitbuffer : BitBuffer, bytes : Iter<Nat8>)
```


## Function `getBytes`
``` motoko no-repl
func getBytes(bitbuffer : BitBuffer, bit_index : Nat, n : Nat) : [Nat8]
```


## Function `dropBytes`
``` motoko no-repl
func dropBytes(bitbuffer : BitBuffer, n : Nat)
```


## Function `addNat8`
``` motoko no-repl
func addNat8(bitbuffer : BitBuffer, nat8 : Nat8)
```


## Function `getNat8`
``` motoko no-repl
func getNat8(bitbuffer : BitBuffer, bit_index : Nat) : Nat8
```


## Function `dropNat8`
``` motoko no-repl
func dropNat8(bitbuffer : BitBuffer)
```


## Function `addNat16`
``` motoko no-repl
func addNat16(bitbuffer : BitBuffer, nat16 : Nat16)
```


## Function `getNat16`
``` motoko no-repl
func getNat16(bitbuffer : BitBuffer, bit_index : Nat) : Nat16
```


## Function `dropNat16`
``` motoko no-repl
func dropNat16(bitbuffer : BitBuffer)
```


## Function `addNat32`
``` motoko no-repl
func addNat32(bitbuffer : BitBuffer, nat32 : Nat32)
```


## Function `getNat32`
``` motoko no-repl
func getNat32(bitbuffer : BitBuffer, bit_index : Nat) : Nat32
```


## Function `dropNat32`
``` motoko no-repl
func dropNat32(bitbuffer : BitBuffer)
```


## Function `addNat64`
``` motoko no-repl
func addNat64(bitbuffer : BitBuffer, nat64 : Nat64)
```


## Function `getNat64`
``` motoko no-repl
func getNat64(bitbuffer : BitBuffer, bit_index : Nat) : Nat64
```


## Function `dropNat64`
``` motoko no-repl
func dropNat64(bitbuffer : BitBuffer)
```


## Function `addInt8`
``` motoko no-repl
func addInt8(bitbuffer : BitBuffer, int8 : Int8)
```


## Function `addInt16`
``` motoko no-repl
func addInt16(bitbuffer : BitBuffer, int16 : Int16)
```


## Function `addInt32`
``` motoko no-repl
func addInt32(bitbuffer : BitBuffer, int32 : Int32)
```


## Function `addInt64`
``` motoko no-repl
func addInt64(bitbuffer : BitBuffer, int64 : Int64)
```

