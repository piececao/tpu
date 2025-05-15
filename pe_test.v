`timescale 1ns/1ps

module pe_test();

// output declaration of module processing_element
wire [31:0] x_out;
wire [31:0] y_out;
wire [31:0] data_stored;

processing_element u_processing_element(
    .x_in        	(x_in         ),
    .y_in        	(y_in         ),
    .x_out       	(x_out        ),
    .y_out       	(y_out        ),
    .data_stored 	(data_stored  ),
    .readin      	(readin       ),
    .wen         	(wen          ),
    .MCLK        	(MCLK         )
);

reg [31:0] x_in, y_in, readin;
reg wen, MCLK;

initial begin
    wen = 1;
    readin = 32'h3F9E8DB9; // 1.2387
    x_in = 32'h3FFFBE77; // 1.998
    y_in = 32'h3F698F1D; // 0.91234
    MCLK = 0;
    #20;
    wen = 0;
    #20;
    wen = 1;
    forever #50 MCLK = ~MCLK;
end


initial begin
    $dumpfile("icarus/pe_test.vcd");        
    $dumpvars(0, pe_test);
    #2000 $finish();
end
endmodule