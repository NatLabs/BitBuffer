import Debug "mo:base/Debug";

module {
    public type NatLib<NatX> = module {
        add : (NatX, NatX) -> NatX;
        bitand : (NatX, NatX) -> NatX;
        bitclear : (NatX, Nat) -> NatX;
        bitcountNonZero : NatX -> NatX;
        bitshiftLeft : (NatX, NatX) -> NatX;
        bitshiftRight : (NatX, NatX) -> NatX;
        bitnot : NatX -> NatX;
        bitor : (NatX, NatX) -> NatX;
        bitset : (NatX, Nat) -> NatX;
        bittest : (NatX, Nat) -> Bool;
        div : (NatX, NatX) -> NatX;
        fromNat : Nat -> NatX;
        subWrap : (NatX, NatX) -> NatX;
        toNat : NatX -> Nat;
        toText : NatX -> Text;
    };

    public func getMax<NatX>(NatLib : NatLib<NatX>) : NatX {
        let zero = NatLib.fromNat(0);
        let one = NatLib.fromNat(1);

        NatLib.subWrap(zero, one);
    };

    public func bits<NatX>(NatLib : NatLib<NatX>) : Nat {
        let size = NatLib.bitcountNonZero(getMax(NatLib));
        NatLib.toNat(size);
    };

    public func getMask<NatX>(NatLib : NatLib<NatX>, i : Nat, n : Nat) : NatX {
        var bitmask = getMax(NatLib);
        let word_size = bits(NatLib);

        if (i >= word_size) {
            Debug.trap("NatLib getMask(): The index is out of the Nat range.");
        };

        if ((i + n) > word_size) {
            Debug.trap("NatLib getMask(): The number of bits is out of the Nat range.");
        };

        let padding = NatLib.fromNat(word_size - (i + n));
        bitmask := NatLib.bitshiftRight(bitmask, padding);
        NatLib.bitshiftLeft(bitmask, NatLib.fromNat(i));
    };

    public func slice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat) : NatX {
        let mask = getMask(NatLib, i, n);
        let masked = NatLib.bitand(bits, mask);
        NatLib.bitshiftRight(masked, NatLib.fromNat(i));
    };

    public func clearSlice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat) : NatX {
        let mask = getMask(NatLib, i, n);
        let flipped_mask = NatLib.bitnot(mask);
        NatLib.bitand(bits, flipped_mask);
    };

    public func replaceSlice<NatX>(NatLib : NatLib<NatX>, bits : NatX, i : Nat, n : Nat, value : NatX) : NatX {
        let cleared = clearSlice(NatLib, bits, i, n);

        let escaped_value = NatLib.bitand(value, getMask(NatLib, 0, n));
        let shifted_value = NatLib.bitshiftLeft(value, NatLib.fromNat(i));
        NatLib.bitor(cleared, shifted_value);
    };
};
