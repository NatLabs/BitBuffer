import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";

import Debug "mo:base/Debug";

module {
    public type NatType = {
        #Nat8; 
        #Nat16;
        #Nat32;
        #Nat64;
    };

    public type NatBlock = {
        #Nat8 : Nat8; 
        #Nat16 : Nat16;
        #Nat32 : Nat32;
        #Nat64 : Nat64;
        // #empty;
    };

    public func bits(_type : NatType) : Nat {
        switch(_type){
            case (#Nat8)   8;
            case (#Nat16) 16;
            case (#Nat32) 32;
            case (#Nat64) 64;
        }
    };

    // public func increaseBits(n: NatBlock) : NatBlock{
    //     switch(n){
    //         case (#Nat8(n))   Nat8.toNat(n);
    //         case (#Nat16(n)) Nat16.toNat(n);
    //         case (#Nat32(n)) Nat32.toNat(n);
    //         case (#Nat64(n)) Nat64.toNat(n);
    //     }
    // };

    public func bytes(_type : NatType) : Nat{
        bits(_type) / 8
    };

    public func zero(_type : NatType) : NatBlock {
        switch(_type){
            case (#Nat8)   #Nat8(0);
            case (#Nat16) #Nat16(0);
            case (#Nat32) #Nat32(0);
            case (#Nat64) #Nat64(0);
        }
    };

    public func max(_type : NatType) : NatBlock {
        switch(_type){
            case (#Nat8)   #Nat8(0xff);
            case (#Nat16) #Nat16(0xffff);
            case (#Nat32) #Nat32(0xffffffff);
            case (#Nat64) #Nat64(0xffffffffffffffff);
        }
    };

    public func add(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 + n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 + n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 + n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 + n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func sub(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 - n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 - n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 - n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 - n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func mul(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 * n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 * n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 * n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 * n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func div(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 / n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 / n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 / n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 / n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func rem(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 % n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 % n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 % n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 % n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func pow(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 ** n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 ** n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 ** n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 ** n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func fromNat(n : Nat, _type: NatType) : NatBlock{
        switch(_type){
            case (#Nat8)     #Nat8(Nat8.fromNat(n));
            case (#Nat16) #Nat16(Nat16.fromNat(n));
            case (#Nat32) #Nat32(Nat32.fromNat(n));
            case (#Nat64) #Nat64(Nat64.fromNat(n));
        };
    };
    
    public func toNat(_n: NatBlock) : Nat{
        switch(_n){
            case (#Nat8(n))   Nat8.toNat(n);
            case (#Nat16(n)) Nat16.toNat(n);
            case (#Nat32(n)) Nat32.toNat(n);
            case (#Nat64(n)) Nat64.toNat(n);
        }
    };

    public func bitcountNonZero(_n: NatBlock) : NatBlock {
        switch(_n){
            case (#Nat8(n))   #Nat8(Nat8.bitcountNonZero(n));
            case (#Nat16(n)) #Nat16(Nat16.bitcountNonZero(n));
            case (#Nat32(n)) #Nat32(Nat32.bitcountNonZero(n));
            case (#Nat64(n)) #Nat64(Nat64.bitcountNonZero(n));
        }
    };

    public func bitcountLeadingZero(_n: NatBlock) : NatBlock{
        switch(_n){
            case (#Nat8(n))   #Nat8(Nat8.bitcountLeadingZero(n));
            case (#Nat16(n)) #Nat16(Nat16.bitcountLeadingZero(n));
            case (#Nat32(n)) #Nat32(Nat32.bitcountLeadingZero(n));
            case (#Nat64(n)) #Nat64(Nat64.bitcountLeadingZero(n));
        }
    };

    public func bitnot(_n: NatBlock) : NatBlock{
        switch(_n){
            case (#Nat8(n))  #Nat8(^n);
            case (#Nat16(n)) #Nat16(^n);
            case (#Nat32(n)) #Nat32(^n);
            case (#Nat64(n)) #Nat64(^n);
        }
    };

    public func bitor(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 | n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 | n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 | n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 | n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func bitxor(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 ^ n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 ^ n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 ^ n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 ^ n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func bitand(_n1 : NatBlock, _n2 : NatBlock) : NatBlock{
        switch(_n1, _n2){
            case (#Nat8(n1), #Nat8(n2))    #Nat8(n1 & n2);
            case (#Nat16(n1), #Nat16(n2)) #Nat16(n1 & n2);
            case (#Nat32(n1), #Nat32(n2)) #Nat32(n1 & n2);
            case (#Nat64(n1), #Nat64(n2)) #Nat64(n1 & n2);
            case (_){
                Debug.trap("Parameters must be of the same variant type");
            };
        }
    };

    public func bitshiftLeft(_n: NatBlock, p : Nat) : NatBlock{
        switch(_n){
            case (#Nat8(n))    #Nat8(n << Nat8.fromNat(p));
            case (#Nat16(n)) #Nat16(n << Nat16.fromNat(p));
            case (#Nat32(n)) #Nat32(n << Nat32.fromNat(p));
            case (#Nat64(n)) #Nat64(n << Nat64.fromNat(p));
        }
    };

    public func bitshiftRight(_n: NatBlock, p : Nat) : NatBlock{
        switch(_n){
            case (#Nat8(n))    #Nat8(n >> Nat8.fromNat(p));
            case (#Nat16(n)) #Nat16(n >> Nat16.fromNat(p));
            case (#Nat32(n)) #Nat32(n >> Nat32.fromNat(p));
            case (#Nat64(n)) #Nat64(n >> Nat64.fromNat(p));
        }
    };

    public func bitset(_n: NatBlock, p : Nat) : NatBlock{
        switch(_n){
            case (#Nat8(n))    #Nat8(Nat8.bitset(n, p));
            case (#Nat16(n)) #Nat16(Nat16.bitset(n, p));
            case (#Nat32(n)) #Nat32(Nat32.bitset(n, p));
            case (#Nat64(n)) #Nat64(Nat64.bitset(n, p));
        }
    };

    public func bitclear(_n: NatBlock, p : Nat) : NatBlock{
        switch(_n){
            case (#Nat8(n))    #Nat8(Nat8.bitclear(n, p));
            case (#Nat16(n)) #Nat16(Nat16.bitclear(n, p));
            case (#Nat32(n)) #Nat32(Nat32.bitclear(n, p));
            case (#Nat64(n)) #Nat64(Nat64.bitclear(n, p));
        }
    };

    public func bittest(_n: NatBlock, p : Nat) : Bool{
        switch(_n){
            case (#Nat8(n))   Nat8.bittest(n, p);
            case (#Nat16(n)) Nat16.bittest(n, p);
            case (#Nat32(n)) Nat32.bittest(n, p);
            case (#Nat64(n)) Nat64.bittest(n, p);
        }
    };

    public func toBinaryText(_n : NatBlock) : Text {
        var binary = "";

        switch(_n){
            case (#Nat8(n)) {
                var _bits = bits(#Nat8);

                while (_bits > 0){
                    binary #= if (Nat8.bittest(n, _bits - 1)) {"1"} else {"0"};
                    _bits -=1;
                };
            };
            case (#Nat16(n)) {
                var _bits = bits(#Nat16);

                while (_bits > 0){
                    binary #= if (Nat16.bittest(n, _bits - 1)) {"1"} else {"0"};
                    _bits -=1;
                };
            };
            case (#Nat32(n)) {
                var _bits = bits(#Nat32);

                while (_bits > 0){
                    binary #= if (Nat32.bittest(n, _bits - 1)) {"1"} else {"0"};
                    _bits -=1;
                };
            };
            case (#Nat64(n)) {
                var _bits = bits(#Nat64);

                while (_bits > 0){
                    binary #= if (Nat64.bittest(n, _bits - 1)) {"1"} else {"0"};
                    _bits -=1;
                };
            };
        };

        binary
    };

    func nat16To8(n16: Nat16) : Nat8{
        Nat8.fromNat(Nat16.toNat(n16))
    };

    func nat8To16(n8: Nat8) : Nat16{
        Nat16.fromNat(Nat8.toNat(n8))
    };

    func nat32To64(n32: Nat32) : Nat64{
        Nat64.fromNat(Nat32.toNat(n32))
    };

    func nat32To8(n32: Nat32) : Nat8{
        Nat8.fromNat(Nat32.toNat(n32))
    };

    func nat64To8(n64: Nat64) : Nat8{
        Nat8.fromNat(Nat64.toNat(n64))
    };

    public func toBytes(_n : NatBlock) : [Nat8]{
        switch(_n){
            case (#Nat8(n))   [n];
            case (#Nat16(n)) [nat16To8(n), nat16To8(n >> 8)];
            case (#Nat32(n)) [nat32To8(n), nat32To8(n >> 8), nat32To8(n >> 16), nat32To8(n >> 24)];
            case (#Nat64(n)) {
                Array.tabulate<Nat8>(8, func (i) { 
                    nat64To8( n >> Nat64.fromNat(i * 8))
                })
            };
        }
    };
};
