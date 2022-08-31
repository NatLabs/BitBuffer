import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";

import Itertools "mo:Itertools/Iter";
import SB "mo:StableBuffer/StableBuffer";

module{

    type NatBlock = Nat32;

    let BITS_PER_BLOCK = 32;
    let MAX_NUM : NatBlock = 0xffffffff;

    public type StableBitBuffer32 = {
        var nbits : Nat;
        buffer : SB.StableBuffer<NatBlock>;
    };

    public func new() : StableBitBuffer32{
        {
            var nbits = 0;
            buffer = SB.init();
        }
    };

    public func newPresized(nbits : Nat) : StableBitBuffer32{
        {
            var nbits = 0;
            buffer = SB.initPresized(
                (nbits / BITS_PER_BLOCK) + 1
            );
        }
    };

    public func init(nbits : Nat, fill : Bool) : StableBitBuffer32{
        let newBufferSize = (nbits / BITS_PER_BLOCK) + 1;
        let buffer = SB.initPresized<NatBlock>( newBufferSize );

        if (fill){
            for (i in Itertools.range(0, newBufferSize)){
                if (i + 1 == newBufferSize){
                    let (_, p) = _get_pos(nbits);
                    let lastBlock = Nat32.fromNat((2 ** p) - 1);
                    SB.add(buffer, lastBlock);
                } else{
                    SB.add<NatBlock>(buffer, MAX_NUM);
                }
            };
        }else{
            for (_ in Itertools.range(0, newBufferSize)){
                SB.add(buffer, 0 : NatBlock);
            }
        };

        {
            buffer;
            var nbits = nbits; 
        }
    };

    public func size(self : StableBitBuffer32) : Nat{
        self.nbits
    };

    /// Counts the number of bits with a `true` value in the buffer
    public func count(self: StableBitBuffer32) : Nat {

        var cnt : NatBlock = 0;

        for (block in blocks(self)){
            cnt := cnt + Nat32.bitcountNonZero(block);
        };
        
        Nat32.toNat(cnt)
    };

    /// Create a clone of the StableBitBuffer32
    public func clone(self : StableBitBuffer32) : StableBitBuffer32{
        {
            var nbits = self.nbits;
            buffer = SB.clone(self.buffer);
        }
    };

    /// Returns the total capacity of the internal storage
    public func capacity(self : StableBitBuffer32) : Nat{
        SB.size(self.buffer) * BITS_PER_BLOCK
    };

    func _get_pos(n: Nat) : (Nat, Nat){
        (n / BITS_PER_BLOCK, n % BITS_PER_BLOCK)
    };

    /// Retrieve the boolean value of the bit at a given index
    public func get(self : StableBitBuffer32, n : Nat) : Bool {
        if (n >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show n);
        };

        let (r, c) = _get_pos(n);
        let block = SB.get(self.buffer, r);
        Nat32.bittest(block, c)
    };

    /// Set the value of bit at a given index
    public func set(self : StableBitBuffer32, i : Nat, val : Bool) {
        if (i >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show i);
        };

        let (r, c) = _get_pos(i);

        let block = if (val){
            Nat32.bitset(SB.get(self.buffer, r), c);
        }else{
            Nat32.bitclear(SB.get(self.buffer, r), c);
        };

        SB.put(self.buffer, r, block);
    };

    /// Add a bit to the end of the buffer
    public func add(self : StableBitBuffer32, val : Bool) {

        if (self.nbits % BITS_PER_BLOCK == 0){
            SB.add(self.buffer, 0 : NatBlock);
        };

        self.nbits +=1;
        set(self, self.nbits - 1, val);
    };

    /// Removes the last bit from the array and returns an optional value
    /// If the buffer is empty it returns a null value
    public func removeLast(self : StableBitBuffer32) : ?Bool {
        if (self.nbits == 0) return null;

        let val = get(self, self.nbits - 1);

        if (self.nbits % BITS_PER_BLOCK == 1){
            ignore SB.removeLast(self.buffer);
        }else{
            set(self, self.nbits - 1, false);
        };

        self.nbits -=1;

        ?val
    };

    /// Returns an iterator over the nat blocks in the internal storage
    public func blocks(self : StableBitBuffer32) : Iter.Iter<NatBlock>{
        SB.vals(self.buffer)
    };

    /// Sets all the elements in the buffer to the given value
    public func setAll(self : StableBitBuffer32, val : Bool) {
        let bufferSize = SB.size(self.buffer);

        if (val){
            if (bufferSize == 0) return;

            for (i in Itertools.range(0, bufferSize)){
                if (i + 1 == bufferSize){
                    let (_, p) = _get_pos(self.nbits);
                    let lastBlock = Nat32.fromNat((2 ** p) - 1);
                    SB.put(self.buffer, i, lastBlock);
                } else{
                    SB.put(self.buffer, i, MAX_NUM);
                }
            };
        }else{
            for (i in Itertools.range(0, bufferSize)){
                SB.put(self.buffer, i, 0 : NatBlock);
            }
        }
    };

    /// Concatenates the buffer from the `other` buffer to the `self` buffer
    /// in place
    public func append(self : StableBitBuffer32, other : StableBitBuffer32){
        if (self.nbits % BITS_PER_BLOCK == 0 ){
            for (newBlock in blocks(other)){
                SB.add(self.buffer, newBlock);
            }
        }else{
            // 00000111
            //      ---
            // ----- |
            //   |   |
            // offset|
            //       |
            //     overflow

            let overflow = self.nbits % BITS_PER_BLOCK;
            let offset = BITS_PER_BLOCK - overflow;
            let selfBufferSize = SB.size(self.buffer);
            let otherBufferSize = SB.size(other.buffer);
            var i = 0;

            for (newBlock in blocks(other)){
                SB.put(
                    self.buffer, 
                    selfBufferSize - 1 + i, 
                    Nat32.bitor(
                        SB.get(self.buffer, selfBufferSize - 1 + i), 
                        Nat32.bitshiftLeft(newBlock, Nat32.fromNat(overflow))
                    )
                );

                let overflowedBits = Nat32.bitshiftRight(newBlock, Nat32.fromNat(offset));
                if (not (i + 1 == otherBufferSize) or not (overflowedBits == 0)){
                    SB.add(self.buffer, overflowedBits);
                };

                i+=1;
            };
        };

        self.nbits += other.nbits;

    };

    /// Removes all the bits in the buffer
    public func clear(self : StableBitBuffer32) {
        self.nbits := 0;
        SB.clear(self.buffer);
    };

    /// Checks if any bit is equal to `true` in the buffer
    public func any(self : StableBitBuffer32) : Bool {
        for (block in blocks(self)){
            if (Nat32.toNat(Nat32.bitcountNonZero(block)) > 0){
                return true;
            };
        };

        false
    };

    /// Checks if all bits in the buffer are `true`
    public func all(self : StableBitBuffer32) : Bool {
        let bufferSize = SB.size(self.buffer);

        for (i in Itertools.range(0, bufferSize)){
            let block = SB.get(self.buffer, i);

            if (i + 1 == bufferSize){
                let p = self.nbits % BITS_PER_BLOCK;

                if (not (block == Nat32.fromNat((2 ** p) - 1))){
                    return false
                };
            }else{
                if (not (block == MAX_NUM)){
                    return false;
                };
            };
        };
        
        true
    };

    /// Checks that all bits in the buffer are `false
    public func none(self : StableBitBuffer32) : Bool {
        for (block in blocks(self)){
            if (not (block == 0)){
                return false;
            };
        };

        true
    };

    func process_blocks(self: StableBitBuffer32, other: StableBitBuffer32, fn: (NatBlock, NatBlock) -> NatBlock){
        if (not (size(self) == size(other))){
            Debug.trap("Bit Arrays must of the same size to perform bit operations")
        };

        for (i in Itertools.range(0, SB.size(self.buffer))){
            let x = SB.get(self.buffer, i);
            let y = SB.get(other.buffer, i);

            let block = fn(x, y);

            SB.put(self.buffer, i, block);
        };
    };

    /// bit and operation in place
    public func bitand(self: StableBitBuffer32, other: StableBitBuffer32){
        process_blocks(self, other, Nat32.bitand);
    };

    public func bitor(self: StableBitBuffer32, other: StableBitBuffer32){
        process_blocks(self, other, Nat32.bitor);
    };

    public func bitxor(self: StableBitBuffer32, other: StableBitBuffer32){
        process_blocks(self, other, Nat32.bitxor);
    };

    /// Flips all the bits in the buffer
    public func invert(self : StableBitBuffer32){
        for (i in Itertools.range(0, SB.size(self.buffer))){
            let n = SB.get(self.buffer, i);
            SB.put(self.buffer, i, ^n);
        };
    };

    // Todo - fix the extra bits in the last block 
    public func grow( self : StableBitBuffer32, newBits: Nat, fill : Bool ){

        if (newBits == 0) return;

        let bufferSize = SB.size(self.buffer);
        let newBlocks = (self.nbits + newBits / BITS_PER_BLOCK) + 1 - bufferSize;

        if (fill == false) { 
            for (i in Itertools.range(0, newBlocks)){
                SB.add(self.buffer, 0 : NatBlock)
            }
        }else{
            let overflow = self.nbits % BITS_PER_BLOCK;
            let offset = BITS_PER_BLOCK - overflow;

            if (bufferSize > 0){
                let i = bufferSize - 1;
                let lastBlock = SB.get(self.buffer, i);
                let mask = ^Nat32.fromNat((2**overflow) - 1);

                let newBlock = Nat32.bitor(lastBlock, mask);
                SB.put(self.buffer, i, newBlock);
            };

            for (i in Itertools.range(0, newBlocks)){
                SB.add(self.buffer, MAX_NUM)
            };
        };

        self.nbits += newBits;
    };

    /// Initialise a BitBuffer with an iterator of boolean values
    public func fromIter(iter : Iter.Iter<Bool>) : StableBitBuffer32 {
        let bitbuffer = new();

        for (val in iter){
            add(bitbuffer, val);
        };

        bitbuffer
    };

    /// Return the values of the buffer as an iterator
    public func toIter(self : StableBitBuffer32) : Iter.Iter<Bool>{
        var i = 0;

        object{
            public func next() : ?Bool{
                if (i >= self.nbits) return null;

                let (r, c) = _get_pos(i);

                let val = Nat32.bittest(SB.get(self.buffer, r), c);
                i+=1;

                ?val
            };
        }
    };

    public func fromArray(arr: [Bool] ) : StableBitBuffer32 {
        fromIter(arr.vals())
    };

    public func toArray( self : StableBitBuffer32 ) : [Bool]{
        Iter.toArray(toIter(self))
    };

    // // Todo - remove the extra bits after the last block
    // public func toBytes(self : StableBitBuffer32) : [Nat8] {
    //     let bufferSize = (BITS_PER_BLOCK / 8) * SB.size(self.buffer);

    //     let buffer = Buffer.Buffer<Nat8>(bufferSize);

    //     for (block in blocks(self)){
    //         let bytes = Nat32.toBytes(block);

    //         for (byte in bytes.vals()){
    //             buffer.add(byte);
    //         }
    //     };

    //     buffer.toArray()
    // };

    // // Todo - remove leading zeroes
    // public func toText(self : StableBitBuffer32) : Text{
    //     var binary  = "";

    //     for (block in blocks(self)){
    //         binary #= Nat32.toBinaryText(block); 
    //     };

    //     binary
    // };
};