module intadd #(
    parameter WIDTH = 8
)(
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,

    output wire [WIDTH-1:0] Y,
    output wire overflow
);

wire [WIDTH:0]result;
assign result = A+B;

assign Y = result[WIDTH-1:0];
assign overflow = A[WIDTH-1] == B[WIDTH-1]
    ? A[WIDTH-1] != Y[WIDTH-1]
    : 0;

endmodule