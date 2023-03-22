import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";

import ActorSpec "utils/ActorSpec";
import BitBuffer "../src/BitBuffer";

let {
    assertTrue;
    assertFalse;
    assertAllTrue;
    describe;
    it;
    skip;
    pending;
    run;
} = ActorSpec;

func bitbuffer_tests<NatX>(title : Text, NatLib: BitBuffer.NatLib<NatX>) : ActorSpec.Group {
    describe(
        title,
        [
            it(
                "init",
                do {
                    let bitbuffer = BitBuffer.init(NatLib, 64, true);
                    assertTrue(bitbuffer.bitcount(true) == 64);
                },
            ),
            it(
                "get",
                do {
                    let bitbuffer = BitBuffer.init(NatLib, 3, true);

                    assertAllTrue([
                        bitbuffer.get(0),
                        bitbuffer.get(1),
                        bitbuffer.get(2),
                    ]);
                },
            ),
            it(
                "put",
                do {
                    let bitbuffer = BitBuffer.init(NatLib, 5, false);

                    bitbuffer.put(1, true);
                    bitbuffer.put(3, true);

                    assertAllTrue([
                        bitbuffer.get(1),
                        bitbuffer.get(3),
                        not bitbuffer.get(0),
                        not bitbuffer.get(2),
                        not bitbuffer.get(4),
                    ]);
                },
            ),
            it(
                "add",
                do {
                    let bitbuffer = BitBuffer.BitBuffer(NatLib, 8);
                    let isEmptyAtStart = bitbuffer.size() == 0;

                    bitbuffer.add(true);
                    bitbuffer.add(false);
                    bitbuffer.add(true);

                    assertAllTrue([
                        isEmptyAtStart,
                        bitbuffer.size() == 3,
                        bitbuffer.get(0) == true,
                        bitbuffer.get(1) == false,
                        bitbuffer.get(2) == true,
                    ]);
                },
            ),
            it(
                "addBits",
                do {
                    let bitbuffer = BitBuffer.BitBuffer(NatLib, 8);
                    bitbuffer.addBits(5, NatLib.fromNat(21));

                    let res = [
                        bitbuffer.size() == 5,
                        bitbuffer.get(0) == true,
                        bitbuffer.get(1) == false,
                        bitbuffer.get(2) == true,
                        bitbuffer.get(3) == false,
                        bitbuffer.get(4) == true
                    ];

                    Debug.print(debug_show(res));
                    assertAllTrue(
                        res
                    );
                },
            ),
            it("getBits", do {
                true
            }),
            it(
                "removeLast",
                do {
                    let bitbuffer = BitBuffer.BitBuffer(Nat8, 3);

                    bitbuffer.add(true);
                    bitbuffer.add(false);
                    bitbuffer.add(true);

                    assertAllTrue([
                        bitbuffer.removeLast() == ?true,
                        bitbuffer.removeLast() == ?false,
                        bitbuffer.removeLast() == ?true,
                        bitbuffer.removeLast() == null,
                    ]);
                },
            ),
            it(
                "invert",
                do {
                    let bitbuffer = BitBuffer.init(NatLib, 5, false);

                    bitbuffer.put(1, true);
                    bitbuffer.put(3, true);

                    bitbuffer.invert();

                    assertAllTrue([
                        bitbuffer.get(0),
                        bitbuffer.get(2),
                        bitbuffer.get(4),
                        not bitbuffer.get(1),
                        not bitbuffer.get(3),
                    ]);
                },
            ),
            it(
                "clear",
                do {
                    let bitbuffer = BitBuffer.init(NatLib, 5, false);
                    let initialised = bitbuffer.size() > 0;

                    bitbuffer.clear();

                    assertAllTrue([
                        initialised,
                        bitbuffer.size() == 0,
                    ]);
                },
            ),
            
            // it(
            //     "any",
            //     do {
            //         let bitbuffer = BitBuffer.init(NatLib, 5, false);
            //         let noneAtFirst = SBB.any(bitbuffer) == false;

            //         bitbuffer.put(2, true);

            //         assertAllTrue([
            //             noneAtFirst,
            //             SBB.any(bitbuffer),
            //         ]);
            //     },
            // ),
            // it(
            //     "none",
            //     do {
            //         let bitbuffer = BitBuffer.init(NatLib, 5, false);
            //         let allFalseAtStart = SBB.none(bitbuffer);

            //         bitbuffer.put(2, true);

            //         assertAllTrue([
            //             allFalseAtStart,
            //             SBB.none(bitbuffer) == false,
            //         ]);
            //     },
            // ),
            // it(
            //     "clone",
            //     do {
            //         let a = BitBuffer.init(NatLib, 7, false);
            //         SBB.set(a, 3, false);
            //         SBB.set(a, 5, false);

            //         let b = SBB.clone(a);

            //         let blocksA = Iter.toArray(SBB.blocks(a));
            //         let blocksB = Iter.toArray(SBB.blocks(b));

            //         assertAllTrue([
            //             SBB.size(a) == SBB.size(b),
            //             blocksA == blocksB,
            //         ]);
            //     },
            // ),
            // it(
            //     "all",
            //     do {
            //         let bitbuffer = BitBuffer.init(NatLib, 5, true);
            //         let allTrueAtStart = SBB.all(bitbuffer);

            //         bitbuffer.put(2, false);

            //         assertAllTrue([
            //             allTrueAtStart,
            //             SBB.all(bitbuffer) == false,
            //         ]);
            //     },
            // ),
            // describe(
            //     "append",
            //     [
            //         it(
            //             "101 + 010 == 101010",
            //             do {
            //                 let tests = Buffer.Buffer<Bool>(6);

            //                 let a = SBB.init(#Nat8, 3, true);
            //                 SBB.set(a, 1, false);

            //                 tests.add(SBB.size(a) == 3);

            //                 let b = SBB.init(#Nat8, 3, false);
            //                 SBB.set(b, 1, true);

            //                 tests.add(SBB.size(b) == 3);

            //                 SBB.append(a, b);

            //                 tests.add(SBB.size(a) == 6);
            //                 tests.add(
            //                     SBB.toArray(a) == [
            //                         true,
            //                         false,
            //                         true,
            //                         false,
            //                         true,
            //                         false,
            //                     ],
            //                 );

            //                 assertAllTrue(tests.toArray());
            //             },
            //         )
            //     ],
            // ),
            // it(
            //     "grow",
            //     do {
            //         let bitbuffer = SBB.init(#Nat8, 3, false);

            //         SBB.grow(bitbuffer, 3, true);

            //         let array = Iter.toArray(SBB.toIter(bitbuffer));

            //         assertAllTrue([
            //             bitbuffer.size() == 6,
            //             array == [
            //                 false,
            //                 false,
            //                 false,
            //                 true,
            //                 true,
            //                 true,
            //             ],
            //         ]);
            //     },
            // ),

        ],
    );
};

