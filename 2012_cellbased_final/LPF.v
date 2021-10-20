`timescale 1ns/10ps
module LPF(clk, reset, x_half, y_valid, y);
input   clk;
input   reset;
input [3:0] x_half;
output  y_valid;
output  [7:0]  y;
//==========================================================================
reg  y_valid;
reg  [7:0]  y;
//==========================================================================
parameter LH0 = 16'hFFF8,
          LH1 = 16'hFFF0,
          LH2 = 16'h0020,
          LH3 = 16'h0060,
          LH4 = 16'hFF40,
          LH5 = 16'hFEC0,
          LH6 = 16'h0280,
          LH7 = 16'h0800,
          LH8 = 16'h0800,
          LH9 = 16'h0280,
          LH10 = 16'hFEC0,
          LH11 = 16'hFF40,
          LH12 = 16'h0060,
          LH13 = 16'h0020,
          LH14 = 16'hFFF0,
          LH15 = 16'hFFF8;
//==========================================================================
reg clk_div;
reg [2:0] cs, ns;
reg [4:0] cs_C, ns_C;
reg [7:0] x [15:0];
reg [27:0] sum;
//==========================================================================
parameter WAIT_X = 3'd0,
          GET_X0 = 3'd1,
          GET_X1 = 3'd2,
          CAL = 3'd3,
          OUT_Y = 3'd4,
          RST = 3'd5;
parameter C0 = 5'd0,
          C1 = 5'd1,
          C2 = 5'd2,
          C3 = 5'd3,
          C4 = 5'd4,
          C5 = 5'd5,
          C6 = 5'd6,
          C7 = 5'd7,
          C8 = 5'd8,
          C9 = 5'd9,
          C10 = 5'd10,
          C11 = 5'd11,
          C12 = 5'd12,
          C13 = 5'd13,
          C14 = 5'd14,
          C15 = 5'd15,
          C_RST = 5'd16,
          C_WAIT = 5'd17;
//==========================================================================

//current state
always@(posedge clk or posedge reset) begin
    if(reset) cs = RST;
    else cs = ns;
end

// C current state
always@(posedge clk or posedge reset) begin
    if(reset) cs_C = C_RST;
    else cs_C = ns_C;
end

//next state
always@(*) begin
    if(cs == RST) ns = WAIT_X;
    else begin
        case(cs)
            WAIT_X: ns = GET_X0;
            GET_X0: ns = GET_X1;
            GET_X1: ns = CAL;
            CAL: begin
                if(cs_C == C15) ns = OUT_Y;
                else ns = CAL;
            end
            OUT_Y: ns = WAIT_X;
            default: ns = RST;
        endcase
    end
end

// calculate next state
always@(*) begin
    case(cs)
        RST: ns_C = C_WAIT;
        WAIT_X: ns_C = C_WAIT;
        GET_X0: ns_C = C_WAIT;
        GET_X1: ns_C = C0;
        CAL: begin
            case(cs_C)
            C0: ns_C = C1;
            C1: ns_C = C2;
            C2: ns_C = C3;
            C3: ns_C = C4;
            C4: ns_C = C5;
            C5: ns_C = C6;
            C6: ns_C = C7;
            C7: ns_C = C8;
            C8: ns_C = C9;
            C9: ns_C = C10;
            C10: ns_C = C11;
            C11: ns_C = C12;
            C12: ns_C = C13;
            C13: ns_C = C14;
            C14: ns_C = C15;
            C15: ns_C = C_WAIT;
            default: ns = C_WAIT;
        endcase
        end
        OUT_Y: ns_C = C_WAIT;
        default: ns_C = C_WAIT;
    endcase
end

//==========================================================================

// x
integer i;
always@(*) begin
    if(cs == RST) begin
        for(i = 0; i <= 15; i = i + 1) begin
            x[i] = 0;
        end
    end
    else if(cs == WAIT_X) begin
        for(i = 0; i <= 14; i = i + 1) begin
            x[i] = x[i + 1];
        end
    end else if(cs == GET_X0) begin
        if(x_half) x[15][3:0] = x_half;
        else x[15][3:0] = 4'd0;
    end
    else if(cs == GET_X1) begin
        if(x_half)  x[15][7:4] = x_half;
        else x[15][7:4] = 4'd0;
    end
end

// sum
always@(*) begin
    if(cs == WAIT_X) sum = 0;
    else begin
        case (cs_C)
            C_RST: sum = 0;
            C0: sum = sum + {{16{x[15][7]}}, x[15]} * {{8{LH0[15]}}, LH0};
            C1: sum = sum + {{16{x[14][7]}}, x[14]} * {{8{LH1[15]}}, LH1};
            C2: sum = sum + {{16{x[13][7]}}, x[13]} * {{8{LH2[15]}}, LH2};
            C3: sum = sum + {{16{x[12][7]}}, x[12]} * {{8{LH3[15]}}, LH3};
            C4: sum = sum + {{16{x[11][7]}}, x[11]} * {{8{LH4[15]}}, LH4};
            C5: sum = sum + {{16{x[10][7]}}, x[10]} * {{8{LH5[15]}}, LH5};
            C6: sum = sum + {{16{x[9][7]}}, x[9]} * {{8{LH6[15]}}, LH6};
            C7: sum = sum + {{16{x[8][7]}}, x[8]} * {{8{LH7[15]}}, LH7};
            C8: sum = sum + {{16{x[7][7]}}, x[7]} * {{8{LH8[15]}}, LH8};
            C9: sum = sum + {{16{x[6][7]}}, x[6]} * {{8{LH9[15]}}, LH9};
            C10: sum = sum + {{16{x[5][7]}}, x[5]} * {{8{LH10[15]}}, LH10};
            C11: sum = sum + {{16{x[4][7]}}, x[4]} * {{8{LH11[15]}}, LH11};
            C12: sum = sum + {{16{x[3][7]}}, x[3]} * {{8{LH12[15]}}, LH12};
            C13: sum = sum + {{16{x[2][7]}}, x[2]} * {{8{LH13[15]}}, LH13};
            C14: sum = sum + {{16{x[1][7]}}, x[1]} * {{8{LH14[15]}}, LH14};
            C15: sum = sum + {{16{x[0][7]}}, x[0]} * {{8{LH15[15]}}, LH15};
            C_WAIT: sum = sum;
            default: sum = sum;
        endcase
    end
end

// y
always@(*) begin
    if(cs == OUT_Y) begin
        y = (sum[11])
            ? sum[19:12] + 8'd1
            : sum[19:12];
    end
end

//y_valid
always@(*) begin
    if(cs == OUT_Y && clk) begin
        y_valid = 1'b1;
    end else y_valid = 1'b0;
end

//==========================================================================
endmodule