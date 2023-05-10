`define MANTISSA 22:0		// position of MANTISSA in DATA
`define EXPONANT 30:23		// position of MANTISSA in DATA
`define SIGN 31			// position of MANTISSA in DATA



module fadd_fsub #(parameter FLEN = 32) (
	input	wire	[FLEN-1 : 0] frs1,
	input	wire	[FLEN-1 : 0] frs2,
	input	wire				 En,
	input	wire				 Funct,		// 0 for add - 1 for sub
	output	reg 	[FLEN-1 : 0] frd
	);


/******************************* internal wire *******************************/

	////////////////// ASSIGN //////////////////	
	// operand
	reg		[FLEN-1:0]	operand_a;
	reg		[FLEN-1:0]	operand_b;
	// check any operand is bigger
	reg					A_is_Bigger;
	// exponent 
	wire	[7:0]		exponent1;
	wire	[7:0]		exponent2;
	// mantissa
	wire	[23:0]		mantissa1;
	wire	[23:0]		mantissa2;
	// sign bit
	reg					output_sign;
	// select opreation addition or subtraction
	reg					operation_sub_addBar;

	////////////////// EXPONANT //////////////////
	// exponent comparison
	wire		[7:0]	exp_diff;
	wire 	[7:0]	new_exponent;
	wire	[24:0]	shifted_mantissa2;
	wire			is_exp_equal;

	////////////////// MANTISSA //////////////////
	// mantissa subtraction
	wire	[24:0]	subtraction_diff;
	wire	[7:0]	exponent_sub;
	// final result
	reg		[24:0]	final_mantissa ;
	reg		[30:0]	comp_result;

	////////////////// OUTPUT //////////////////
	// exponent comparison
	wire		is_operand_a_zero;
	wire		is_operand_b_zero;



/******************************* ASSIGN OPERAND *******************************/

always @(*) begin

	if (Funct) begin
		if (~frs1[`SIGN] && frs2[`SIGN]) begin

			if (frs1[`EXPONANT] == frs2[`EXPONANT]) begin
				if (frs1[`MANTISSA] > frs2[`MANTISSA]) begin
					{A_is_Bigger,operand_a,operand_b} = {1'b0,frs1,frs2} ;
				end
				else begin
					{A_is_Bigger,operand_a,operand_b} = {1'b1,frs2,frs1} ;
				end
			end

			else if (frs1[`EXPONANT] < frs2[`EXPONANT]) begin
				{A_is_Bigger,operand_a,operand_b} = {1'b1,frs2,frs1} ;
			end	

			else begin
				{A_is_Bigger,operand_a,operand_b} = {1'b0,frs1,frs2} ;
			end	
		end

		else begin
			{A_is_Bigger,operand_a,operand_b} = {1'b0,frs1,frs2} ;		
		end

	end

	else if (~frs1[`SIGN] && ~frs2[`SIGN]) begin
		if (frs1[29:23]) begin

			if (frs2[29:23]) begin
				if (frs1[`MANTISSA] > frs2[`MANTISSA]) begin
					{operand_a,operand_b} = {frs1,frs2} ;
				end
				else begin
					{operand_a,operand_b} = {frs2,frs1} ;
				end
			end

			else begin
				{operand_a,operand_b} = {frs2,frs1} ;
			end

		end

		else if (frs1[`EXPONANT] == frs2[`EXPONANT]) begin
			if (frs1[`MANTISSA] > frs2[`MANTISSA]) begin
				{operand_a,operand_b} = {frs1,frs2} ;
			end
			else begin
				{operand_a,operand_b} = {frs2,frs1} ;
			end
		end

		else begin
			if (frs1[`EXPONANT] > frs2[`EXPONANT]) begin
				{operand_a,operand_b} = {frs1,frs2} ;
			end
			else begin
				{operand_a,operand_b} = {frs2,frs1} ;
			end
		end

	end

	else if (frs1[`SIGN] && ~frs2[`SIGN]) begin
		{operand_a,operand_b} = {frs2,frs1} ;
	end

	else if (~frs1[`SIGN] && frs2[`SIGN]) begin
		{operand_a,operand_b} = {frs1,frs2} ;
	end


	else begin

		if (frs1[29:23]) begin
			if (frs2[29:23]) begin
				if (frs1[`MANTISSA] > frs2[`MANTISSA]) begin
					{operand_a,operand_b} = {frs2,frs1} ;
				end
				else begin
					{operand_a,operand_b} = {frs1,frs2} ;
				end
			end
			else begin
				{operand_a,operand_b} = {frs1,frs2} ;
			end
		end

		else if (frs1[`EXPONANT] == frs2[`EXPONANT]) begin

			if (frs1[`MANTISSA] > frs2[`MANTISSA]) begin
				{operand_a,operand_b} = {frs2,frs1} ;
			end
			else begin
				{operand_a,operand_b} = {frs1,frs2} ;
			end

		end

		else begin
			if (frs1[`EXPONANT] > frs2[`EXPONANT]) begin
				{operand_a,operand_b} = {frs2,frs1} ;
			end
			else begin
				{operand_a,operand_b} = {frs1,frs2} ;
			end
		end

	end
end


	assign exponent1 = operand_a[`EXPONANT];
	assign exponent2 = operand_b[`EXPONANT];

	assign mantissa1 = (|exponent1) ? {1'b1,operand_a[`MANTISSA]} : {1'b0,operand_a[`MANTISSA]};
	assign mantissa2 = (|exponent2) ? {1'b1,operand_b[`MANTISSA]} : {1'b0,operand_b[`MANTISSA]};



	////////////////// SELECT OPERATION //////////////////
	always @(*) begin
		if (Funct) begin
			if (operand_a[31] && ~operand_b[31]) begin
				operation_sub_addBar = 1'b1 ;
			end
			else begin
				operation_sub_addBar = 1'b0 ;
			end
		end
		else begin
			if (~operand_a[31] && ~operand_b[31]) begin
				operation_sub_addBar = 1'b1 ;
			end
			else begin
				operation_sub_addBar = 1'b0 ;
			end
		end
	end

	
	////////////////// SELECT SIGN BIT //////////////////
	always @(*) begin
		if (Funct ) begin
			if (A_is_Bigger) begin
				output_sign = 1'b0 ;
			end
			else begin
				output_sign = operand_a[31] ;
			end
		end
		else begin
			if (operand_a[31] && operand_b[31]) begin
				output_sign = 1'b1 ;
			end
			else if (~operand_a[31] && operand_b[31]) begin
				output_sign = 1'b1 ;
			end
			else begin
				output_sign = 1'b0 ;
			end
		end
	end
	

/******************************* exponent *******************************/
	assign exp_diff = exponent1 - exponent2;
	assign new_exponent = operand_b[30:23] + exp_diff ;
	assign shifted_mantissa2 = mantissa2 >> exp_diff ;
	assign is_exp_equal = (exponent1 == new_exponent) ;


/******************************* mantissa *******************************/	
	always @(*) begin
		if (is_exp_equal) begin
			if (operation_sub_addBar) begin
				final_mantissa = mantissa1 + shifted_mantissa2 ;
				if (final_mantissa[24]) begin
				comp_result[22:0]  = final_mantissa[23:1];
				comp_result[30:23] = new_exponent + 1'b1;
				end
				else begin
				comp_result[22:0]  = final_mantissa[22:0];
				comp_result[30:23] = new_exponent;
				end
			end
			else begin
				final_mantissa = mantissa1 + (~shifted_mantissa2 + 24'b1);
				comp_result[22:0]  = subtraction_diff[22:0];
				comp_result[30:23] = exponent_sub;
			end
		end
		else begin
			final_mantissa = 'b0 ;
			comp_result[30:0]  = 'b0 ;
		end
	end

	priority_encoder pe(final_mantissa, new_exponent, subtraction_diff,exponent_sub);



/******************************* OUTPUT *******************************/	
	assign is_operand_a_zero =  ~(|operand_a[30:0]);
	assign is_operand_b_zero =  ~(|operand_b[30:0]);

	always @(*) begin
		case({Funct, is_operand_a_zero, is_operand_b_zero})
			3'b010: begin
				frd = operand_b; 
			end
			3'b011: begin
				frd = 32'b0; 
			end
			3'b001: begin
				frd = operand_a; 
			end
			3'b110: begin
				frd = {~operand_b[31], operand_b[30:0]}; 
			end
			3'b101: begin
				frd = operand_a; 
			end
			3'b111: begin
				frd = 32'b0; 
			end
			default: 
				frd = {output_sign, comp_result};
		endcase
	end



endmodule
