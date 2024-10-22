/* ---- encoding = utf-8 ---- */
`timescale 1ns / 1ps

/**
 * Description: 按键消抖
 * 按键边沿触发 cnt 从 0 开始计数，至全1停止
 * 屏蔽计数期间的按键电平变化以消抖
 *
*/

module debouncer
       #(
           parameter CNT_BITS = 19 // 计数器长度，令计数周期为 20ms 左右为宜
       )
       (
           input	wire clk,
           input	wire rst_n,
           input	wire in,
           output	reg out
       );

reg [CNT_BITS - 1: 0]	cnt;
reg cnt_en;
reg [2: 0] in_r;
wire rising, falling;

// 打拍
always@(posedge clk)
    in_r <= {in_r[1: 0], in};

assign in_changed = in_r[2] != in_r[1];
assign cnt_stop = cnt == {CNT_BITS{1'b1}};

always@(posedge clk or negedge rst_n) begin
    if (!rst_n || cnt_stop)
        cnt_en <= 0;
    else if (in_changed)
        cnt_en <= 1'b1;
end

always@(posedge clk) begin
    if (cnt_en == 0)
        out <= in_r[1];
end

always@(posedge clk) begin
    if (!cnt_en)
        cnt <= 0;
    else
        cnt <= cnt + 1'h1;
end

endmodule
