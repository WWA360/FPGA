module ultrasonic
#(
    parameter FRE_CLK = 50
)
(
    input clk,
    input rst_n,

    input Echo,
    output reg Trig,

    output reg [15:0] distance,
    output reg distance_valid
);

localparam ONE_SECOND  = FRE_CLK * 1000000;
localparam ONE_MSECOND = FRE_CLK * 1000;
localparam ONE_USECOND = FRE_CLK;

localparam S_IDLE = 0;
localparam S_TRIG = 1;
localparam S_WAIT = 2;
localparam S_ECHO = 3;
localparam S_DONE = 4;

reg [31:0] idle_cnt;
reg [31:0] trig_cnt;
reg [31:0] echo_cnt;

reg [2:0] state;

always@(posedge clk) begin
    if(!rst_n) 
        state <= S_IDLE;
    else case(state)
        S_IDLE: if(idle_cnt >= ONE_MSECOND * 100)
                    state <= S_TRIG;
                else  
                    state <= S_IDLE;
        S_TRIG: if(trig_cnt >= ONE_USECOND * 16)
                    state <= S_WAIT;
                else 
                    state <= S_TRIG;
        S_WAIT: if(Echo == 1)
                    state <= S_ECHO;
                else 
                    state <= S_WAIT;
        S_ECHO: if(Echo == 0)
                    state <= S_DONE;
                else  
                    state <= S_ECHO;
        S_DONE: state <= S_IDLE;
        default:state <= S_IDLE;
    endcase
end

always@(posedge clk)
    if(!rst_n) Trig <= 0;
    else if(state == S_TRIG) Trig <= 1;
    else Trig <= 0;

always@(posedge clk)
    if(!rst_n) idle_cnt <= 0;
    else if(state == S_IDLE) idle_cnt <= idle_cnt + 1;
    else idle_cnt <= 0;

always@(posedge clk)
    if(!rst_n) trig_cnt <= 0;
    else if(state == S_TRIG) trig_cnt <= trig_cnt + 1;
    else trig_cnt <= 0;

always@(posedge clk)
    if(!rst_n) echo_cnt <= 0;
    else if(state == S_IDLE) echo_cnt <= 0;        
    else if(state == S_ECHO) echo_cnt <= echo_cnt + 1;
    else echo_cnt <= echo_cnt;                     

always@(posedge clk)
    if(!rst_n) distance_valid <= 0;
    else if(state == S_DONE) distance_valid <= 1;
    else distance_valid <= 0;

always@(posedge clk)
    if(!rst_n) distance <= 0;                       
    else if(state == S_DONE) distance <= (echo_cnt * 3597) >> 20; 
    else distance <= distance;

endmodule