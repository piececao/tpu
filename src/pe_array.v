module pe_array(
    input wire [31:0]x_inputs0,
    input wire [31:0]x_inputs1,
    input wire [31:0]x_inputs2,
    input wire [31:0]x_inputs3,
    input wire [31:0]x_inputs4,
    input wire [31:0]x_inputs5,
    input wire [31:0]x_inputs6,
    input wire [31:0]x_inputs7,
    input wire [31:0]x_inputs8,
    input wire [31:0]x_inputs9,
    input wire [31:0]x_inputs10,
    input wire [31:0]x_inputs11,
    input wire [31:0]x_inputs12,
    input wire [31:0]x_inputs13,
    input wire [31:0]x_inputs14,
    input wire [31:0]x_inputs15,

    input wire [31:0]y_inputs0,
    input wire [31:0]y_inputs1,
    input wire [31:0]y_inputs2,
    input wire [31:0]y_inputs3,
    input wire [31:0]y_inputs4,
    input wire [31:0]y_inputs5,
    input wire [31:0]y_inputs6,
    input wire [31:0]y_inputs7,
    input wire [31:0]y_inputs8,
    input wire [31:0]y_inputs9,
    input wire [31:0]y_inputs10,
    input wire [31:0]y_inputs11,
    input wire [31:0]y_inputs12,
    input wire [31:0]y_inputs13,
    input wire [31:0]y_inputs14,
    input wire [31:0]y_inputs15,

    input wire [7:0] x_position,
    input wire [7:0] y_position,
    input wire rdn,
    output reg [31:0] output_value,

    input wire master_clock,
    input wire reset_n
);

always @(negedge reset_n or negedge rdn) begin
    if(reset_n == 0)begin
        output_value <= 0;
    end
    else begin
        output_value <= data_out_arrays[x_position][y_position];
    end
end

wire [31:0]x_input_array[15:0];
wire [31:0]y_input_array[15:0];

wire [31:0]x_output_matrix[15:0][15:0];
wire [31:0]y_output_matrix[15:0][15:0];

wire [31:0]data_out_arrays[15:0][15:0];

    
genvar i,j;
generate
for(i=0;i<16;i=i+1) begin : rows
    for(j=0;j<16;j=j+1)begin : columns
    // 左上角的情况（第一行第一列位置）
    if(i==0 && j==0) begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin('d0),
            .wen(resetn),
            .x_in(x_input_array[0]),
            .y_in(y_input_array[0]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    // 第一行的情况
    else if(i==0 && j!=0)begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin('d0),
            .wen(resetn),
            .x_in(x_output_matrix[i][j-1]),
            .y_in(y_input_array[j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    // 第一列的情况
    else if(i!=0 && j==0)begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin('d0),
            .wen(resetn),
            .x_in(x_input_array[i]),
            .y_in(y_output_matrix[i-1][j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    else begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin('d0),
            .wen(resetn),
            .x_in(x_output_matrix[i][j-1]),
            .y_in(y_output_matrix[i-1][j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    end
end
endgenerate


assign x_input_array[0] = x_inputs0;
assign x_input_array[1] = x_inputs1;
assign x_input_array[2] = x_inputs2;
assign x_input_array[3] = x_inputs3;
assign x_input_array[4] = x_inputs4;
assign x_input_array[5] = x_inputs5;
assign x_input_array[6] = x_inputs6;
assign x_input_array[7] = x_inputs7;
assign x_input_array[8] = x_inputs8;
assign x_input_array[9] = x_inputs9;
assign x_input_array[10] = x_inputs10;
assign x_input_array[11] = x_inputs11;
assign x_input_array[12] = x_inputs12;
assign x_input_array[13] = x_inputs13;
assign x_input_array[14] = x_inputs14;
assign x_input_array[15] = x_inputs15;

assign y_input_array[0] = y_inputs0;
assign y_input_array[1] = y_inputs1;
assign y_input_array[2] = y_inputs2;
assign y_input_array[3] = y_inputs3;
assign y_input_array[4] = y_inputs4;
assign y_input_array[5] = y_inputs5;
assign y_input_array[6] = y_inputs6;
assign y_input_array[7] = y_inputs7;
assign y_input_array[8] = y_inputs8;
assign y_input_array[9] = y_inputs9;
assign y_input_array[10] = y_inputs10;
assign y_input_array[11] = y_inputs11;
assign y_input_array[12] = y_inputs12;
assign y_input_array[13] = y_inputs13;
assign y_input_array[14] = y_inputs14;
assign y_input_array[15] = y_inputs15;


endmodule