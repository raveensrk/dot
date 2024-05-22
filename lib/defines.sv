module defines ();
    int A;
    int B;
    int C;

    initial begin
        $display($realtime);

`ifndef A
        `define A =1
`endif
`ifndef B
        `define B =2
`endif
`ifndef C
        `define C =3
`endif

        $display("A = %0d", A);
        $display("B = %0d", B);
        $display("C = %0d", C);


        $dumpvars;
        $finish;
    end

endmodule : defines
