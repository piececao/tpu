`timescale 1ns/1ps

module pe_array_tb();

// output declaration of module pe_array
wire [31:0] output_value;
reg [31:0]x_input_array[15:0];
wire [31:0]x_inputs0 = x_input_array[0];
wire [31:0]x_inputs1 = x_input_array[1];
wire [31:0]x_inputs2 = x_input_array[2];
wire [31:0]x_inputs3 = x_input_array[3];
wire [31:0]x_inputs4 = x_input_array[4];
wire [31:0]x_inputs5 = x_input_array[5];
wire [31:0]x_inputs6 = x_input_array[6];
wire [31:0]x_inputs7 = x_input_array[7];
wire [31:0]x_inputs8 = x_input_array[8];
wire [31:0]x_inputs9 = x_input_array[9];
wire [31:0]x_inputs10 = x_input_array[10];
wire [31:0]x_inputs11 = x_input_array[11];
wire [31:0]x_inputs12 = x_input_array[12];
wire [31:0]x_inputs13 = x_input_array[13];
wire [31:0]x_inputs14 = x_input_array[14];
wire [31:0]x_inputs15 = x_input_array[15];

reg [31:0]y_input_array[15:0];
wire [31:0]y_inputs0 = y_input_array[0];
wire [31:0]y_inputs1 = y_input_array[1];
wire [31:0]y_inputs2 = y_input_array[2];
wire [31:0]y_inputs3 = y_input_array[3];
wire [31:0]y_inputs4 = y_input_array[4];
wire [31:0]y_inputs5 = y_input_array[5];
wire [31:0]y_inputs6 = y_input_array[6];
wire [31:0]y_inputs7 = y_input_array[7];
wire [31:0]y_inputs8 = y_input_array[8];
wire [31:0]y_inputs9 = y_input_array[9];
wire [31:0]y_inputs10 = y_input_array[10];
wire [31:0]y_inputs11 = y_input_array[11];
wire [31:0]y_inputs12 = y_input_array[12];
wire [31:0]y_inputs13 = y_input_array[13];
wire [31:0]y_inputs14 = y_input_array[14];
wire [31:0]y_inputs15 = y_input_array[15];

reg [7:0]x_position;
reg [7:0]y_position;

pe_array u_pe_array(
    .x_inputs0    	(x_inputs0     ),
    .x_inputs1    	(x_inputs1     ),
    .x_inputs2    	(x_inputs2     ),
    .x_inputs3    	(x_inputs3     ),
    .x_inputs4    	(x_inputs4     ),
    .x_inputs5    	(x_inputs5     ),
    .x_inputs6    	(x_inputs6     ),
    .x_inputs7    	(x_inputs7     ),
    .x_inputs8    	(x_inputs8     ),
    .x_inputs9    	(x_inputs9     ),
    .x_inputs10   	(x_inputs10    ),
    .x_inputs11   	(x_inputs11    ),
    .x_inputs12   	(x_inputs12    ),
    .x_inputs13   	(x_inputs13    ),
    .x_inputs14   	(x_inputs14    ),
    .x_inputs15   	(x_inputs15    ),
    .y_inputs0    	(y_inputs0     ),
    .y_inputs1    	(y_inputs1     ),
    .y_inputs2    	(y_inputs2     ),
    .y_inputs3    	(y_inputs3     ),
    .y_inputs4    	(y_inputs4     ),
    .y_inputs5    	(y_inputs5     ),
    .y_inputs6    	(y_inputs6     ),
    .y_inputs7    	(y_inputs7     ),
    .y_inputs8    	(y_inputs8     ),
    .y_inputs9    	(y_inputs9     ),
    .y_inputs10   	(y_inputs10    ),
    .y_inputs11   	(y_inputs11    ),
    .y_inputs12   	(y_inputs12    ),
    .y_inputs13   	(y_inputs13    ),
    .y_inputs14   	(y_inputs14    ),
    .y_inputs15   	(y_inputs15    ),
    .x_position   	(x_position    ),
    .y_position   	(y_position    ),
    .rdn          	(rdn           ),
    .output_value 	(output_value  ),
    .master_clock 	(master_clock  ),
    .reset_n      	(reset_n       )
);

reg rdn,master_clock,reset_n;
integer i,j;
initial begin
    rdn = 1;
    master_clock = 0;
    reset_n = 1;
    for(i = 0; i < 16; i++)begin
        //1.87
        x_input_array[i] = 32'h3FEF5C29;
    end
    for(i = 0; i < 16; i++)begin
        //2.123
        y_input_array[i] = 32'h4007DF3B;
    end
    #10
    reset_n = 0;
    #10
    reset_n = 1;

    forever #50 master_clock = ~master_clock;
end

integer i2,j2;
initial begin
    #1000
    for(i2 = 0; i2 < 16; i2=i2+1)begin
        //0
        x_input_array[i] = 32'h0;
    end
    for(i2 = 0; i2 < 16; i2=i2+1)begin
        //0
        y_input_array[i] = 32'h0;
    end
    #500
    for(i2=0;i2<16;i2=i2+1)begin
        for(j2=0;j2<16;j2=j2+1)begin
            $write("(%d,%d)",i2,j2);
        end
    end
end

initial begin
    $dumpfile("icarus/pe_array_tb.vcd");        
    $dumpvars(0, pe_array_tb);
    #2000 $finish();
end


endmodule