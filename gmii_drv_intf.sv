interface gmii_drv_intf (input clk, output [7:0] data, output valid, output err,input config_busy) ;

//logic [7:0] data;
//logic valid ;
//logic err ;

default clocking pclk @(posedge clk);
endclocking

//modport mon ( clocking pclk, input [7:0] data, input valid, input err );

endinterface
  
