import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

import ActorSpec "./utils/ActorSpec";

import NatLib "../src/NatLib";

let {
    assertTrue; assertFalse; assertAllTrue; describe; it; skip; pending; run
} = ActorSpec;

let success = run([
    describe("NatLib Module", [
        it("add", do {
            assertAllTrue ([
                NatLib.add(#Nat8(23), #Nat8(27)) == #Nat8(50),
                NatLib.add(#Nat16(23), #Nat16(27)) == #Nat16(50),
                NatLib.add(#Nat32(23), #Nat32(27)) == #Nat32(50),
                NatLib.add(#Nat64(23), #Nat64(27)) == #Nat64(50),
            ])
        }),
    ])
]);

if(success == false){
  Debug.trap("\1b[46;41mTests failed\1b[0m");
}else{
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
