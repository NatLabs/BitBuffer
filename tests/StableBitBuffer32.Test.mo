import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

import ActorSpec "./utils/ActorSpec";

import SBB_32 "../src/StableBitBuffer32";
import NatLib "../src/NatLib";

let {
    assertTrue; assertFalse; assertAllTrue; describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe("StableBitBuffer32", [
        it("init", do{
            let bitbuffer = SBB_32.init(64, true);

            assertTrue(SBB_32.count(bitbuffer) == 64)
        }),
        it("get", do{
            let bitbuffer = SBB_32.init(3, true);

            assertAllTrue([
                SBB_32.get(bitbuffer, 0),
                SBB_32.get(bitbuffer, 1),
                SBB_32.get(bitbuffer, 2),
            ])
        }),
        it("set", do{
            let bitbuffer = SBB_32.init(5, false);
            
            SBB_32.set(bitbuffer, 1, true);
            SBB_32.set(bitbuffer, 3, true);

            assertAllTrue([
                SBB_32.get(bitbuffer, 1),
                SBB_32.get(bitbuffer, 3),
                not SBB_32.get(bitbuffer, 0),
                not SBB_32.get(bitbuffer, 2),
                not SBB_32.get(bitbuffer, 4),
            ])
        }),
        it("fromIter", do{
            let bits = [true, false, false, true, false];

            let bitbuffer = SBB_32.fromIter(bits.vals());

            assertAllTrue([
                SBB_32.size(bitbuffer) == 5,
                SBB_32.get(bitbuffer, 0) == true,
                SBB_32.get(bitbuffer, 1) == false,
                SBB_32.get(bitbuffer, 2) == false,
                SBB_32.get(bitbuffer, 3) == true,
                SBB_32.get(bitbuffer, 4) == false,
            ])
        }),
        it("toIter", do{
            let bitbuffer = SBB_32.init(5, false);

            SBB_32.set(bitbuffer, 0, true);
            SBB_32.set(bitbuffer, 3, true);

            assertTrue( 
                Iter.toArray(SBB_32.toIter(bitbuffer)) == [
                    true, false, false, true, false
                ]
            )
        }),
        it("add", do{
            let bitbuffer = SBB_32.new();
            let isEmptyAtStart = SBB_32.size(bitbuffer) == 0;

            SBB_32.add(bitbuffer, true);
            SBB_32.add(bitbuffer, false);
            SBB_32.add(bitbuffer, true);

            assertAllTrue([
                isEmptyAtStart,
                SBB_32.size(bitbuffer) == 3,
                SBB_32.get(bitbuffer, 0) == true,
                SBB_32.get(bitbuffer, 1) == false,
                SBB_32.get(bitbuffer, 2) == true,
            ])
        }),
        it("removeLast", do{
            let bitbuffer = SBB_32.newPresized(3);
            
            SBB_32.add(bitbuffer, true);
            SBB_32.add(bitbuffer, false);
            SBB_32.add(bitbuffer, true);

            assertAllTrue([
                SBB_32.removeLast(bitbuffer) == ?true,
                SBB_32.removeLast(bitbuffer) == ?false,
                SBB_32.removeLast(bitbuffer) == ?true,
                SBB_32.removeLast(bitbuffer) == null,
            ])
        }),
        it("setAll", do{
            let bitbuffer = SBB_32.newPresized(3);

            SBB_32.add(bitbuffer, false);
            SBB_32.add(bitbuffer, true);
            SBB_32.add(bitbuffer, false);
            
            SBB_32.setAll(bitbuffer, true);

            let firstCheckIsTrue = 
                SBB_32.get(bitbuffer, 0) and
                SBB_32.get(bitbuffer, 1) and
                SBB_32.get(bitbuffer, 2);

            SBB_32.setAll(bitbuffer, false);

            let secondCheckIsFalse = 
                not SBB_32.get(bitbuffer, 0) and
                not SBB_32.get(bitbuffer, 1) and
                not SBB_32.get(bitbuffer, 2);

            assertAllTrue([
                firstCheckIsTrue,
                secondCheckIsFalse
            ])
        }), 
        it("invert", do{
            let bitbuffer = SBB_32.init(5, false);

            SBB_32.set(bitbuffer, 1, true);
            SBB_32.set(bitbuffer, 3, true);

            SBB_32.invert(bitbuffer);

            assertAllTrue([
                SBB_32.get(bitbuffer, 0),
                SBB_32.get(bitbuffer, 2),
                SBB_32.get(bitbuffer, 4),
                not SBB_32.get(bitbuffer, 1),
                not SBB_32.get(bitbuffer, 3),
            ])
        }),
        it("clear", do{
            let bitbuffer = SBB_32.init(8, false);
            let initialised = SBB_32.size(bitbuffer) > 0;

            SBB_32.clear(bitbuffer);
            
            assertAllTrue([
                initialised,
                SBB_32.size(bitbuffer) == 0,
            ])
        }),
        it("clone", do{
            let a = SBB_32.init(7, true);
            SBB_32.set(a, 3, false);
            SBB_32.set(a, 5, false);

            let b = SBB_32.clone(a);

            let blocksA = Iter.toArray(SBB_32.blocks(a));
            let blocksB = Iter.toArray(SBB_32.blocks(b));

            assertAllTrue([
                SBB_32.size(a) == SBB_32.size(b),
                blocksA == blocksB
            ])
        }),
        it("all", do{
            let bitbuffer = SBB_32.init(8, true);
            let allTrueAtStart = SBB_32.all(bitbuffer);

            SBB_32.set(bitbuffer, 2, false);

            assertAllTrue([
                allTrueAtStart,
                SBB_32.all(bitbuffer) == false
            ])
        }),
        it("any", do{
            let bitbuffer = SBB_32.init(8, false);
            let noneAtFirst = SBB_32.any(bitbuffer) == false;

            SBB_32.set(bitbuffer, 2, true);

            assertAllTrue([
                noneAtFirst, 
                SBB_32.any(bitbuffer) 
            ])
        }),
        it("none", do{
            let bitbuffer = SBB_32.init(8, false);
            let allFalseAtStart = SBB_32.none(bitbuffer);

            SBB_32.set(bitbuffer, 2, true);

            assertAllTrue([
                allFalseAtStart,
                SBB_32.none(bitbuffer) == false
            ])
        }),
        describe("append", [
            it("101 + 010 == 101010", do{
                let tests = Buffer.Buffer<Bool>(6);

                let a = SBB_32.init(3, true);
                SBB_32.set(a, 1, false);

                tests.add(SBB_32.size(a) == 3);

                let b = SBB_32.init(3, false);
                SBB_32.set(b, 1, true);

                tests.add(SBB_32.size(b) == 3);

                SBB_32.append(a, b);

                tests.add(SBB_32.size(a) == 6);
                tests.add(SBB_32.toArray(a) == [
                    true, false, true,
                    false, true, false
                ]);

                assertAllTrue(tests.toArray())
            })
        ]),
        it("grow", do{
            let bitbuffer = SBB_32.init(3, false);

            SBB_32.grow(bitbuffer, 3, true);

            let array = Iter.toArray(SBB_32.toIter(bitbuffer));

            assertAllTrue([
                SBB_32.size(bitbuffer) == 6,
                array == [
                    false, false, false,
                    true, true, true
                ]
            ])
        }),
    ]),
]);

if(success == false){
  Debug.trap("\1b[46;41mTests failed\1b[0m");
}else{
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
