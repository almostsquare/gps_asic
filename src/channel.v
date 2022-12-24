// Author: Adrian Wong (adrian@almostsquare.com)

// Single tracking channel for GPS C/A code
// Incomplete implementation
// Partially completed for 2022.12.31 MPW-8 submission

module channel(
`ifdef USE_POWER_PINS
	inout           vccd1,	// User area 1 1.8V power
	inout           vssd1,	// User area 1 digital ground
`endif
    input           clk,
    input           reset,

    input           sample,

    input           lo_nco_enable,
    input           ca_nco_enable,
    input           ca_gen_enable,

    input   [31:0]  data_value,
    input   [2:0]   address,

    output          lo_i,
    output          lo_q,
    output          prompt_i,
    output          prompt_q,

    output  [31:0]  lo_nco_phase_accumulator,
    output  [15:0]  ca_nco_phase_upper,

    output   [1:0]  io_oeb
);

    wire    [31:0]  ca_nco_phase_accumulator;
    wire            ca_full_chip;
    wire            ca_prompt;

    reg     [31:0]  lo_nco_phase_delay;
    reg     [31:0]  ca_nco_phase_delay;

    reg     [31:0]  ca_nco_step;
    reg     [31:0]  lo_nco_step;

    reg             lo_nco_phase_sync;
    reg             ca_nco_phase_sync;

    reg     [10:1]  prn_phase_init;


    // Small modification for Caravel MPW8 wrapper
    assign io_oeb = 2'b0;

    assign ca_full_chip       = ~ca_nco_phase_accumulator[31];
    assign ca_nco_phase_upper = ca_nco_phase_accumulator[31:16];

    // Tiny Register File
    always @ (posedge clk) begin
        if (reset) begin
                lo_nco_step <= 32'h01FF0000;        // Dummy val for bringup
                lo_nco_phase_delay <= 32'b0;
                ca_nco_step <= 32'h0FFF0000;        // Dummy val for bringup
                ca_nco_phase_delay <= 32'b0;
                lo_nco_phase_sync <= 1'b0;
                ca_nco_phase_sync <= 1'b0;
                prn_phase_init <= 9'o541;           // Chip PRN39 for bringup
        end else begin
            case (address)
                3'b001: lo_nco_step <= data_value;
                3'b010: begin
                            lo_nco_phase_delay <= data_value;
                            lo_nco_phase_sync <= 1'b1;
                        end
                3'b011: ca_nco_step <= data_value;
                3'b100: begin
                            ca_nco_phase_delay <= data_value;
                            ca_nco_phase_sync <= 1'b1;
                        end
                3'b101: prn_phase_init <= data_value[9:0];
                default: begin
                            ca_nco_phase_sync <= 1'b0;
                            lo_nco_phase_sync <= 1'b0;
                        end
            endcase
        end
    end

    // Local Numerically Controlled Oscillator (NCO)
    nco lo_nco(
        .clk(clk),
        .reset(reset),
        .enable(lo_nco_enable),
        .phase_sync(lo_nco_phase_sync),
        .phase_in(lo_nco_phase_delay),
        .step(lo_nco_step),
        .phase_out(lo_nco_phase_accumulator));

    // Coarse Acqusition Numerically Controlled Oscillator (NCO)
    nco ca_nco(
        .clk(clk),
        .reset(reset),
        .enable(ca_nco_enable),
        .phase_sync(ca_nco_phase_sync),
        .phase_in(ca_nco_phase_delay),
        .step(ca_nco_step),
        .phase_out(ca_nco_phase_accumulator));

    assign ca_full_chip = ~ca_nco_phase_accumulator[31];

    // Coarse Acquisition Code Generator
    ca_code ca_gen(
        .clk(ca_full_chip),
        .reset(~ca_gen_enable),
        .expanded(1'b1),
        .tap0(prn_phase_init[8:5]),     // Just re-use prn_phase_init bits
        .tap1(prn_phase_init[4:1]),     // Just re-use prn_phase_init bits
        .g2_init(prn_phase_init),
        .chip(ca_prompt));

    // NCO phase-to-amplitude conversion
    // 1-bit amplitude is just the sign
    wire [3:0] lo_sin = 4'b1100;
    wire [3:0] lo_cos = 4'b0110;
 
    // In-Phase and Quadrature Arms
    // Use quad trick from Andrew Holme
    assign lo_i = lo_sin[lo_nco_phase_accumulator[31:30]];
    assign lo_q = lo_cos[lo_nco_phase_accumulator[31:30]];

    assign prompt_i = sample ^ ca_prompt ^ lo_i;
    assign prompt_q = sample ^ ca_prompt ^ lo_q;
    
    // TODO(adrianwong): Size this to match chipping rate
    // reg [1024:0] integrator_pi, integrator_pq;

    // TODO(adrianwong): Dump integrator/accumulators
    // always @ (posedge clk) begin
    //     integrator_pi <= {integrator_pi[1023:0], prompt_i};
    //     integrator_pq <= {integrator_pq[1023:0], prompt_q};
    // end

    // TODO(adrianwong): Early, late arms for integrators

endmodule