import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import NatLib "NatLib";

module{
    type NatType = NatLib.NatType;
    type NatBlock = NatLib.NatBlock;

    public type StableBitArray = {
        blocks : [var NatBlock];
        natType : NatType;
        nbits : Nat;
    };

    public func init(natType : NatType, nbits: Nat, fill: Bool ) : StableBitArray{
        
        let nBlocks = if (nbits > 0) { 
            (nbits / NatLib.bits(natType)) + 1
        } else {0};

        let rbits = (nbits % NatLib.bits(natType)) + 1;

        let defaultBlock = if (fill) {
            NatLib.max(natType)
        } else { 
            NatLib.zero(natType)
        };

        {
            nbits; natType;
            blocks = Array.tabulateVar<NatBlock>(nBlocks, func (i){
                if (i + 1 == nBlocks){
                    let rbits = nbits % NatLib.bits(natType);
                    NatLib.fromNat((2 ** rbits) - 1, natType)
                }else{
                    defaultBlock
                }
            });
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

    public func size({ nbits }: StableBitArray) : Nat{
        nbits
    };

    public func count({ blocks; natType }: StableBitArray) : Nat {

        var cnt : NatBlock = NatLib.zero(natType);

        for (block in blocks.vals()){
            cnt := NatLib.add(cnt, NatLib.bitcountNonZero(block));
        };
        
        NatLib.toNat(cnt)
    };

    public func clone({ blocks; natType; nbits }: StableBitArray) : StableBitArray{
        {
            natType; nbits;
            blocks = Array.tabulateVar<NatBlock>(
                blocks.size(), 
                func(i){ blocks[i] }
            );
        }
    };

    public func capacity({blocks; nbits} : StableBitArray) : Nat{
        blocks.size() * nbits
    };

    func _get_pos(n: Nat, natType : NatType) : (Nat, Nat){
        (n / NatLib.bits(natType), n % NatLib.bits(natType))
    };

    public func get(self : StableBitArray, n : Nat) : Bool {
        let { blocks; natType; nbits } = self;

        if (n >= nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show n);
        };

        let (r, c) = _get_pos(n, natType);

        NatLib.bittest(blocks[r], c)
    };

    public func set(self : StableBitArray, i : Nat, val : Bool) {
        let { blocks; natType; nbits } = self;

        if (i >= nbits){
            Debug.trap("index out of bounds: the size is " # debug_show(size(self)) # " but the index is " # debug_show i);
        };

        let (r, c) = _get_pos(i, natType);

        blocks[r] := if (val){
            NatLib.bitset(blocks[r], c);
        }else{
            NatLib.bitclear(blocks[r], c);
        };
    };

    public func blocks(self : StableBitArray) : Iter.Iter<NatBlock>{
        self.blocks.vals()
    };

    public func setAll({blocks; natType} : StableBitArray) {

        for (i in Iter.range(0, blocks.size() - 1)){
            if (i + 1 == blocks.size()){
                let (_, p) = _get_pos(blocks.size(), natType);
                blocks[i] := NatLib.fromNat((2 ** p) - 1, natType);
            } else{
                blocks[i] := NatLib.max(natType);
            }
        };
    };

    public func clear({blocks; natType} : StableBitArray) {
        for (i in Iter.range(0, blocks.size() - 1)){
            blocks[i] := NatLib.zero(natType)
        };
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

        for (i in Iter.range(0, self.blocks.size() - 1)){
            self.blocks[i] := fn(self.blocks[i], other.blocks[i]);
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
        for (i in Iter.range(0, self.blocks.size() - 1)){
            self.blocks[i] := NatLib.bitnot(self.blocks[i]);
        };
    };

    public func fromIter(natType: NatType, iter : Iter.Iter<Bool>) : StableBitArray {
        let arr = Iter.toArray(iter);

        let bitArray = init(natType, arr.size(), false);

        for (i in Iter.range(0, arr.size() - 1)){
            set(bitArray, i, arr[i]);
        };

        bitArray
    };

    public func toIter(self : StableBitArray) : Iter.Iter<Bool>{
        var i = 0;

        object{
            public func next() : ?Bool{
                let (r, c) = _get_pos(i, self.natType);

                let val = NatLib.bittest(self.blocks[r], c);
                i+=1;

                ?val
            };
        }
    };

    // To-do - remove the extra bits after the size
    public func toBytes(self : StableBitArray) : [Nat8] {
        let bufferSize = NatLib.bytes(self.natType) * self.blocks.size();

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
    public func toText({ blocks; natType}: StableBitArray) : Text{
        var binary  = "";

        for (block in blocks.vals()){
            binary #= NatLib.toBinaryText(block); 
        };

        binary
    };
};