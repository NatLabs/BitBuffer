/// A Buffer for bit-level and byte-level manipulation.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Int8 "mo:base/Int8";
import Int16 "mo:base/Int16";
import Int32 "mo:base/Int32";
import Int64 "mo:base/Int64";

import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";

import Itertools "mo:itertools/Iter";
import BufferDeque "mo:BufferDeque/BufferDeque";

import Common "mo:BufferDeque/internal/Common";
import BitBuffer "BitBuffer";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type Iter<A> = Iter.Iter<A>;
    
    let BYTE = 8;

    public class BitBuffer(init_bits : Nat) {
        let max_n : Nat64 = 0xFFFFFFFFFFFFFFFF;
        // let BYTE : Nat = 8;
        // let big_endian : Bool = true;

        let init_buffer_capacity = (init_bits + (BYTE - 1 : Nat) / (BYTE : Nat));

        let buffer = BufferDeque.BufferDeque<Nat8>(init_buffer_capacity);
        var total_bits : Nat = 0;

        var dropped_bits : Nat = 0;

        /// Returns the number of bits in the buffer
        public func bitSize() : Nat { total_bits - dropped_bits };

        /// Returns the max number of bits the buffer can hold without resizing
        public func bitCapacity() : Nat { (buffer.capacity() * BYTE) - dropped_bits };

        /// Returns the number of bytes in the buffer
        public func byteSize() : Nat { (bitSize() + (BYTE - 1 : Nat)) / BYTE };

        /// Returns the max number of bytes the buffer can hold without resizing
        public func byteCapacity() : Nat { (bitCapacity() + (BYTE - 1 : Nat)) / BYTE  };

        /// Returns the number of bits that match the given bit
        public func bitcount(bit : Bool) : Nat {
            var cnt = 0;

            for (byte in buffer.vals()) {
                cnt += Nat8.toNat(Nat8.bitcountNonZero(byte));
            };

            if (bit) { cnt } else { total_bits - cnt };
        };

        public func addBits(n : Nat, bits : Nat) {
            var var_bits = bits;
            var nbits = n;
            let nbytes = (nbits + (BYTE - 1 : Nat)) / BYTE;

            let offset = total_bits % BYTE;
            let overflow = (BYTE - offset) : Nat;

            if (offset == 0) {
                for (i in Iter.range(0, nbytes - 1)) {

                    let take_n_bits = if (nbits % BYTE == 0) BYTE else (nbits % BYTE);

                    let byte = if (i + 1 == nbytes and take_n_bits != 0) {
                        Nat8.fromNat(var_bits % (2 ** take_n_bits));
                    } else {
                        Nat8.fromNat(var_bits % (2 ** BYTE));
                    };

                    var_bits := var_bits / (2 ** BYTE);
                    buffer.addBack(byte);
                };
            } else {

                if (bitSize() == 0) {
                    buffer.addBack(0);
                };

                while (nbits > 0) {
                    var curr = Nat8.fromNat(var_bits % (2 ** offset));
                    let last_index = (byteSize() - 1 : Nat);
                    let prev = buffer.get(last_index) << Nat8.fromNat(offset);

                    buffer.put(byteSize() - 1, prev | curr);
                    var_bits := var_bits / (2 ** offset);

                    nbits -= offset;

                    if (nbits > 0) {
                        let next_byte = Nat8.fromNat(var_bits % (2 ** overflow));
                        buffer.addBack(next_byte);
                        nbits -= overflow;
                    };
                };
            };

            total_bits += n;
        };

        /// Drops the first `n` bits from the buffer
        public func dropBits(n: Nat){
            var nbits = n;

            if (nbits + dropped_bits > BYTE){
                ignore buffer.popFront();
                nbits -= (BYTE - dropped_bits);
            };

            while (nbits > BYTE ){
                ignore buffer.popFront();
                nbits -= BYTE;
            };

            dropped_bits := nbits;
        };

        public func getBits(bit_index : Nat, nbits : Nat) : Nat {
            1;
        };

        public func bytes() : Iter<Nat8> {
            buffer.vals();
        };

        /// Aligns the buffer to the next byte boundary
        public func byteAlign() {
            let offset = total_bits % BYTE;

            if (offset != 0) {
                total_bits += BYTE - offset;
            };

        };

    };

    public func addByte(buffer: BitBuffer, byte: Nat8) {
        buffer.addBits(BYTE, Nat8.toNat(byte));
    };

    public func addBytes(buffer: BitBuffer, bytes: Iter<Nat8>) {
        for (byte in bytes) {
            addByte(buffer, byte);
        };
    };

    public func addNat8(buffer: BitBuffer, nat8: Nat8) = addByte(buffer, nat8);

    public func addNat16(buffer : BitBuffer, nat16 : Nat16) {
        buffer.addBits(BYTE * 2, Nat16.toNat(nat16));
    };

    public func addNat32(buffer : BitBuffer, nat32 : Nat32) {
        buffer.addBits(BYTE * 4, Nat32.toNat(nat32));
    };

    public func addNat64(buffer : BitBuffer, nat64 : Nat64) {
        buffer.addBits(BYTE * 8, Nat64.toNat(nat64));
    };

    func int_represented_as_nat(int: Int, nbits: Nat) : Nat {
        if (int < 0) {
            let nat = Int.abs(int);
            (2 ** (nbits - 1)) + nat;
        } else {
            Int.abs(int);
        };
    };

    public func addInt8(buffer: BitBuffer, int8: Int8){
        buffer.addBits(
            BYTE,
            int_represented_as_nat(Int8.toInt(int8), BYTE)
        );
    };

    public func addInt16(buffer : BitBuffer, int16 : Int16) {
        buffer.addBits(
            BYTE * 2,
            int_represented_as_nat(Int16.toInt(int16), BYTE * 2)
        );
    };

    public func addInt32(buffer : BitBuffer, int32 : Int32) {
        buffer.addBits(
            BYTE * 4,
            int_represented_as_nat(Int32.toInt(int32), BYTE * 4)
        );
    };

    public func addInt64(buffer : BitBuffer, int64 : Int64) {
        buffer.addBits(
            BYTE * 8,
            int_represented_as_nat(Int64.toInt(int64), BYTE * 8)
        );
    };
};
