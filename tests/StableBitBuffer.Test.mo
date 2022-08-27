import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

import ActorSpec "./utils/ActorSpec";

import SBB "../src/StableBitBuffer";
import NatLib "../src/NatLib";

let {
    assertTrue; assertFalse; assertAllTrue; describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe("StableBitBuffer", [
        describe("With Nat8 Block", [
            it("init", do{
                let bitbuffer = SBB.initNat8(64, true);

                assertTrue(SBB.count(bitbuffer) == 64)
            }),
            it("get", do{
                let bitbuffer = SBB.initNat8(3, true);

                assertAllTrue([
                    SBB.get(bitbuffer, 0),
                    SBB.get(bitbuffer, 1),
                    SBB.get(bitbuffer, 2),
                ])
            }),
            it("set", do{
                let bitbuffer = SBB.initNat8(5, false);
                
                SBB.set(bitbuffer, 1, true);
                SBB.set(bitbuffer, 3, true);

                assertAllTrue([
                    SBB.get(bitbuffer, 1),
                    SBB.get(bitbuffer, 3),
                    not SBB.get(bitbuffer, 0),
                    not SBB.get(bitbuffer, 2),
                    not SBB.get(bitbuffer, 4),
                ])
            }),
            it("add", do{
                let bitbuffer = SBB.new(#Nat8);
                let isEmptyAtStart = SBB.size(bitbuffer) == 0;

                SBB.add(bitbuffer, true);
                SBB.add(bitbuffer, false);
                SBB.add(bitbuffer, true);

                assertAllTrue([
                    isEmptyAtStart,
                    SBB.size(bitbuffer) == 3,
                    SBB.get(bitbuffer, 0) == true,
                    SBB.get(bitbuffer, 1) == false,
                    SBB.get(bitbuffer, 2) == true,
                ])
            }),
            it("removeLast", do{
                let bitbuffer = SBB.newPresized(#Nat8, 3);
                
                SBB.add(bitbuffer, true);
                SBB.add(bitbuffer, false);
                SBB.add(bitbuffer, true);

                assertAllTrue([
                    SBB.removeLast(bitbuffer) == ?true,
                    SBB.removeLast(bitbuffer) == ?false,
                    SBB.removeLast(bitbuffer) == ?true,
                    SBB.removeLast(bitbuffer) == null,
                ])
            }),
            it("setAll", do{
                let bitbuffer = SBB.newPresized(#Nat8, 3);

                SBB.add(bitbuffer, false);
                SBB.add(bitbuffer, true);
                SBB.add(bitbuffer, false);
                
                SBB.setAll(bitbuffer, true);

                let firstCheckIsTrue = 
                    SBB.get(bitbuffer, 0) and
                    SBB.get(bitbuffer, 1) and
                    SBB.get(bitbuffer, 2);

                SBB.setAll(bitbuffer, false);

                let secondCheckIsFalse = 
                    not SBB.get(bitbuffer, 0) and
                    not SBB.get(bitbuffer, 1) and
                    not SBB.get(bitbuffer, 2);

                assertAllTrue([
                    firstCheckIsTrue,
                    secondCheckIsFalse
                ])
            }), 
            it("invert", do{
                let bitbuffer = SBB.initNat8(5, false);

                SBB.set(bitbuffer, 1, true);
                SBB.set(bitbuffer, 3, true);

                SBB.invert(bitbuffer);

                assertAllTrue([
                    SBB.get(bitbuffer, 0),
                    SBB.get(bitbuffer, 2),
                    SBB.get(bitbuffer, 4),
                    not SBB.get(bitbuffer, 1),
                    not SBB.get(bitbuffer, 3),
                ])
            }),
            it("clear", do{
                let bitbuffer = SBB.initNat8(8, false);
                let initialised = SBB.size(bitbuffer) > 0;

                SBB.clear(bitbuffer);
                
                assertAllTrue([
                    initialised,
                    SBB.size(bitbuffer) == 0,
                ])
            }),
            it("clone", do{
                let a = SBB.initNat8(7, true);
                SBB.set(a, 3, false);
                SBB.set(a, 5, false);

                let b = SBB.clone(a);

                let blocksA = Iter.toArray(SBB.blocks(a));
                let blocksB = Iter.toArray(SBB.blocks(b));

                assertAllTrue([
                    SBB.size(a) == SBB.size(b),
                    blocksA == blocksB
                ])
            }),
            it("all", do{
                let bitbuffer = SBB.initNat8(8, true);
                let allTrueAtStart = SBB.all(bitbuffer);

                SBB.set(bitbuffer, 2, false);

                assertAllTrue([
                    allTrueAtStart,
                    SBB.all(bitbuffer) == false
                ])
            }),
            it("any", do{
                let bitbuffer = SBB.initNat8(8, false);
                let noneAtFirst = SBB.any(bitbuffer) == false;

                SBB.set(bitbuffer, 2, true);

                assertAllTrue([
                    noneAtFirst, 
                    SBB.any(bitbuffer) 
                ])
            }),
            it("none", do{
                let bitbuffer = SBB.initNat8(8, false);
                let allFalseAtStart = SBB.none(bitbuffer);

                SBB.set(bitbuffer, 2, true);

                assertAllTrue([
                    allFalseAtStart,
                    SBB.none(bitbuffer) == false
                ])
            }),
            describe("append", [
                it("101 + 010 == 101010", do{
                    let tests = Buffer.Buffer<Bool>(6);

                    let a = SBB.initNat8(3, true);
                    SBB.set(a, 1, false);

                    tests.add(SBB.size(a) == 3);

                    let b = SBB.initNat8(3, false);
                    SBB.set(b, 1, true);

                    tests.add(SBB.size(b) == 3);

                    SBB.append(a, b);

                    tests.add(SBB.size(a) == 6);
                    tests.add(SBB.toArray(a) == [
                        true, false, true,
                        false, true, false
                    ]);

                    assertAllTrue(tests.toArray())
                })
            ]),
            it("fromIter", do{
                let bits = [true, false, false, true, false];

                let bitbuffer = SBB.fromIter(#Nat8, bits.vals());

                assertAllTrue([
                    SBB.size(bitbuffer) == 5,
                    SBB.get(bitbuffer, 0) == true,
                    SBB.get(bitbuffer, 1) == false,
                    SBB.get(bitbuffer, 2) == false,
                    SBB.get(bitbuffer, 3) == true,
                    SBB.get(bitbuffer, 4) == false,
                ])
            }),
            it("toIter", do{
                let bitbuffer = SBB.init(#Nat8, 5, false);

                SBB.set(bitbuffer, 0, true);
                SBB.set(bitbuffer, 3, true);

                assertTrue( 
                    Iter.toArray(SBB.toIter(bitbuffer)) == [
                        true, false, false, true, false
                    ]
                )
            }),
        ]),

        describe("With Nat16 Block", [
            it("init", do{
                let bitbuffer = SBB.initNat16(32, true);

                assertTrue(SBB.count(bitbuffer) == 32)
            }),
        ]),
        describe("With Nat32 Block", [
            it("init", do{
                let bitbuffer = SBB.initNat32(16, true);

                assertTrue(SBB.count(bitbuffer) == 16)
            }),
        ]),
        describe("With Nat64 Block", [
            it("init", do{
                let bitbuffer = SBB.initNat64(8, true);

                assertAllTrue([
                    SBB.count(bitbuffer) == 8,
                    SBB.get(bitbuffer, 4),
                ])
            }),
        ])
    ])
]);

if(success == false){
  Debug.trap("\1b[46;41mTests failed\1b[0m");
}else{
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
