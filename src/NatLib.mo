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

    public type NatLibRec<NatX> =  {
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
    };

    type NatLibX<NatX> = NatLib<NatX> and module {
        sub: (NatX, NatX) -> NatX
    };

    public func getMax<NatX>(NatLib: NatLib<NatX>) : NatX {
        let zero = NatLib.fromNat(0);
        let one = NatLib.fromNat(1);

        NatLib.subWrap(zero, one);
    };

    public func bits<NatX>(NatLib: NatLib<NatX>) : Nat{
        let size = NatLib.bitcountNonZero(getMax(NatLib));
        NatLib.toNat(size);
    };
};