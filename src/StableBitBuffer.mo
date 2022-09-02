import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import Itertools "mo:Itertools/Iter";
import SB "mo:StableBuffer/StableBuffer";

import NatLib "NatLib";

module{
    type NatSize = NatLib.NatSize;
    type NatBlock = NatLib.NatBlock;

    /// Stable Bit Buffer type
    public type StableBitBuffer = {
        natSize : NatSize;
        var nbits : Nat;
        buffer : SB.StableBuffer<NatBlock>;
    };

    /// Creates an empty [StableBitBuffer](#stableBitBuffer) with the specified [NatSize](../NatLib#natLib) for each bitblock in the buffer
    public func new(natSize : NatSize) : StableBitBuffer{
        {
            var nbits = 0;  natSize;
            buffer = SB.init();
        }
    };

    /// Creates an empty [StableBitBuffer](#stableBitBuffer) with an initial capacity
    ///
    /// #### Input
    /// - natSize - specific nat size for each bitblock
    /// - nbits - initial capacity of the stable bit buffer
    public func newPresized(natSize : NatSize, nbits : Nat) : StableBitBuffer{
        {
            var nbits = 0;  natSize;
            buffer = SB.initPresized(
                (nbits / NatLib.bits(natSize)) + 1
            );
        }
    };

    /// Initializes n numbers of elements with a given value
    /// 
    /// #### Inputs
    /// - natSize - size of nats for each block
    /// - nbits - number of elements to initialise in the bit buffer
    /// - fill - boolean value to fill the buffer with
    public func init(natSize : NatSize, nbits : Nat, fill : Bool) : StableBitBuffer{
        let newBufferSize = (nbits / NatLib.bits(natSize)) + 1;
        let buffer = SB.initPresized<NatBlock>( newBufferSize );

        if (fill){
            for (i in Itertools.range(0, newBufferSize)){
                if (i + 1 == newBufferSize){
                    let (_, p) = _get_pos(nbits, natSize);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, natSize);
                    SB.add(buffer, lastBlock);
                } else{
                    SB.add(buffer, NatLib.max(natSize));
                }
            };
        }else{
            for (_ in Itertools.range(0, newBufferSize)){
                SB.add(buffer, NatLib.zero(natSize));
            }
        };

        {
            natSize; buffer;
            var nbits = nbits; 
        }
    };

    /// Returns the number of bits in the buffer
    public func size(self : StableBitBuffer) : Nat{
        self.nbits
    };

    /// Counts the number of bits with a `true` value in the buffer
    public func count(self: StableBitBuffer) : Nat {

        var cnt : NatBlock = NatLib.zero(self.natSize);

        for (block in blocks(self)){
            cnt := NatLib.add(cnt, NatLib.bitcountNonZero(block));
        };
        
        NatLib.toNat(cnt)
    };

    /// Create a clone of the StableBitBuffer
    public func clone(self : StableBitBuffer) : StableBitBuffer{
        {
            natSize = self.natSize; 
            var nbits = self.nbits;
            buffer = SB.clone(self.buffer);
        }
    };

    /// Returns the total capacity of the internal storage
    public func capacity(self : StableBitBuffer) : Nat{
        SB.size(self.buffer) * NatLib.bits(self.natSize)
    };

    func _get_pos(n: Nat, natSize : NatSize) : (Nat, Nat){
        (n / NatLib.bits(natSize), n % NatLib.bits(natSize))
    };

    /// Retrieve the boolean value of the bit at a given index
    public func get(self : StableBitBuffer, n : Nat) : Bool {
        if (n >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show n);
        };

        let (r, c) = _get_pos(n, self.natSize);
        let block = SB.get(self.buffer, r);
        NatLib.bittest(block, c)
    };

    /// Set the value of bit at a given index
    /// #### Inputs
    /// - self - bit buffer to modify
    /// - i - index of the bit to set
    /// - val - boolean value to set the bit to

    public func set(self : StableBitBuffer, i : Nat, val : Bool) {
        if (i >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show i);
        };

        let (r, c) = _get_pos(i, self.natSize);

        let block = if (val){
            NatLib.bitset(SB.get(self.buffer, r), c);
        }else{
            NatLib.bitclear(SB.get(self.buffer, r), c);
        };

        SB.put(self.buffer, r, block);
    };

    /// Add a bit to the end of the buffer
    public func add(self : StableBitBuffer, val : Bool) {

        if (self.nbits % NatLib.bits(self.natSize) == 0){
            SB.add(self.buffer, NatLib.zero(self.natSize));
        };

        self.nbits +=1;
        set(self, self.nbits - 1, val);
    };

    /// Removes the last bit from the array and returns an optional value
    /// If the buffer is empty it returns a null value
    public func removeLast(self : StableBitBuffer) : ?Bool {
        if (self.nbits == 0) return null;

        let val = get(self, self.nbits - 1);

        if (self.nbits % NatLib.bits(self.natSize) == 1){
            ignore SB.removeLast(self.buffer);
        }else{
            set(self, self.nbits - 1, false);
        };

        self.nbits -=1;

        ?val
    };

    /// Returns an iterator over the nat blocks in the internal storage
    public func blocks(self : StableBitBuffer) : Iter.Iter<NatBlock>{
        SB.vals(self.buffer)
    };

    /// Sets all the elements in the buffer to the given value
    public func setAll(self : StableBitBuffer, val : Bool) {
        let bufferSize = SB.size(self.buffer);

        if (val){
            if (bufferSize == 0) return;

            for (i in Itertools.range(0, bufferSize)){
                if (i + 1 == bufferSize){
                    let (_, p) = _get_pos(self.nbits, self.natSize);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, self.natSize);
                    SB.put(self.buffer, i, lastBlock);
                } else{
                    SB.put(self.buffer, i, NatLib.max(self.natSize));
                }
            };
        }else{
            for (i in Itertools.range(0, bufferSize)){
                SB.put(self.buffer, i, NatLib.zero(self.natSize));
            }
        }
    };

    /// Concatenates the buffer from the `other` buffer to the `self` buffer
    /// in place
    public func append(self : StableBitBuffer, other : StableBitBuffer){
        if (self.nbits % NatLib.bits(self.natSize) == 0 ){
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

            let overflow = self.nbits % NatLib.bits(self.natSize);
            let offset = NatLib.bits(self.natSize) - overflow;
            let selfBufferSize = SB.size(self.buffer);
            let otherBufferSize = SB.size(other.buffer);
            var i = 0;

            for (newBlock in blocks(other)){
                SB.put(
                    self.buffer, 
                    selfBufferSize - 1 + i, 
                    NatLib.bitor(
                        SB.get(self.buffer, selfBufferSize - 1 + i), 
                        NatLib.bitshiftLeft(newBlock, overflow)
                    )
                );

                let overflowedBits = NatLib.bitshiftRight(newBlock, offset);
                if (not (i + 1 == otherBufferSize) or not (overflowedBits == NatLib.zero(self.natSize))){
                    SB.add(self.buffer, overflowedBits);
                };

                i+=1;
            };
        };

        self.nbits += other.nbits;

    };

    /// Removes all the bits in the buffer
    public func clear(self : StableBitBuffer) {
        self.nbits := 0;
        SB.clear(self.buffer);
    };

    /// Checks if any bit is equal to `true` in the buffer
    public func any(self : StableBitBuffer) : Bool {
        for (block in blocks(self)){
            if (NatLib.toNat(NatLib.bitcountNonZero(block)) > 0){
                return true;
            };
        };

        false
    };

    /// Checks if all bits in the buffer are `true`
    public func all(self : StableBitBuffer) : Bool {
        let bufferSize = SB.size(self.buffer);

        for (i in Itertools.range(0, bufferSize)){
            let block = SB.get(self.buffer, i);

            if (i + 1 == bufferSize){
                let p = self.nbits % NatLib.bits(self.natSize);

                if (not (block == NatLib.fromNat((2 ** p) - 1, self.natSize))){
                    return false
                };
            }else{
                if (not (block == NatLib.max(self.natSize))){
                    return false;
                };
            };
        };
        
        true
    };

    /// Checks that all bits in the buffer are `false
    public func none(self : StableBitBuffer) : Bool {
        for (block in blocks(self)){
            if (not (block == NatLib.zero(self.natSize))){
                return false;
            };
        };

        true
    };

    func process_blocks(self: StableBitBuffer, other: StableBitBuffer, fn: (NatBlock, NatBlock) -> NatBlock){
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

    /// In place bitand operation between all the bits in the two bitbuffers
    /// > Note: The two bitbuffers must have the same size
    public func bitand(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitand);
    };

    /// In place bitor operation between all the bits in the two bitbuffers
    /// > Note: The two bitbuffers must have the same size
    public func bitor(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitor);
    };

    /// In place bitxor operation between all the bits in the two bitbuffers
    /// > Note: The two bitbuffers must have the same size
    public func bitxor(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitxor);
    };

    /// Flips all the bits in the buffer
    public func invert(self : StableBitBuffer){
        for (i in Itertools.range(0, SB.size(self.buffer))){
            let n = SB.get(self.buffer, i);
            SB.put(self.buffer, i, NatLib.bitnot(n));
        };
    };

    // Todo - fix the extra bits in the last block 
    public func grow( self : StableBitBuffer, newBits: Nat, fill : Bool ){

        if (newBits == 0) return;

        let bufferSize = SB.size(self.buffer);
        let newBlocks = (self.nbits + newBits / NatLib.bits(self.natSize)) + 1 - bufferSize;

        // if (bufferSize == 0) {

        // };

        if (fill == false) { 
            for (i in Itertools.range(0, newBlocks)){
                SB.add(self.buffer, NatLib.zero(self.natSize))
            }
        }else{
            let overflow = self.nbits % NatLib.bits(self.natSize);
            let offset = NatLib.bits(self.natSize) - overflow;

            if (bufferSize > 0){
                let i = bufferSize - 1;
                let lastBlock = SB.get(self.buffer, i);
                let mask = NatLib.bitnot(
                    NatLib.fromNat((2**overflow) - 1, self.natSize)
                );

                let newBlock = NatLib.bitor(lastBlock, mask);
                SB.put(self.buffer, i, newBlock);
            };

            for (i in Itertools.range(0, newBlocks)){
                SB.add(self.buffer, NatLib.max(self.natSize))
            };
        };

        self.nbits += newBits;
    };

    /// Initialise a BitBuffer with an iterator of boolean values
    public func fromIter(natSize: NatSize, iter : Iter.Iter<Bool>) : StableBitBuffer {
        let bitbuffer = new(natSize);

        for (val in iter){
            add(bitbuffer, val);
        };

        bitbuffer
    };

    /// Return the values of the buffer as an iterator
    public func toIter(self : StableBitBuffer) : Iter.Iter<Bool>{
        var i = 0;

        object{
            public func next() : ?Bool{
                if (i >= self.nbits) return null;

                let (r, c) = _get_pos(i, self.natSize);

                let val = NatLib.bittest(SB.get(self.buffer, r), c);
                i+=1;

                ?val
            };
        }
    };

    public func fromArray(natSize: NatSize, arr: [Bool] ) : StableBitBuffer {
        fromIter(natSize: NatSize, arr.vals())
    };

    public func toArray( self : StableBitBuffer ) : [Bool]{
        Iter.toArray(toIter(self))
    };

    // Todo - remove the extra bits after the last block
    public func toBytes(self : StableBitBuffer) : [Nat8] {
        let bufferSize = NatLib.bytes(self.natSize) * SB.size(self.buffer);

        let buffer = Buffer.Buffer<Nat8>(bufferSize);

        for (block in blocks(self)){
            let bytes = NatLib.toBytes(block);

            for (byte in bytes.vals()){
                buffer.add(byte);
            }
        };

        buffer.toArray()
    };

    // Todo - remove leading zeroes
    public func toText(self : StableBitBuffer) : Text{
        var binary  = "";

        for (block in blocks(self)){
            binary #= NatLib.toBinaryText(block); 
        };

        binary
    };
};