module main (
    input  int in,
    output int out
);
    int a, b, c;
    initial begin
        $display("a = %d", a);
        $display("b = %d", b);
        $display("c = %d", c);
        $finish;
    end
endmodule
