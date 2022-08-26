import Array "mo:base/Array";

import NatLib "NatLib";

module{
    type NatType = NatLib.NatType;
    type NatBlock = NatLib.NatBlock;

    class BitArray(natType : NatType, nbits: Nat, fill: Bool){
        var _size = nbits;

        let defaultBlock = if (fill) {
            natBlock.fromNat((2 ** natBlock.bits) - 1 )
        } else { 
            natBlock.fromNat(0)
        };

        let blocks = Array.init(
            (nbits / natBlock.bits) + 1, 
            func(_) { defaultBlock }
        );

        public func size() : Nat{
            _size
        };

        public func count() : Nat{
            var cnt = 0;

            for (block in blocks){
                cnt += natBlock.bitcountNonZero(block);
            };

            cnt
        };
    };

    public func BitArray8(nbits: Nat, fill: Bool): BitArray{
        BitArray(#Nat8, nbits, fill)
    };

    public func BitArray16(nbits: Nat, fill: Bool): BitArray{
        BitArray(#Nat16, nbits, fill)
    };

    public func BitArray32(nbits: Nat, fill: Bool): BitArray{
        BitArray(#Nat32, nbits, fill)
    };

    public func BitArray64(nbits: Nat, fill: Bool): BitArray{
        BitArray(#Nat64, nbits, fill)
    };
}