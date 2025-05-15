`timescale 1ns/1ps
module test();
// output declaration of module intadd
parameter WIDTH = 8;
wire [WIDTH-1:0] Y;
wire overflow;
reg [WIDTH-1:0]A;
reg [WIDTH-1:0]B;

intadd #(
    .WIDTH 	(8  ))
u_intadd(
    .A        	(A         ),
    .B        	(B         ),
    .Y        	(Y         ),
    .overflow 	(overflow  )
);

// output declaration of module intmult
wire [WIDTH-1:0] Y_mult;
wire overflow_m;

intmult #(
    .WIDTH 	(8  ))
u_intmult(
    .A        	(A         ),
    .B        	(B         ),
    .Y        	(Y_mult         ),
    .overflow 	(overflow_m  )
);



initial begin
    A = -7;
    B = 11;
    #50
    A = 2;
    B = 17;
    #50
    A = 127;
    B = 2;
end

initial begin
    $dumpfile("icarus/tadd_test_tb.vcd");        
    $dumpvars(0, test);
    #2000 $finish();
end

endmodule