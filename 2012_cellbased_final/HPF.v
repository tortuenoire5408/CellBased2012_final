`timescale 1ns/10ps
module HPF(clk, reset, x_half, z_valid, z);
input   clk;
input   reset;
input [3:0] x_half;
output  z_valid;
output  [7:0]  z;
//==========================================================================
reg  z_valid;
reg  [7:0]  z;
//==========================================================================
parameter HH0 = 16'hFFF8,
          HH1 = 16'h0010,
          HH2 = 16'h0020,
          HH3 = 16'hFFA0,
          HH4 = 16'hFF40,
          HH5 = 16'h0140,
          HH6 = 16'h0280,
          HH7 = 16'hF800,
          HH8 = 16'h0800,
          HH9 = 16'hFD80,
          HH10 = 16'hFEC0,
          HH11 = 16'h00C0,
          HH12 = 16'h0060,
          HH13 = 16'hFFE0,
          HH14 = 16'hFFF0,
          HH15 = 16'h0008;
//==========================================================================
reg [2:0] cs, ns;
reg [4:0] cs_C, ns_C;
reg [7:0] x [15:0];
reg [35:0] sum;
//==========================================================================
parameter WAIT_X = 3'd0,
          GET_X0 = 3'd1,
          GET_X1 = 3'd2,
          CAL = 3'd3,
          OUT_Z = 3'd4,
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
    if(reset) cs <= RST;
    else cs <= ns;
end

// C current state
always@(posedge clk or posedge reset) begin
    if(reset) cs_C <= C_RST;
    else cs_C <= ns_C;
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
                if(cs_C == C15) ns = OUT_Z;
                else ns = CAL;
            end
            OUT_Z: ns = WAIT_X;
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
        OUT_Z: ns_C = C_WAIT;
        default: ns_C = C_WAIT;
    endcase
end

//==========================================================================

// x
integer i;
always@(posedge clk or posedge reset) begin
    if(cs == RST) begin
        for(i = 0; i <= 15; i = i + 1) begin
            x[i] <= 0;
        end
    end
    else if(ns == WAIT_X) begin
        for(i = 0; i <= 14; i = i + 1) begin
            x[i] <= x[i + 1];
        end
    end else if(ns == GET_X0) begin
        if(x_half) x[15][3:0] <= x_half;
        else x[15][3:0] <= 4'd0;
    end
    else if(ns == GET_X1) begin
        if(x_half)  x[15][7:4] <= x_half;
        else x[15][7:4] <= 4'd0;
    end
end

// sum
always@(*) begin
    if(cs == WAIT_X) sum = 0;
    else begin
        case (cs_C)
            C_RST: sum = 0;
            C0: sum = sum + {{16{x[15][7]}}, x[15]} * {{8{HH0[15]}}, HH0};
            C1: sum = sum + {{16{x[14][7]}}, x[14]} * {{8{HH1[15]}}, HH1};
            C2: sum = sum + {{16{x[13][7]}}, x[13]} * {{8{HH2[15]}}, HH2};
            C3: sum = sum + {{16{x[12][7]}}, x[12]} * {{8{HH3[15]}}, HH3};
            C4: sum = sum + {{16{x[11][7]}}, x[11]} * {{8{HH4[15]}}, HH4};
            C5: sum = sum + {{16{x[10][7]}}, x[10]} * {{8{HH5[15]}}, HH5};
            C6: sum = sum + {{16{x[9][7]}}, x[9]} * {{8{HH6[15]}}, HH6};
            C7: sum = sum + {{16{x[8][7]}}, x[8]} * {{8{HH7[15]}}, HH7};
            C8: sum = sum + {{16{x[7][7]}}, x[7]} * {{8{HH8[15]}}, HH8};
            C9: sum = sum + {{16{x[6][7]}}, x[6]} * {{8{HH9[15]}}, HH9};
            C10: sum = sum + {{16{x[5][7]}}, x[5]} * {{8{HH10[15]}}, HH10};
            C11: sum = sum + {{16{x[4][7]}}, x[4]} * {{8{HH11[15]}}, HH11};
            C12: sum = sum + {{16{x[3][7]}}, x[3]} * {{8{HH12[15]}}, HH12};
            C13: sum = sum + {{16{x[2][7]}}, x[2]} * {{8{HH13[15]}}, HH13};
            C14: sum = sum + {{16{x[1][7]}}, x[1]} * {{8{HH14[15]}}, HH14};
            C15: sum = sum + {{16{x[0][7]}}, x[0]} * {{8{HH15[15]}}, HH15};
            C_WAIT: sum = sum;
            default: sum = sum;
        endcase
    end
end

// z
always@(*) begin
    if(cs == OUT_Z) begin
        z = (sum[11])
            ? sum[19:12] + 8'd1
            : sum[19:12];
    end else z = 0;
end

//z_valid
always@(*) begin
    if(cs == OUT_Z && clk) begin
        z_valid = 1'b1;
    end else z_valid = 1'b0;
end

//==========================================================================
endmodule