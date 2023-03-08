/// A Buffer for bit-level manipulation.

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";

import Itertools "mo:itertools/Iter";

import NatLib "NatLib";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type Iter<A> = Iter.Iter<A>;
    public type NatLib<A> = NatLib.NatLib<A>;

    public class BitBuffer<NatX>(natlib : NatLib<NatX>, init_bit_capacity : Nat) = self {

        let max_n : NatX = NatLib.getMax(natlib);
        let word_size : Nat = NatLib.bits(natlib);

        let init_buffer_capacity = (init_bit_capacity + (word_size - 1 : Nat) / word_size);

        let buffer = Buffer.Buffer<NatX>(init_buffer_capacity);
        var total_bits : Nat = 0;

        /// Returns the number of bits in the buffer
        public func size() : Nat { total_bits };

        /// Returns the number of bits in each word
        public func wordSize() : Nat { word_size };

        func allocated() : Nat {
            buffer.size() * word_size;
        };

        /// Returns the number of bits that can be stored in the buffer without
        /// reallocation
        public func capacity() : Nat {
            buffer.capacity() * word_size;
        };

        /// Counts the number of bits that match the given bit
        public func bitcount(bit: Bool) : Nat {
            var cnt_x : NatX = natlib.fromNat(0);

            for (word in buffer.vals()) {
                let n = natlib.bitcountNonZero(word);
                cnt_x := natlib.add(cnt_x, n);
            };

            let cnt = natlib.toNat(cnt_x);

            if (bit) { cnt } else { total_bits - cnt };
        };

        // Returns the position of the word in the buffer
        // and the postition bit in the word at the given index
        func get_pos(index : Nat) : (Nat, Nat) {
            (index / word_size, index % word_size);
        };

        /// Returns the bit at the given index
        public func get(index : Nat) : Bool {
            if (index >= total_bits) {
                Debug.trap("BitBuffer get(): Index out of bounds");
            };

            let (word_index, bit_index) = get_pos(index);
            let word = buffer.get(word_index);
            natlib.bittest(word, bit_index);
        };
        
        public func getBits(i : Nat, n : Nat) : NatX {
            
            let (word_index, bit_index) = get_pos(i);
            let word = buffer.get(word_index);

            let top_segment_len = Nat.min(n, word_size - bit_index);
            let top_segment = NatLib.slice(natlib, word, bit_index, top_segment_len);

            if (bit_index + n <= word_size){
                return top_segment;
            };

            let next_word = buffer.get(word_index + 1);
            let bottom_segment = NatLib.slice(natlib, next_word, 0, (n - top_segment_len) : Nat);
            let bottom_segment_shift = natlib.bitshiftLeft(bottom_segment, natlib.fromNat(top_segment_len));

            natlib.bitor(top_segment, bottom_segment_shift);

        };

        /// Gets the byte from the given index
        public func getByte(i: Nat): Nat8 {
            if (i >= total_bits) {
                Debug.trap("BitBuffer getByte(): Index out of bounds");
            };

            let byte = getBits(i, Nat.min(8, total_bits - i));
            let nat = natlib.toNat(byte);
            Nat8.fromNat(nat);
        };

        /// Sets the bit at the given index
        public func put(i : Nat, bit : Bool) {
            if (i >= total_bits) {
                Debug.trap("BitBuffer put(): Index out of bounds");
            };

            let (word_index, bit_index) = get_pos(i);
            let word = buffer.get(word_index);

            let new_word = if (bit) {
                natlib.bitset(word, bit_index);
            } else {
                natlib.bitclear(word, bit_index);
            };

            buffer.put(word_index, new_word);
        };

        func _putBits(i : Nat, n : Nat, bits : NatX) = debug {
            let (word_index, bit_index) = get_pos(i);

            let word = buffer.get(word_index);

            let len = Nat.min(n, (word_size - bit_index) : Nat);

            let new_word = NatLib.replaceSlice(natlib, word, bit_index, len, bits);

            buffer.put(word_index, new_word);

            // if overflow of bits, put a new word
            if (bit_index + n > word_size) {
                let bottom_segment = NatLib.slice(natlib, bits, len, (n - len): Nat);
                buffer.put(word_index + 1, bottom_segment);
            };

        };

        /// Sets the bits at the given index
        public func putBits(i : Nat, n : Nat, bits : NatX) {
            if (i >= total_bits) {
                Debug.trap("BitBuffer putBits(): Index out of bounds");
            };

            if (n > word_size) {
                Debug.trap("BitBuffer putBits(): Number of bits to add is too large");
            };

            if (i + n > total_bits) {
                Debug.trap("BitBuffer putBits(): Not enough bits in buffer");
            };

            _putBits(i, n, bits);
        };

        public func insert(i : Nat, bit : Bool) {
            let natx = if (bit) {
                natlib.fromNat(1);
            } else {
                natlib.fromNat(0);
            };

            insertBits(i, 1, natx);
        };

        public func insertBits(i : Nat, n : Nat, bits : NatX) {
            if (i > total_bits) {
                Debug.trap("BitBuffer insertBits(): Index out of bounds");
            };

            if (n > word_size) {
                Debug.trap("BitBuffer insertBits(): Number of bits to insert is too large");
            };

            if (total_bits + n > allocated()) {
                buffer.add(natlib.fromNat(0));
            };

            let (word_index, bit_index) = get_pos(i);
            var elems_after_index = (total_bits - i) : Nat;

            while (elems_after_index > 0) {
                let shift_n = Nat.min(elems_after_index, word_size);
                let bit_index = ( i + elems_after_index - shift_n) : Nat;

                let word = getBits(bit_index, shift_n);

                _putBits(bit_index + n, shift_n, word);
                elems_after_index -= shift_n;
            };

            _putBits(i, n, bits);
            total_bits += n;
        };

        /// Adds a bit to the end of the buffer
        /// ```motoko
        /// import Nat32 "mo:base/Nat32";
        /// import BitBuffer "mo:bitbuffer/BitBuffer";
        ///
        /// let bitbuffer = BitBuffer.BitBuffer<Nat32>(Nat32, 3);
        ///
        /// bitbuffer.add(true);
        /// bitbuffer.add(false);
        /// bitbuffer.add(true);
        ///
        /// assert bitbuffer.size() == 3;
        /// assert bitbuffer.get(0) == true;
        /// assert bitbuffer.get(1) == false;
        /// assert bitbuffer.get(2) == true;
        /// ```
        public func add(bit : Bool) {
            let (word_index, bit_index) = get_pos(total_bits);

            if (word_index >= buffer.size()) {
                buffer.add(natlib.fromNat(0));
            };

            let word = buffer.get(word_index);

            let new_word = if (bit) {
                natlib.bitset(word, bit_index);
            } else {
                natlib.bitclear(word, bit_index);
            };

            buffer.put(word_index, new_word);
            total_bits += 1;
        };

        /// Adds bits to the end of the buffer up to the word_size
        public func addBits(n : Nat, bits : NatX) = debug {
            if (n > word_size) {
                Debug.trap("BitBuffer addBits(): Number of bits to add is too large");
            };

            let bit_index = total_bits % word_size;

            if (bit_index == 0 or (bit_index + n) > word_size) {
                buffer.add(natlib.fromNat(0));
            };

            _putBits(total_bits, n, bits);
            total_bits += n;
        };

        public func addByte(n: Nat8){
            let nat = Nat8.toNat(n);
            let bits = natlib.fromNat(nat);
            addBits(8, bits);
        };

        public func addBytes(bytes: [Nat8]){
            for (byte in bytes.vals()) {
                addByte(byte);
            };
        };

        /// Appends the bits from the given buffer to the end of this buffer
        public func append(other : BitBuffer<NatX>) {
            var other_size = other.size();

            for (word in other.words()) {
                let n = Nat.min(word_size, other_size);
                self.addBits(word_size, word);
                other_size -= n;
            };
        };

        public func removeLast() : ?Bool {
            if (total_bits == 0) {
                return null;
            };

            ?remove(total_bits - 1);
        };

        public func remove(i: Nat) : Bool {
            let bit = removeBits(i, 1);
            natlib.toNat(bit) == 1
        };

        public func removeBits(i: Nat, n: Nat) : NatX {
            let bits = getBits(i, n);

            var j = i + n;

            while (j < total_bits) {
                let nbits = Nat.min(total_bits - j, word_size);
                let word = getBits(j, nbits);
                _putBits(j - n, nbits, word);
                j += nbits;
            };

            total_bits -= n;

            if ((allocated() - total_bits : Nat) > word_size){
                ignore buffer.removeLast();
            };

            bits
        };

        public func pad(n: Nat){
            let zero = natlib.fromNat(0);
            addBits(n, zero);
        };

        public func byteAlign(){
            if (not isByteAligned(self)){
                let padding = (8 - (total_bits % 8)) : Nat;
                pad(padding);
            }
        };

        public func wordAlign(){
            if (not isWordAligned(self)){
                let padding = (word_size - (total_bits % word_size)) : Nat;
                pad(padding);
            }
        };

        /// Flips all the bits in the buffer
        public func invert() {
            for (i in Itertools.range(0, buffer.size())) {
                let word = buffer.get(i);
                let new_word = natlib.bitnot(word);
                buffer.put(i, new_word);
            };
        };

        /// Removes all the bits in the buffer
        public func clear() {
            buffer.clear();
            total_bits := 0;
        };

        public func clone() : BitBuffer<NatX> {
            fromWords(natlib, Buffer.toArray(buffer))
        };

        public func words() : Iter<NatX> {
            buffer.vals();
        };

        public func vals() : Iter<Bool> {
            Iter.map(
                Itertools.range(0, total_bits),
                func(i : Nat) : Bool { self.get(i) },
            );
        };
    };

    public func init<NatX>(
        natlib : NatLib<NatX>,
        buffer_size : Nat,
        val : Bool,
    ) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, buffer_size);
        var _buffer_size = buffer_size;
        let word_size = NatLib.bits(natlib);

        let word = if (val) {
            NatLib.getMax(natlib);
        } else {
            natlib.fromNat(0);
        };

        while (_buffer_size > 0){
            let nbits = Nat.min(_buffer_size, word_size);
            bitbuffer.addBits(nbits, word);
            _buffer_size -= nbits;
        };

        bitbuffer;
    };

    public func tabulate<NatX>(
        natlib : NatLib<NatX>,
        buffer_size : Nat,
        f : (Nat) -> Bool,
    ) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, buffer_size);

        for (i in Itertools.range(0, buffer_size)) {
            bitbuffer.add(f(i));
        };

        bitbuffer;
    };

    public func fromBytes<NatX>(natlib : NatLib<NatX>, bytes : [Nat8]) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, bytes.size() * 8);

        for (byte in bytes.vals()) {
            bitbuffer.addByte(byte);
        };

        bitbuffer;
    };

    public func fromWords<NatX>(natlib : NatLib<NatX>, words : [NatX]) : BitBuffer<NatX> {
        let word_bit_size = NatLib.bits(natlib);
        let nbits = words.size() * word_bit_size;
        let bitbuffer = BitBuffer<NatX>(natlib, nbits);

        for (word in words.vals()) {
            bitbuffer.addBits(word_bit_size, word);
        };

        bitbuffer;
    };
    
    public func withNat8Word(init_capacity: Nat) : BitBuffer<Nat8> {
        BitBuffer<Nat8>(Nat8, init_capacity);
    };

    public func withNat16Word(init_capacity: Nat) : BitBuffer<Nat16> {
        BitBuffer<Nat16>(Nat16, init_capacity);
    };

    public func withNat32Word(init_capacity : Nat) : BitBuffer<Nat32> {
        BitBuffer<Nat32>(Nat32, init_capacity);
    };

    public func withNat64Word(init_capacity : Nat) : BitBuffer<Nat64> {
        BitBuffer<Nat64>(Nat64, init_capacity);
    };

    public func toBytes<NatX>(bitbuffer: BitBuffer<NatX>) : [Nat8] {
        let size = (bitbuffer.size() + (8 - 1 : Nat)) / 8;

        Array.tabulate(
            size,
            func (i : Nat) : Nat8 {
                bitbuffer.getByte(i * 8);
            },
        )
    };

    public func toWords<NatX>(bitbuffer: BitBuffer<NatX>) : [NatX] {
        Iter.toArray(bitbuffer.words());
    };

    public func bitcountNonZero<NatX>(bitbuffer: BitBuffer<NatX>) : Nat {
        bitbuffer.bitcount(true);
    };

    public func isByteAligned<NatX>(bitbuffer: BitBuffer<NatX>) : Bool {
        bitbuffer.size() % 8 == 0;
    };

    public func isWordAligned<NatX>(bitbuffer: BitBuffer<NatX>) : Bool {
        bitbuffer.size() % bitbuffer.wordSize() == 0;
    };

};
