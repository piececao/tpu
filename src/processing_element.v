`timescale 1ns/1ps

module processing_element(
    input wire [31:0]x_in,
    input wire [31:0]y_in,
    output reg [31:0]x_out,
    output reg [31:0]y_out,

    output reg [31:0]data_stored,
    input wire [31:0]readin,
    input wire wen,

    // Master clk
    input wire MCLK
);

// output declaration of module fp_mul
wire [31:0] mult_result;

fp_mul 
u_fp_mul(
    .a      	(x_in       ),
    .b      	(y_in       ),
    .result 	(mult_result  )
);

// output declaration of module fp_add
wire [31:0] add_result;

fp_add 
u_fp_add(
    .a      	(data_stored    ),
    .b      	(mult_result       ),
    .result 	(add_result  )
);

always @(negedge wen or posedge MCLK) begin
    if(wen == 0) begin
        data_stored <= readin;
        x_out <= 0;
        y_out <= 0;
    end
    else begin
        // data_stored = data_stored + x*y;
        data_stored <= add_result;
        x_out <= x_in;
        y_out <= y_in;
    end
end


endmodule