let success = run([
    describe(
        "BitBuffer",
        [
            describe("BitBuffer with Nat8 word type", [
                it("getBits", do{
                    let bitbuffer = BitBuffer.fromWords<Nat8>(Nat8, [21, 224, 31]);
                    let res = [
                        bitbuffer.getBits(0, 8),
                        bitbuffer.getBits(8, 5),
                        bitbuffer.getBits(13, 8),
                    ];
                    Debug.print("res: ++ " # debug_show res);
                    Debug.print(debug_show BitBuffer.toWords(bitbuffer));
                    assertAllTrue([res == [21, 0, 255]])
                }),
                it("putBits", do {
                    let bitbuffer = BitBuffer.fromWords<Nat8>(Nat8, [0, 0, 0]);

                    bitbuffer.putBits(0, 5, 21);
                    bitbuffer.putBits(5, 8, 255);
                    bitbuffer.putBits(13, 7, 64);

                    assertAllTrue([
                        bitbuffer.getBits(0, 5) == 21,
                        bitbuffer.getBits(5, 8) == 255,
                        bitbuffer.getBits(13, 7) == 64,
                    ])
                }),
                it("addBits", do {
                    let bitbuffer = BitBuffer.BitBuffer<Nat8>(Nat8, 8);
                    bitbuffer.addBits(8, 21);
                    bitbuffer.addBits(5, 0);
                    bitbuffer.addBits(8, 255);

                    assertAllTrue([
                        bitbuffer.size() == 21,
                        Iter.toArray(bitbuffer.words()) == [21, 224, 31],
                    ]);
                }),
                it("addByte", do{
                    let bitbuffer = BitBuffer.BitBuffer<Nat8>(Nat8, 8);
                    bitbuffer.addByte(21);
                    bitbuffer.addByte(255);

                    assertAllTrue([
                        bitbuffer.size() == 16,
                        Iter.toArray(bitbuffer.words()) == [21, 255],
                    ]);
                }),
                it("fromWords", do{
                    let bitbuffer = BitBuffer.fromWords<Nat8>(Nat8, [21, 224, 31]);
                    assertAllTrue([
                        bitbuffer.size() == 24,
                        BitBuffer.toWords(bitbuffer) == [21, 224, 31],
                    ])
                }),
                it("insertBits", do{
                    let bitbuffer = BitBuffer.BitBuffer<Nat8>(Nat8, 21);

                    Debug.print("insertBits");
                    let res = [
                        do {
                            bitbuffer.addBits(2, 3);
                            Debug.print("test: getBits(0, 2): " # debug_show bitbuffer.getBits(0, 2));
                            bitbuffer.getBits(0, 2) == 3 
                        },
                        bitbuffer.size() == 2,
                        do {
                            bitbuffer.insertBits(1, 3, 2);
                            Debug.print("test: getBits(1, 3): " # debug_show bitbuffer.getBits(1, 3));
                            bitbuffer.getBits(1, 3) == 2
                        },
                        bitbuffer.size() == 5,

                        do{
                            bitbuffer.insertBits(0, 3, 0);
                            Debug.print("test: getBits(0, 3): " # debug_show bitbuffer.getBits(0, 3));
                            bitbuffer.getBits(0, 3) == 0
                        },
                        bitbuffer.size() == 8,

                    ];

                    Debug.print("res" # debug_show res);

                    assertAllTrue(res)

                })
            ]),
            // bitbuffer_tests<Nat8>("With Nat8 Word", Nat8),
            // bitbuffer_tests<Nat16>("With Nat16 Word", Nat16),
            // bitbuffer_tests<Nat32>("With Nat32 Word", Nat32),
            // bitbuffer_tests<Nat64>("With Nat64 Word", Nat64),
        ],
    )
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
