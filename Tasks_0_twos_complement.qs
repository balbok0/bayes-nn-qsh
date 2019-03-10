namespace Final_Project
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Convert;

    // from "A novel reversible two's complement gate (TCG) and its quantum mapping"
    // by Ayan Chaudhuri ; Mahamuda Sultana ; Diganta Sengupta ; Atal Chaudhuri
    // https://ieeexplore.ieee.org/document/8073946

    // test if handles negatives properly
    operation TC_prepare(a : Int, TC : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC);
            mutable bools = int_to_boolsBE(a);
            for (i in 0..N-1) {
                if (bools[i]) {
                    X(TC[i]);
                }
            }
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    operation TC_negate(TC : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC);
            if (N != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }

            Controlled X([TC[0], TC[1], TC[2]], TC[3]);
            Controlled X([TC[1], TC[2]], TC[3]);
            Controlled X([TC[0], TC[2]], TC[3]);
            Controlled X([TC[0], TC[1]], TC[2]);
            Controlled X([TC[2]], TC[3]);
            Controlled X([TC[1]], TC[3]);
            Controlled X([TC[1]], TC[2]);
            Controlled X([TC[0]], TC[3]);
            Controlled X([TC[0]], TC[2]);
            Controlled X([TC[0]], TC[1]);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    operation TC_add(TC_A : Qubit[], TC_B : Qubit[], TC_target : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC_A);
            let P = Length(TC_B);
            let Q = Length(TC_target);
            if (N != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }
            if (P != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }
            if (Q != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }
            using (GARBAGE = Qubit[3]) {
                using (CARRY = Qubit[2]) {
                    SCG([TC_A[0], GARBAGE[0], TC_B[0], CARRY[0]], [GARBAGE[1], TC_target[0], CARRY[1], GARBAGE[2]]);
                    Reset(CARRY[0]); Reset(GARBAGE[0]);
                    SCG([TC_A[1], GARBAGE[0], TC_B[1], CARRY[1]], [GARBAGE[1], TC_target[1], CARRY[0], GARBAGE[2]]);
                    Reset(CARRY[1]); Reset(GARBAGE[0]);
                    SCG([TC_A[2], GARBAGE[0], TC_B[2], CARRY[0]], [GARBAGE[1], TC_target[2], CARRY[1], GARBAGE[2]]);
                    Reset(CARRY[0]); Reset(GARBAGE[0]);
                    SCG([TC_A[3], GARBAGE[0], TC_B[3], CARRY[1]], [GARBAGE[1], TC_target[3], CARRY[0], GARBAGE[2]]);
                    ResetAll(CARRY); ResetAll(GARBAGE);
                }
            }
        }
    }

    // add sub and cmp here

    operation TC_add_int(INT_A : Int, TC_B : Qubit[], TC_target : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC_B);
            let P = Length(TC_target);
            if (N != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }
            if (P != 4) {
                fail "Eror: Only N = 4 Currently Implemented";
            }
            using (TC_A = Qubit[4]) {
                TC_prepare(INT_A, TC_A);
                TC_add(TC_A, TC_B, TC_target);
                ResetAll(TC_A);
            }  
        }
    }


}

