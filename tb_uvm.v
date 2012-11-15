//-----------------------------------------------------
// Systemverilog+UVM testbench to exercise a 
// Xilinx coregen Virtex5 Trimac with a GMII interface
//-----------------------------------------------------

`timescale 1ps / 1ps

import uvm_pkg::*;

module tb_uvm;

   reg        reset;

  // EMAC0
  wire        tx_client_clk_0;
  wire [7:0]  tx_ifg_delay_0; 
  wire        rx_client_clk_0;
  wire [15:0] pause_val_0;
  wire        pause_req_0;

  // GMII wires
  wire        gmii_tx_clk_0;
  wire        gmii_tx_en_0;
  wire        gmii_tx_er_0;
  wire [7:0]  gmii_txd_0;
   reg 	      gmii_rx_clk_0;
  wire        gmii_rx_dv_0;
  wire        gmii_rx_er_0;
  wire [7:0]  gmii_rxd_0;

  // Clock wires
   reg 	      host_clk;
  reg         gtx_clk;
  reg         refclk;

   reg       config_busy;

  //----------------------------------------------------------------
  // Wire up Device Under Test
  //----------------------------------------------------------------
  v5_emac_v1_8_example_design dut
    (
    // Client Receiver Interface - EMAC0
    .EMAC0CLIENTRXDVLD               (),
    .EMAC0CLIENTRXFRAMEDROP          (),
    .EMAC0CLIENTRXSTATS              (),
    .EMAC0CLIENTRXSTATSVLD           (),
    .EMAC0CLIENTRXSTATSBYTEVLD       (),

    // Client Transmitter Interface - EMAC0
    .CLIENTEMAC0TXIFGDELAY           (tx_ifg_delay_0),
    .EMAC0CLIENTTXSTATS              (),
    .EMAC0CLIENTTXSTATSVLD           (),
    .EMAC0CLIENTTXSTATSBYTEVLD       (),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ             (pause_req_0),
    .CLIENTEMAC0PAUSEVAL             (pause_val_0),

     // Clock wire - EMAC0
    .GTX_CLK_0                       (gtx_clk),

    // GMII Interface - EMAC0
    .GMII_TXD_0                      (gmii_txd_0),
    .GMII_TX_EN_0                    (gmii_tx_en_0),
    .GMII_TX_ER_0                    (gmii_tx_er_0),
    .GMII_TX_CLK_0                   (gmii_tx_clk_0),
    .GMII_RXD_0                      (gmii_rxd_0),
    .GMII_RX_DV_0                    (gmii_rx_dv_0),
    .GMII_RX_ER_0                    (gmii_rx_er_0),
    .GMII_RX_CLK_0                   (gmii_rx_clk_0),


    .REFCLK                          (refclk),
        
    // Asynchronous Reset
    .RESET                           (reset)
    );

  //--------------------------------------------------------------------------
  // Flow Control is unused in this demonstration
  //--------------------------------------------------------------------------
  assign pause_req_0 = 1'b0;
  assign pause_val_0 = 16'b0;

  // IFG stretching not used in demo.
  assign tx_ifg_delay_0 = 8'b0;

  //--------------------------------------------------------------------------
  // Clock drivers
  //--------------------------------------------------------------------------

  // Drive GTX_CLK at 125 MHz
  initial                 // drives gtx_clk at 125 MHz
  begin
    gtx_clk <= 1'b0;
  	#10000;
    forever
    begin	 
      gtx_clk <= 1'b0;
      #4000;
      gtx_clk <= 1'b1;
      #4000;
    end
  end

   //Systemverilog interface instances to pass onto the
   //uvm testbench drivers and monitors
   gmii_mon_intf tx_mon_intf( .clk(gmii_tx_clk_0),
			      .data(gmii_txd_0),
			      .valid(gmii_tx_en_0),
			      .err(gmii_tx_er_0) );

   gmii_mon_intf rx_mon_intf( .clk(gmii_rx_clk_0),
			      .data(gmii_rxd_0),
			      .valid(gmii_rx_dv_0),
			      .err(gmii_rx_er_0) );

   gmii_drv_intf drv_intf( .clk(gmii_rx_clk_0),
			   .data(gmii_rxd_0),
			   .valid(gmii_rx_dv_0),
			   .err(gmii_rx_er_0),
			   .config_busy(config_busy) );      
   
   initial
     begin
	//Store interface handles in resource db
	uvm_resource_db #(virtual gmii_mon_intf )::set("tx_mon", "intf", tx_mon_intf,null);
	uvm_resource_db #(virtual gmii_mon_intf )::set("rx_mon", "intf", rx_mon_intf,null);
	uvm_resource_db #(virtual gmii_drv_intf )::set("drv", "intf", drv_intf,null);	
	run_test("default_run_test");
     end

  // Drive refclk at 200MHz
  initial
    begin
    refclk <= 1'b0;
    #10000;
    forever
    begin
      refclk <= 1'b1;
      #2500;
      refclk <= 1'b0;
      #2500;
    end
  end

  // drives gmii_rx_clk at 125 MHz for 1000Mb/s operation
  initial    
  begin
    gmii_rx_clk_0 <= 1'b0;
    #20000;
    forever
    begin
      #4000;
      gmii_rx_clk_0 <= 1'b1;
      #4000;
      gmii_rx_clk_0 <= 1'b0;
    end
  end
   
  // hostclk freq = 1/3 gtx_clk freq 
  initial
    begin
       host_clk <= 1'b0;
       #2000;
       forever
	 begin	 
	    host_clk <= 1'b1;
	    #12000;
	    host_clk <= 1'b0;
	    #12000;
	 end
    end

//Reset
   initial
     begin 
	$display("timing checks invalid");

	reset <= 1'b1;
	config_busy <= 0;

	#200000
	  config_busy <= 1;

	$display("reset design");

	reset <= 1'b1;
	#4000000
	  reset <= 1'b0;
	#200000;
     
	$display("timing checks valid");
	#15000000;
	#100000	    ;
	config_busy <= 0;
  end 

endmodule
