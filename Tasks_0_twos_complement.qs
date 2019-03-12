namespace Final_Project
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Extensions.Math;
    open Microsoft.Quantum.Extensions.Convert;

    // from "A novel reversible two's complement gate (TCG) and its quantum mapping"
    // by Ayan Chaudhuri ; Mahamuda Sultana ; Diganta Sengupta ; Atal Chaudhuri
    // https://ieeexplore.ieee.org/document/8073946
    operation TC_negate(TC : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC);
            if (N != 4) {
                fail "Eror: Only N = 4 Currently Implemented for TC_negate";
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

    operation TC_add_sub(sub : Bool, TC_A : Qubit[], TC_B : Qubit[], carry : Qubit, TC_target : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC_A);
            let P = Length(TC_B);
            let Q = Length(TC_target);
            if (N != P || N != Q) {
                fail "Eror: improper TC_add_sub usage";
            }

            if (sub) {
                X(carry);
                for (i in 0..N-1) {
                    X(TC_B[i]);
                }
            }

            for (i in 0..N-1) {
                SCG_bit_adder(TC_A[i], TC_B[i], carry, TC_target[i]);
            }

            if (sub) {
                for (i in 0..N-1) {
                    X(TC_B[i]);
                }
            }
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    function TC_construct_targ (b : Qubit, GARBAGE : Qubit[], N : Int) : Qubit[] {
        mutable targ = [GARBAGE[N-2]];
        for (i in 1 .. N-2) {
            set targ = targ + [GARBAGE[N-i-2]];
        }
        return targ + [b];
    }

    operation TC_comparator(d : Qubit[], dmax : Qubit[], b : Qubit, GARBAGE : Qubit[]) : Unit {
        body(...) {
            let N = Length(d);
            let P = Length(dmax);
            let Q = Length(GARBAGE);
            if (N != P || N != Q) {
                fail "Eror: improper TC_comparator usage";
            }

            TC_add_sub(true, dmax, d, GARBAGE[N-1], TC_construct_targ(b, GARBAGE, N));
            (ControlledOnBitString([true, false], X))([dmax[N-1], d[N-1]], b); // twos complement
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    operation TC_add_int(INT_A : Int, TC_B : Qubit[], carry : Qubit, TC_target : Qubit[]) : Unit {
        body(...) {
            let N = Length(TC_B);
            let P = Length(TC_target);
            if (N != P) {
                fail "Eror: improper TC_add_int usage";
            }
            using (TC_A = Qubit[N]) {
                TC_prepare(INT_A, TC_A);
                TC_add_sub(false, TC_A, TC_B, carry, TC_target);
                TC_prepare(INT_A, TC_A); // de-prepares TC_A
            }
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    // from "QUANTUM ADDER OF CLASSICAL NUMBERS"
    // by A.V. Cherkas and S.A. Chivilikhin
    // https://iopscience.iop.org/article/10.1088/1742-6596/735/1/012083/pdf
    operation Rzk (q : Qubit, k : Double) : Unit {
        body (...) {
            Rz(4.0*PI()/PowD(2.0, k), q);
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }

    operation efficient_adder (A : Qubit[], B : Qubit[]) : Unit {
        body (...) {
            let N = Length(A);
            let P = Length(B);
            if (N != P) {
                fail "Improper quantum adder usage";
            }   
            QFT((BigEndian(A)));
            for (i in 0..P-1) {
                for (j in 0..i) {
                    Controlled Rzk([A[N-j-1]], (B[P-i-1], ToDouble(i-j+1)));
                }
            }
            Adjoint QFT((BigEndian(A)));
        }
        adjoint auto;
        controlled auto;
        controlled adjoint auto;
    }
}
