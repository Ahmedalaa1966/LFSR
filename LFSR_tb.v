module LFSR_testbench ();
    
    /////////////////////////////////////////////////////////
    ///////////////////// DUT signals ////////////////////////
    /////////////////////////////////////////////////////////
    wire CRC_tb ;
    wire Valid_tb ;
    reg  DATA_tb ;
    reg  ACTIVE_tb ;
    reg  CLK_tb ;
    reg  Reset_tb ;

    /////////////////////////////////////////////////////////
    ///////////////////// DUT_instatioiation ////////////////
    /////////////////////////////////////////////////////////

    LFSR DUT(
        .DATA(DATA_tb)      ,
        .ACTIVE(ACTIVE_tb) ,
        .CLK(CLK_tb)       ,
        .RST(Reset_tb)     ,
        .CRC(CRC_tb)       ,
        .valid(valid_tb) 
    );

    /////////////////////////////////////////////////////////
    ///////////////////// loop counter //////////////////////
    /////////////////////////////////////////////////////////

    integer operation ;

    
    /////////////////////////////////////////////////////////
    ///////////////////// Parameters ////////////////////////
    /////////////////////////////////////////////////////////

    parameter Clock_PERIOD =10 ;
    parameter Test_Cases   =10 ;
    parameter LFSR_width   = 8 ;


    /////////////////////////////////////////////////////////
    ///////////////////// Memories //////////////////////////
    /////////////////////////////////////////////////////////

    reg    [LFSR_width-1:0]   data_in      [Test_Cases-1:0] ;
    reg    [LFSR_width-1:0]   Expec_Outs   [Test_Cases-1:0] ;

    ////////////////////////////////////////////////////////
    ////////////////// Clock Generator  ////////////////////
    ////////////////////////////////////////////////////////

    always #(Clock_PERIOD/2)  CLK_tb = ~CLK_tb ;


    /////////////////////////////////////////////////////////
    ///////////////////// Intial block  //////////////////////
    /////////////////////////////////////////////////////////

    initial 
    begin

        // System Functions
        $dumpfile("LFSR_DUMP.vcd") ;       
        $dumpvars; 

        //read inputs and expected outp[ut file
        $readmemh("DATA_h.txt", data_in);
        $readmemh("Expec_Out_h.txt", Expec_Outs);

        // call the inttializing task
        intialize() ;

        // call the reset task
        rst() ;

        for (operation = 0 ;operation< Test_Cases ; operation = operation+1 ) begin
            do_oper( data_in[operation] ) ;
            check_out( Expec_Outs[operation] , operation ) ;
        end

        #100
        $stop ;

    end



    /////////////////////////////////////////////////////////
    ///////////////////// Task declaration  /////////////////
    /////////////////////////////////////////////////////////


    task intialize ;
        begin
            CLK_tb    = 0 ;
            Reset_tb  = 0;
            DATA_tb   = 0;
            ACTIVE_tb = 0;
        end
    endtask

    task rst ;
        begin
            Reset_tb =  'b1;
            #(Clock_PERIOD)
            Reset_tb  = 'b0;
            #(Clock_PERIOD)
            Reset_tb  = 'b1;  
        end
    endtask


    task do_oper ;
        input [LFSR_width-1:0]  data_in_tb ;
        integer i ;
        begin
            ACTIVE_tb = 1 ;
            for ( i = 0 ; i< LFSR_width ; i = i+1 ) begin
                #(Clock_PERIOD) DATA_tb = data_in_tb [i] ;
            end
            ACTIVE_tb = 0 ;
       end
    endtask

    task check_out ;
        input [LFSR_width-1:0] out_data_tb ; 
        reg   [LFSR_width-1:0] DUT_out ;
        input integer          operation_num ;
        integer                j ;

        begin
            @(posedge Valid_tb) ; 
            for (j =0 ;j<LFSR_width ; j=j+1 ) begin
                #(Clock_PERIOD) DUT_out[j] = CRC_tb ;
            end
            if(out_data_tb == DUT_out)
                $display("Test Case %d is succeeded",operation_num);
            else
                $display("Test Case %d is failed"   ,operation_num);
        end
    endtask


endmodule