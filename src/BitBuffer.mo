/// A dynamically sized buffer of bits that can be used to store arbitrary data in a compact form.


import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

import Itertools "mo:itertools/Iter";

import NatLib "NatLib";

module {
    type Buffer<A> = Buffer.Buffer<A>;
    type Iter<A> = Iter.Iter<A>;
    public type NatLib<A> = NatLib.NatLib<A>;

    public class BitBuffer<NatX>(natlib : NatLib<NatX>, init_bit_capacity : Nat) = self {

        let max_n : NatX = NatLib.getMax(natlib);
        let word_size : Nat = NatLib.bits(natlib);

        let init_buffer_capacity = (init_bit_capacity / word_size) + 1;

        let buffer = Buffer.Buffer<NatX>(init_buffer_capacity);
        var nbits : Nat = 0;

        /// Returns the number of bits in the buffer
        public func size() : Nat { nbits };

        public func allocated() : Nat {
            buffer.size() * word_size
        };

        /// Returns the number of bits that can be stored in the buffer without
        /// reallocating
        public func capacity() : Nat {
            buffer.capacity() * word_size;
        };

        /// Returns the number of non-zero bits in the buffer
        public func bitcount() : Nat {
            var cnt : NatX = natlib.fromNat(0);

            for (word in buffer.vals()) {
                let n = natlib.bitcountNonZero(word);
                cnt := natlib.add(cnt, n);
            };

            natlib.toNat(cnt);
        };

        // Returns the position of the word in the buffer
        // and the postition bit in the word at the given index
        func get_pos(index : Nat) : (Nat, Nat) {
            (index / word_size, index % word_size);
        };

        /// Returns the bit at the given index
        public func get(index : Nat) : Bool {
            if (index >= nbits) {
                Debug.trap("BitBuffer get(): Index out of bounds");
            };

            let (word_index, bit_index) = get_pos(index);
            let word = buffer.get(word_index);
            natlib.bittest(word, bit_index);
        };

        /// Todo: getBits() Returns the bits at the given index

        /// Sets the bit at the given index
        public func put(i : Nat, bit : Bool) {
            if (i >= nbits) {
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

        /// Sets the bits at the given index
        // public func putBits(i: Nat, n: Nat, bits : NatX) {
        //     if (i >= nbits) {
        //         Debug.trap("BitBuffer putBits(): Index out of bounds");
        //     };

        //     if (n > word_size) {
        //         Debug.trap("BitBuffer putBits(): Number of bits to add is too large");
        //     };

        //     if (i + n >= nbits) {
        //         Debug.trap("BitBuffer putBits(): Not enough bits in buffer");
        //     };

        //     let (word_index, bit_index) = get_pos(i);
            
        // };

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
            let (word_index, bit_index) = get_pos(nbits);

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
            nbits += 1;
        };

        /// Adds bits to the end of the buffer up to the word_size
        public func addBits(n : Nat, bits : NatX) = debug {
            if (n > word_size) {
                Debug.trap("BitBuffer addBits(): Number of bits to add is too large");
            };

            let (word_index, bit_index) = get_pos(nbits);
            let space = (word_size - bit_index) : Nat;
            let offset = (word_size - Nat.min(n, space)) : Nat;

            Debug.print("addBits: [" # debug_show(n) # "] -> " # natlib.toText(bits) );
            
            let word = if ( self.allocated() <= nbits + n) {
                let word = natlib.fromNat(0);
                buffer.add(word);
                buffer.get(word_index)
            }else{
                buffer.get(word_index)
            };
            
            let bit_x_index = natlib.fromNat(bit_index);

            Debug.print("bit_x_index: " # natlib.toText(bit_x_index));

            let offset_x = natlib.fromNat(offset);

            Debug.print("offset_x: " # natlib.toText(offset_x));

            Debug.print("max_n: " # natlib.toText(max_n));

            let mask = natlib.bitshiftRight(max_n, offset_x);

            Debug.print("mask: " # natlib.toText(mask));

            let top_segment = natlib.bitand(bits, mask);

            Debug.print("top segment: " # natlib.toText(top_segment));

            let new_word = natlib.bitor(word, top_segment);

            Debug.print("new word: " # natlib.toText(new_word));

            buffer.put(word_index, new_word);

            Debug.print("put " # natlib.toText(new_word) # " at index " # debug_show word_index);

            // if overflow of bits, add a new word
            if (bit_index + n > word_size) {
                let overflow = ((2 * word_size) - bit_index - n) : Nat;
                let overflow_x = natlib.fromNat(overflow);

                let bottom_segment = natlib.bitshiftRight(natlib.bitshiftLeft(bits, overflow_x), overflow_x);
                buffer.put(word_index + 1, bottom_segment);
            };

            nbits += n;

            for (word in buffer.vals()){
                Debug.print(debug_show natlib.toText(word));
            };
        };

        /// Appends the bits from the given buffer to the end of this buffer
        public func append(other : BitBuffer<NatX>) {
            for (bit in other.vals()) {
                self.add(bit);
            };
        };

        /// Removes all the bits in the buffer
        public func clear() {
            buffer.clear();
            nbits := 0;
        };

        /// Flips all the bits in the buffer
        public func invert() {
            for (i in Itertools.range(0, buffer.size())) {
                let word = buffer.get(i);
                let new_word = natlib.bitnot(word);
                buffer.put(i, new_word);
            };
        };

        public func words() : Iter<NatX> {
            buffer.vals();
        };

        public func vals() : Iter<Bool> {
            Iter.map(
                Itertools.range(0, nbits),
                func(i : Nat) : Bool { self.get(i) },
            );
        };
    };

    public func init<NatX>(
        natlib : NatLib<NatX>,
        init_bit_capacity : Nat,
        val : Bool,
    ) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, init_bit_capacity);

        for (i in Itertools.range(0, init_bit_capacity)) {
            bitbuffer.add(val);
        };

        bitbuffer;
    };

    public func tabulate<NatX>(
        natlib : NatLib<NatX>,
        init_bit_capacity : Nat,
        f : (Nat) -> Bool,
    ) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, init_bit_capacity);

        for (i in Itertools.range(0, init_bit_capacity)) {
            bitbuffer.add(f(i));
        };

        bitbuffer;
    };

    public func fromIter<NatX>(natlib : NatLib<NatX>, iter : Iter<Bool>) : BitBuffer<NatX> {
        let bitbuffer = BitBuffer<NatX>(natlib, 0);

        for (bit in iter) {
            bitbuffer.add(bit);
        };

        bitbuffer;
    };

    public func fromWords<NatX>(natlib: NatLib<NatX>, words: [NatX]): BitBuffer<NatX>{
        let word_bit_size = NatLib.bits(natlib);
        let nbits = words.size() * word_bit_size;
        let bitbuffer = BitBuffer<NatX>(natlib, nbits);

        for (word in words.vals()){
            bitbuffer.addBits(word_bit_size, word);
        };

        bitbuffer
    };

};
