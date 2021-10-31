`timescale 1ns/10ps
module MBF(clk, reset, y_valid, z_valid, y, z);
input   clk;
input   reset;
output  y_valid;
output  z_valid;
output  [7:0]  y;
output  [7:0]  z;
//==========================================================================
wire [3:0] Q;
wire [9:0] A;
reg CEN;
reg [10:0] Ai;
//==========================================================================

//CEN
always@(*) begin
    if(reset) CEN = 1'd1;
    else if(U_LPF.cs <= 3'd1 && U_HPF.cs <= 3'd1) CEN = 1'd0;
    else CEN = 1'd1;
end

//Ai
always@(posedge clk or posedge reset) begin
    if(U_LPF.ns <= 3'd1 && U_HPF.ns <= 3'd1) begin
        if(Ai >= 10'd0) Ai <= Ai + 1;
        else Ai <= 10'd0;
    end
end

//A
assign A = (Ai <= 1023) ? Ai[9:0] : 10'bz;

//==========================================================================
rom_1024x4_t13 U_ROM(.Q(Q), .CLK(clk), .CEN(CEN), .A(A));

LPF U_LPF(.clk(clk), .reset(reset), .x_half(Q), .y_valid(y_valid), .y(y));

HPF U_HPF(.clk(clk), .reset(reset), .x_half(Q), .z_valid(z_valid), .z(z));
//==========================================================================
endmodule
