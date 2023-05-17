module FPU_MUL #(
    parameter FLEN     = 32,
    parameter MANTISSA = 23,
    parameter EXP      = 8 
)
(
    input  wire				En,
    input  wire	[FLEN-1:0]  Rs1,
    input  wire	[FLEN-1:0]  Rs2,
    output wire             overflow,
    output wire [FLEN-1:0]  Result
);

localparam EXP_BIAS = 8'd127;

// SIGN BITS
wire sign_1;
wire sign_2;
wire sign_rs;

// EXPONENT
wire [EXP-1:0] exp_1;
wire [EXP-1:0] exp_2;
wire [EXP:0]   exp_rs;

// MANTISSA
wire [MANTISSA-1:0] mnt_1;
wire [MANTISSA-1:0] mnt_2;
wire [MANTISSA-1:0] mnt_rs;

// Product of the two mantisssas
wire [63:0]              product;
wire [MANTISSA*2 + 1:0]  product_norm;

// NORMALIZATION
wire norm_op;

// Special values
wire zero;               

assign sign_1 = Rs1[FLEN-1];
assign sign_2 = Rs2[FLEN-1];

assign exp_1 = Rs1[30:23];
assign exp_2 = Rs2[30:23];

assign mnt_1 = Rs1[22:0];
assign mnt_2 = Rs2[22:0];

// Calculate the products of the two mantissas
mul_top mul (
    .a_i({8'b0,1'b1,mnt_1}),
    .b_i({8'b0,1'b1,mnt_2}),
    .En(En),
    .mul_o(product)
);

// Detect the need for the normalization
assign norm_op = product[47]? 1'b1:1'b0;
assign product_norm = product[47]? product: product << 1;  

// Gathering Result
assign sign_rs = sign_1 ^ sign_2;
assign mnt_rs  = product_norm[46:24]; 
assign exp_rs  = exp_1 + exp_2 - EXP_BIAS + norm_op;

// Expections detetction
assign zero     = ({exp_1,mnt_1} == 32'b0 || {exp_2,mnt_2} == 32'b0)? 1'b1:1'b0;
assign overflow = exp_rs[8]? 1'b1:1'b0;

assign Result  = zero? {sign_rs,31'b0} : {sign_rs,exp_rs[EXP-1:0],mnt_rs};

endmodule