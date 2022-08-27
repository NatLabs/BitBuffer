import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import Itertools "mo:Itertools/Iter";
import StableBuffer "mo:StableBuffer/StableBuffer";

import NatLib "NatLib";

module{
    type NatType = NatLib.NatType;
    type NatBlock = NatLib.NatBlock;

    public type StableBitBuffer = {
        natType : NatType;
        var nbits : Nat;
        buffer : StableBuffer.StableBuffer<NatBlock>;
    };

    public func new(natType : NatType) : StableBitBuffer{
        {
            var nbits = 0;  natType;
            buffer = StableBuffer.init();
        }
    };

    public func newPresized(natType : NatType, nbits : Nat) : StableBitBuffer{
        {
            var nbits = 0;  natType;
            buffer = StableBuffer.initPresized(
                (nbits / NatLib.bits(natType)) + 1
            );
        }
    };

    public func init(natType : NatType, nbits : Nat, fill : Bool) : StableBitBuffer{
        let newBufferSize = (nbits / NatLib.bits(natType)) + 1;
        let buffer = StableBuffer.initPresized<NatBlock>( newBufferSize );

        if (fill){
            for (i in Itertools.range(0, newBufferSize)){
                if (i + 1 == newBufferSize){
                    let (_, p) = _get_pos(nbits, natType);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, natType);
                    StableBuffer.add(buffer, lastBlock);
                } else{
                    StableBuffer.add(buffer, NatLib.max(natType));
                }
            };
        }else{
            for (_ in Itertools.range(0, newBufferSize)){
                StableBuffer.add(buffer, NatLib.zero(natType));
            }
        };

        {
            natType; buffer;
            var nbits = nbits; 
        }
    };

    /// Initialise `StableBitBuffer` with a Nat8 Blocks for storing data in multiples of 8 bits
    public func initNat8(nbits : Nat, fill: Bool) : StableBitBuffer {
        init(#Nat8, nbits, fill)
    };

    public func initNat16(nbits : Nat, fill: Bool) : StableBitBuffer {
        init(#Nat16, nbits, fill)
    };

    public func initNat32(nbits : Nat, fill: Bool) : StableBitBuffer {
        init(#Nat32, nbits, fill)
    };

    public func initNat64(nbits : Nat, fill: Bool) : StableBitBuffer {
        init(#Nat64, nbits, fill)
    };

    public func size(self : StableBitBuffer) : Nat{
        self.nbits
    };

    /// Counts the number of bits with a `true` value in the buffer
    public func count(self: StableBitBuffer) : Nat {

        var cnt : NatBlock = NatLib.zero(self.natType);

        for (block in blocks(self)){
            cnt := NatLib.add(cnt, NatLib.bitcountNonZero(block));
        };
        
        NatLib.toNat(cnt)
    };

    /// Create a clone of the StableBitBuffer
    public func clone(self : StableBitBuffer) : StableBitBuffer{
        {
            natType = self.natType; 
            var nbits = self.nbits;
            buffer = StableBuffer.clone(self.buffer);
        }
    };

    /// Returns the total capacity of the internal storage
    public func capacity(self : StableBitBuffer) : Nat{
        StableBuffer.size(self.buffer) * NatLib.bits(self.natType)
    };

    func _get_pos(n: Nat, natType : NatType) : (Nat, Nat){
        (n / NatLib.bits(natType), n % NatLib.bits(natType))
    };

    /// Retrieve the boolean value of the bit at a given index
    public func get(self : StableBitBuffer, n : Nat) : Bool {
        if (n >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show n);
        };

        let (r, c) = _get_pos(n, self.natType);
        let block = StableBuffer.get(self.buffer, r);
        NatLib.bittest(block, c)
    };

    /// Set the value of bit at a given index
    public func set(self : StableBitBuffer, i : Nat, val : Bool) {
        if (i >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show i);
        };

        let (r, c) = _get_pos(i, self.natType);

        let block = if (val){
            NatLib.bitset(StableBuffer.get(self.buffer, r), c);
        }else{
            NatLib.bitclear(StableBuffer.get(self.buffer, r), c);
        };

        StableBuffer.put(self.buffer, r, block);
    };

    /// Add a bit to the end of the buffer
    public func add(self : StableBitBuffer, val : Bool) {

        if (self.nbits % NatLib.bits(self.natType) == 0){
            StableBuffer.add(self.buffer, NatLib.zero(self.natType));
        };

        self.nbits +=1;
        set(self, self.nbits - 1, val);
    };

    /// Removes the last bit from the array and returns an optional value
    /// If the buffer is empty it returns a null value
    public func removeLast(self : StableBitBuffer) : ?Bool {
        if (self.nbits == 0) return null;

        let val = get(self, self.nbits - 1);

        if (self.nbits % NatLib.bits(self.natType) == 1){
            ignore StableBuffer.removeLast(self.buffer);
        }else{
            set(self, self.nbits - 1, false);
        };

        self.nbits -=1;

        ?val
    };

    /// Returns an iterator over the nat blocks in the internal storage
    public func blocks(self : StableBitBuffer) : Iter.Iter<NatBlock>{
        StableBuffer.vals(self.buffer)
    };

    /// Sets all the elements in the buffer to the given value
    public func setAll(self : StableBitBuffer, val : Bool) {
        let bufferSize = StableBuffer.size(self.buffer);

        if (val){
            if (bufferSize == 0) return;

            for (i in Itertools.range(0, bufferSize)){
                if (i + 1 == bufferSize){
                    let (_, p) = _get_pos(self.nbits, self.natType);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, self.natType);
                    StableBuffer.put(self.buffer, i, lastBlock);
                } else{
                    StableBuffer.put(self.buffer, i, NatLib.max(self.natType));
                }
            };
        }else{
            for (i in Itertools.range(0, bufferSize)){
                StableBuffer.put(self.buffer, i, NatLib.zero(self.natType));
            }
        }
    };

    /// Concatenates the buffer from the `other` buffer to the `self` buffer
    /// in place
    public func append(self : StableBitBuffer, other : StableBitBuffer){
        if (self.nbits % NatLib.bits(self.natType) == 0 ){
            for (newBlock in blocks(other)){
                StableBuffer.add(self.buffer, newBlock);
            }
        }else{
            // 00000111
            //      ---
            // ----- |
            //   |   |
            // offset|
            //       |
            //     overflow

            let overflow = self.nbits % NatLib.bits(self.natType);
            let offset = NatLib.bits(self.natType) - overflow;
            let selfBufferSize = StableBuffer.size(self.buffer);
            let otherBufferSize = StableBuffer.size(other.buffer);
            var i = 0;

            for (newBlock in blocks(other)){
                StableBuffer.put(
                    self.buffer, 
                    selfBufferSize - 1 + i, 
                    NatLib.bitor(
                        StableBuffer.get(self.buffer, selfBufferSize - 1 + i), 
                        NatLib.bitshiftLeft(newBlock, overflow)
                    )
                );

                let overflowedBits = NatLib.bitshiftRight(newBlock, offset);
                if (not (i + 1 == otherBufferSize) or not (overflowedBits == NatLib.zero(self.natType))){
                    StableBuffer.add(self.buffer, overflowedBits);
                };

                i+=1;
            };
        };

        self.nbits += other.nbits;

    };

    /// Removes all the bits in the buffer
    public func clear(self : StableBitBuffer) {
        self.nbits := 0;
        StableBuffer.clear(self.buffer);
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
        let bufferSize = StableBuffer.size(self.buffer);

        for (i in Itertools.range(0, bufferSize)){
            let block = StableBuffer.get(self.buffer, i);

            if (i + 1 == bufferSize){
                let p = self.nbits % NatLib.bits(self.natType);

                if (not (block == NatLib.fromNat((2 ** p) - 1, self.natType))){
                    return false
                };
            }else{
                if (not (block == NatLib.max(self.natType))){
                    return false;
                };
            };
        };
        
        true
    };

    /// Checks that all bits in the buffer are `false
    public func none(self : StableBitBuffer) : Bool {
        for (block in blocks(self)){
            if (not (block == NatLib.zero(self.natType))){
                return false;
            };
        };

        true
    };

    func process_blocks(self: StableBitBuffer, other: StableBitBuffer, fn: (NatBlock, NatBlock) -> NatBlock){
        if (not (size(self) == size(other))){
            Debug.trap("Bit Arrays must of the same size to perform bit operations")
        };

        for (i in Itertools.range(0, StableBuffer.size(self.buffer))){
            let x = StableBuffer.get(self.buffer, i);
            let y = StableBuffer.get(other.buffer, i);

            let block = fn(x, y);

            StableBuffer.put(self.buffer, i, block);
        };
    };

    /// bit and operation in place
    public func bitand(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitand);
    };

    public func bitor(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitor);
    };

    public func bitxor(self: StableBitBuffer, other: StableBitBuffer){
        process_blocks(self, other, NatLib.bitxor);
    };

    /// Flips all the bits in the buffer
    public func invert(self : StableBitBuffer){
        for (i in Itertools.range(0, StableBuffer.size(self.buffer))){
            let n = StableBuffer.get(self.buffer, i);
            StableBuffer.put(self.buffer, i, NatLib.bitnot(n));
        };
    };

    // Todo - fix the extra bits in the last block 
    public func grow( self : StableBitBuffer, newBits: Nat, fill : Bool ){

        let bufferSize = StableBuffer.size(self.buffer);
        let newBlocks = (self.nbits + newBits / NatLib.bits(self.natType)) - bufferSize;

        if (fill == false) { 
            for (i in Itertools.range(0, newBlocks)){
                StableBuffer.add(self.buffer, NatLib.zero(self.natType))
            }
        }else{
            let overflow = self.nbits % NatLib.bits(self.natType);
            let offset = NatLib.bits(self.natType) - overflow;

            if (bufferSize > 0){
                let i = bufferSize - 1;
                let lastBlock = StableBuffer.get(self.buffer, i);
                let mask = NatLib.bitnot(
                    NatLib.fromNat((2**overflow) - 1, self.natType)
                );

                let newBlock = NatLib.bitor(lastBlock, mask);
                StableBuffer.put(self.buffer, i, newBlock);
            };

            for (i in Itertools.range(0, newBlocks)){
                StableBuffer.add(self.buffer, NatLib.max(self.natType))
            };
        };

        self.nbits += newBits;
    };

    /// Initialise a BitBuffer with an iterator of boolean values
    public func fromIter(natType: NatType, iter : Iter.Iter<Bool>) : StableBitBuffer {
        let bitbuffer = new(natType);

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

                let (r, c) = _get_pos(i, self.natType);

                let val = NatLib.bittest(StableBuffer.get(self.buffer, r), c);
                i+=1;

                ?val
            };
        }
    };

    public func fromArray(natType: NatType, arr: [Bool] ) : StableBitBuffer {
        fromIter(natType: NatType, arr.vals())
    };

    public func toArray( self : StableBitBuffer ) : [Bool]{
        Iter.toArray(toIter(self))
    };

    // Todo - remove the extra bits after the last block
    public func toBytes(self : StableBitBuffer) : [Nat8] {
        let bufferSize = NatLib.bytes(self.natType) * StableBuffer.size(self.buffer);

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