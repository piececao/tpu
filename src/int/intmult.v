module intmult #(
    parameter WIDTH = 8
)(
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,
    output wire [WIDTH-1:0] Y,
    output wire overflow
);

reg [WIDTH+WIDTH-1:0]shift[WIDTH-1:0];
reg [WIDTH+WIDTH-1:0]Y_reg;
wire [WIDTH+WIDTH-1:0]A_wide;

assign A_wide = A;
assign Y = Y_reg[WIDTH-1:0];
assign overflow = !(~|Y_reg[WIDTH+WIDTH-1:WIDTH] | &Y_reg[WIDTH+WIDTH-1:WIDTH]);

integer i;
always @(*) begin
    Y_reg = 0;
    for(i = 0; i < WIDTH; i=i+1)begin
        shift[i] = B[i] ? (A_wide << i) : 0;
    end
    for(i = 0; i < WIDTH; i=i+1)begin
        Y_reg = Y_reg + shift[i];
    end
end

endmodule