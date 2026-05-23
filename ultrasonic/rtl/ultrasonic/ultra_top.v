module ultra_top
#(
    parameter LED_ON = 0,
    parameter FRE_CLK = 50 
)
(
    input clk,
    input rst_n,
    input Echo,

    output wire Trig,
    output wire [3:0] tube_bit,
    output wire [7:0] tube_seg,

    output wire bell
);

wire distance_valid;
wire [15:0] distance;
wire [15:0] bcd_distance; 

ultrasonic 
#(
    .FRE_CLK(FRE_CLK)
) ultrasonic_inst
(
    .clk             (clk)       ,
    .rst_n           (rst_n)     ,

    .Echo            (Echo)      ,
    .Trig            (Trig)      ,

    .distance        (distance)  ,
    .distance_valid  (distance_valid)
);


binary2bcd binary2bcd_inst (
    .bin_in  (distance[13:0]), 
    .bcd_out (bcd_distance)
);

tube_dive 
#(
    .LED_ON(LED_ON),
    .CLK_FRE(FRE_CLK) 
)
tube_dive_inst
(
    .clk        (clk)        ,
    .rst_n      (rst_n)      ,
    .d0         (bcd_distance[3:0])   , 
    .d1         (bcd_distance[7:4])   ,
    .d2         (bcd_distance[11:8])  ,
    .d3         (bcd_distance[15:12]) , 

    .tube_bit   (tube_bit)   ,
    .tube_seg   (tube_seg)
);
reg [4:0]tone_index;
always@(posedge clk)
if(!rst_n) tone_index<=0;
else if(distance>1000) tone_index<=1;
else if(distance>500) tone_index<=5;
else if(distance>300) tone_index<=10;
else if(distance>100) tone_index<=15;
else if(distance>0) tone_index<=20;
else tone_index<=0;

tone_index
#(
    .CLK_FRE(FRE_CLK) //MHz
)
tone_index_inst
(
    .tone_index(tone_index),
    .clk(clk),
    .rst_n(rst_n),

    .tone_out(bell)
);
endmodule