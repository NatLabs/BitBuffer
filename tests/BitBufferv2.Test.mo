import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import {test; suite; skip} "mo:test";

import BitBuffer "../src/BitBufferv2";

suite("BitBuffer", func() {
	test("Add bits to buffer", func() {
        let buffer = BitBuffer.BitBuffer(8);

        buffer.addBits(4, 10);
        buffer.addBits(4, 10);

        buffer.addBits(16, 43690);
        buffer.addBits(32, 2863311530);
        buffer.addBits(64, 12297829382473034410);

        Debug.print("Buffer: " # debug_show Iter.toArray(buffer.bytes()));
        assert Iter.toArray(buffer.bytes()) == [170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170, 170];
    });
});