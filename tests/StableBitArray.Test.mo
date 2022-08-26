import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

import ActorSpec "./utils/ActorSpec";

import StableBitArray "../src/StableBitArray";

let {
    assertTrue; assertFalse; assertAllTrue; describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe("StableBitArray", [
        describe("With Nat8 Block", [
            it("init", do{
                let bitArray = StableBitArray.initNat8(64, true);
                Debug.print("with nat: " #debug_show StableBitArray.count(bitArray));

                assertTrue(StableBitArray.count(bitArray) == 64)
            }),
            it("set", do{
                let bitArray = StableBitArray.initNat8(8, false);
                
                StableBitArray.set(bitArray, 1, true);
                StableBitArray.set(bitArray, 3, true);
                StableBitArray.set(bitArray, 5, true);
                StableBitArray.set(bitArray, 6, true);
                StableBitArray.set(bitArray, 5, false);

                assertAllTrue([
                    StableBitArray.get(bitArray, 1),
                    StableBitArray.get(bitArray, 3),
                    not StableBitArray.get(bitArray, 5),
                    StableBitArray.get(bitArray, 6),
                    Iter.toArray(StableBitArray.toIter(bitArray)) == [
                        false, true, false, true, 
                        false, false, true, false
                    ]
                ])
            }),

            it("invert", do{
                let bitArray = StableBitArray.initNat8(8, false);

                StableBitArray.set(bitArray, 1, true);
                StableBitArray.set(bitArray, 3, true);
                StableBitArray.set(bitArray, 5, true);

                StableBitArray.invert(bitArray);

                assertAllTrue([
                    not StableBitArray.get(bitArray, 1),
                    StableBitArray.get(bitArray, 2),
                    not StableBitArray.get(bitArray, 3),
                    StableBitArray.get(bitArray, 4),
                    not StableBitArray.get(bitArray, 5),
                    StableBitArray.get(bitArray, 6),
                    StableBitArray.get(bitArray, 7),
                ])
            }),
        ]),

        describe("With Nat16 Block", [
            it("init", do{
                let bitArray = StableBitArray.initNat16(32, true);

                assertTrue(StableBitArray.count(bitArray) == 32)
            }),
        ]),
        describe("With Nat32 Block", [
            it("init", do{
                let bitArray = StableBitArray.initNat32(16, true);

                assertTrue(StableBitArray.count(bitArray) == 16)
            }),
        ]),
        describe("With Nat64 Block", [
            it("init", do{
                let bitArray = StableBitArray.initNat64(8, true);

                assertAllTrue([
                    StableBitArray.count(bitArray) == 8,
                    StableBitArray.get(bitArray, 4),
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
