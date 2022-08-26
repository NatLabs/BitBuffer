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

    public type StableBitArray = {
        natType : NatType;
        var nbits : Nat;
        buffer : StableBuffer.StableBuffer<NatBlock>;
    };

    public func new(natType : NatType, nbits : Nat) : StableBitArray{
        {
            var nbits = 0;  natType;
            buffer = StableBuffer.initPresized(
                (nbits / NatLib.bits(natType)) + 1
            );
        }
    };

    public func init(natType : NatType, nbits : Nat, fill : Bool) : StableBitArray{
        let newBufferSize = (nbits / NatLib.bits(natType)) + 1;
        let buffer = StableBuffer.initPresized<NatBlock>( newBufferSize );

        if (fill){
            for (i in Iter.range(1, newBufferSize)){
                if (i == newBufferSize){
                    let (_, p) = _get_pos(nbits, natType);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, natType);
                    StableBuffer.add(buffer, lastBlock);
                } else{
                    StableBuffer.add(buffer, NatLib.max(natType));
                }
            };
        }else{
            for (_ in Iter.range(1, newBufferSize)){
                StableBuffer.add(buffer, NatLib.zero(natType));
            }
        };

        {
            natType; buffer;
            var nbits = nbits; 
        }
    };

    /// Initialise `StableBitArray` with a Nat8 Blocks for storing data in multiples of 8 bits
    public func initNat8(nbits : Nat, fill: Bool) : StableBitArray {
        init(#Nat8, nbits, fill)
    };

    public func initNat16(nbits : Nat, fill: Bool) : StableBitArray {
        init(#Nat16, nbits, fill)
    };

    public func initNat32(nbits : Nat, fill: Bool) : StableBitArray {
        init(#Nat32, nbits, fill)
    };

    public func initNat64(nbits : Nat, fill: Bool) : StableBitArray {
        init(#Nat64, nbits, fill)
    };

    public func size(self : StableBitArray) : Nat{
        self.nbits
    };

    public func count(self: StableBitArray) : Nat {

        var cnt : NatBlock = NatLib.zero(self.natType);

        for (block in blocks(self)){
            cnt := NatLib.add(cnt, NatLib.bitcountNonZero(block));
        };
        
        NatLib.toNat(cnt)
    };

    public func clone(self : StableBitArray) : StableBitArray{
        {
            natType = self.natType; 
            var nbits = self.nbits;
            buffer = StableBuffer.clone(self.buffer);
        }
    };

    public func capacity(self : StableBitArray) : Nat{
        StableBuffer.size(self.buffer) * self.nbits
    };

    func _get_pos(n: Nat, natType : NatType) : (Nat, Nat){
        (n / NatLib.bits(natType), n % NatLib.bits(natType))
    };

    public func get(self : StableBitArray, n : Nat) : Bool {
        if (n >= self.nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show n);
        };

        let (r, c) = _get_pos(n, self.natType);
        let block = StableBuffer.get(self.buffer, r);
        NatLib.bittest(block, c)
    };

    public func set(self : StableBitArray, i : Nat, val : Bool) {
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

    public func add(self : StableBitArray, val : Bool) {

        if (self.nbits % NatLib.bits(self.natType) == 0){
            StableBuffer.add(self.buffer, NatLib.zero(self.natType));
        };

        self.nbits +=1;
        set(self, self.nbits - 1, val);
    };

    public func removeLast(self : StableBitArray) : ?Bool {
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

    public func blocks(self : StableBitArray) : Iter.Iter<NatBlock>{
        StableBuffer.vals(self.buffer)
    };

    public func setAll(self : StableBitArray, val : Bool) {
        if (val){
            for (i in Iter.range(0, StableBuffer.size(self.buffer) - 1)){
                if (i + 1 == StableBuffer.size(self.buffer)){
                    let (_, p) = _get_pos(self.nbits, self.natType);
                    let lastBlock = NatLib.fromNat((2 ** p) - 1, self.natType);
                    StableBuffer.put(self.buffer, i, lastBlock);
                } else{
                    StableBuffer.put(self.buffer, i, NatLib.max(self.natType));
                }
            };
        }else{
            for (i in Iter.range(0, StableBuffer.size(self.buffer) - 1)){
                StableBuffer.put(self.buffer, i, NatLib.zero(self.natType));
            }
        }
    };

    public func clear(self : StableBitArray) {
        self.nbits := 0;
        StableBuffer.clear(self.buffer);
    };

    public func any(self : StableBitArray) : Bool {
        for (block in blocks(self)){
            if (NatLib.toNat(NatLib.bitcountNonZero(block)) > 1){
                return true;
            };
        };

        false
    };

    public func all(self : StableBitArray) : Bool {
        for (block in blocks(self)){
            if (not (block == NatLib.max(self.natType))){
                return false;
            };
        };

        true
    };

    public func none(self : StableBitArray) : Bool {
        for (block in blocks(self)){
            if (not (block == NatLib.zero(self.natType))){
                return false;
            };
        };

        true
    };

    func process_blocks(self: StableBitArray, other: StableBitArray, fn: (NatBlock, NatBlock) -> NatBlock){
        if (not (size(self) == size(other))){
            Debug.trap("Bit Arrays must of the same size to perform bit operations")
        };

        for (i in Iter.range(0, StableBuffer.size(self.buffer) - 1)){
            let x = StableBuffer.get(self.buffer, i);
            let y = StableBuffer.get(other.buffer, i);

            let block = fn(x, y);

            StableBuffer.put(self.buffer, i, block);
        };
    };

    public func bitand(self: StableBitArray, other: StableBitArray){
        process_blocks(self, other, NatLib.bitand);
    };

    public func bitor(self: StableBitArray, other: StableBitArray){
        process_blocks(self, other, NatLib.bitor);
    };

    public func bitxor(self: StableBitArray, other: StableBitArray){
        process_blocks(self, other, NatLib.bitxor);
    };

    public func invert(self : StableBitArray){
        for (i in Iter.range(0, StableBuffer.size(self.buffer) - 1)){
            let n = StableBuffer.get(self.buffer, i);
            StableBuffer.put(self.buffer, i, NatLib.bitnot(n));
        };
    };

    public func fromIter(natType: NatType, iter : Iter.Iter<Bool>) : StableBitArray {
        let bitArray = new(natType, 0);

        for (val in iter){
            add(bitArray, val);
        };

        bitArray
    };

    public func toIter(self : StableBitArray) : Iter.Iter<Bool>{
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

    // To-do - remove the extra bits after the size
    public func toBytes(self : StableBitArray) : [Nat8] {
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

    // To-do - remove leading zeroes
    public func toText(self : StableBitArray) : Text{
        var binary  = "";

        for (block in blocks(self)){
            binary #= NatLib.toBinaryText(block); 
        };

        binary
    };
};