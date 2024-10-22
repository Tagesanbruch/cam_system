module state_control (
    input clk,
    input rst_n,
    input [1:0] I_Key,
    output [4:0] state
);
parameter DB_BITS = 19;
wire [1: 0] db_key;
reg [1: 0] db_key_r;
reg [4:0] state_r;
assign state = state_r;
// 按键 - PWM
always @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        state_r <= 0;
    end
    else begin
        if(db_key_r[0] && !db_key[0])
			state_r <= state_r + 1'b1;
        else if(db_key_r[1] && !db_key[1])
			state_r <= state_r - 1'b1;
        else 
        	state_r <= state_r;
    end
end

always @(posedge clk or negedge rst_n ) begin
	if (!rst_n) begin
        db_key_r <= 2'b11;
    end
    else begin
		db_key_r <= db_key;
	end
end

// 消抖
debouncer #(
    .CNT_BITS(DB_BITS) // 计数器长度，令计数周期为 20ms 左右为宜
)
u_debouncer_0 (
    .clk(clk),
    .rst_n(rst_n),
    .in(I_Key[0]),
    .out(db_key[0])
);

debouncer #(
    .CNT_BITS(DB_BITS) // 计数器长度，令计数周期为 20ms 左右为宜
) u_debouncer_1 (
    .clk(clk),
    .rst_n(rst_n),
    .in(I_Key[1]),
    .out(db_key[1])
);
endmodule