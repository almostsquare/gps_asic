module dump();
    initial begin
        $dumpfile ("nco.vcd");
        $dumpvars (0, nco);
        #1;
    end
endmodule
