`timescale 1ns/1ps
module fpma_tb();

// output declaration of module fp_mul
wire [31:0] result;

fp_mul u_fp_mul(
    .a      	(a       ),
    .b      	(b       ),
    .result 	(result  )
);

// output declaration of module fp_add
wire [31:0] result_add;

fp_add #(
    .GUARD 	(5  ))
u_fp_add(
    .a      	(a       ),
    .b      	(b       ),
    .result 	(result_add  )
);


reg [31:0]a, b;
initial begin
    a = 0;
    b = 0;
    #20
    a = 32'h40000000;
    b = 32'h40400000;
    #20
    a = 32'h3FFFFFFF;
    b = 32'h3FFFFFFF;
    #20
    a = 32'h3FE66666;
    b = 32'h40F66666;
end


initial begin
    $dumpfile("icarus/fpma_tb.vcd");
    $dumpvars(0, fpma_tb);
    #2000 $finish();
end
endmodule //fpma_tb
