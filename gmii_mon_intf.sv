interface gmii_mon_intf (input clk, input [7:0] data, input valid, input err) ;

//logic [7:0] data;
//logic valid ;
//logic err ;

default clocking pclk @(posedge clk);
endclocking

//modport mon ( clocking pclk, input [7:0] data, input valid, input err );

endinterface
  
