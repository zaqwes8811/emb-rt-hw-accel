	component ni2 is
		port (
			clk_clk                        : in  std_logic                    := 'X'; -- clk
			pio_external_connection_export : out std_logic_vector(7 downto 0)         -- export
		);
	end component ni2;

	u0 : component ni2
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			pio_external_connection_export => CONNECTED_TO_pio_external_connection_export  -- pio_external_connection.export
		);

