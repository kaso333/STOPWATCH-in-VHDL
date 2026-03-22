library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Stoper_test is
end Stoper_test;

architecture Behavioral of Stoper_test is
    component Stoper
        Port ( 
            clk           : in  STD_LOGIC;			-- sygnal zegarowy
            rst           : in  STD_LOGIC;			-- sygnal resetu
            start_pause   : in  STD_LOGIC;			-- sygnal start/pauza
            save          : in  STD_LOGIC;			-- sygnal zapisu czasu
            memory_select : in  STD_LOGIC_VECTOR(1 downto 0);	-- wybór zapisanego czasu do wyœwietlenia
            minutes       : out INTEGER range 0 to 59;			-- wyjscie - minuty
            seconds       : out INTEGER range 0 to 59;			-- wyjscie - sekundy
            memory_valid  : out STD_LOGIC_VECTOR(2 downto 0)	-- wyjscie - status zapisanych czasów
        );
    end component;
    
    -- sygnaly testowe
    signal clk_tb          : std_logic := '0';
    signal rst_tb          : std_logic := '0';
    signal start_pause_tb  : std_logic := '0';
    signal save_tb         : std_logic := '0';
    signal memory_select_tb: std_logic_vector(1 downto 0) := "00";
    signal minutes_tb      : integer range 0 to 59;
    signal seconds_tb      : integer range 0 to 59;
    signal memory_valid_tb : std_logic_vector(2 downto 0);
    
    -- sygnaly pomocnicze
    signal stoper_state    : string(1 to 8) := "STOPPED ";	-- status dzialania stopera
    
    -- stale czasowe
    constant CLK_PERIOD : time := 20 ns;  -- okres zegara (50MHz)
    
    -- plik do zapisu wyników
    file output_file : text open write_mode is "stoper_results.txt";	-- wyniki beda zapisywane do tego pliku
    
begin
    -- instancja testowanego ukladu
    UUT: Stoper port map (
        clk           => clk_tb,
        rst           => rst_tb,
        start_pause   => start_pause_tb,
        save          => save_tb,
        memory_select => memory_select_tb,
        minutes       => minutes_tb,
        seconds       => seconds_tb,
        memory_valid  => memory_valid_tb
    );
    
    -- generacja sygnalu zegarowego
    clk_process: process
    begin
        clk_tb <= '0';				-- sygnal zegarowy na '0'
        wait for CLK_PERIOD/2;	-- oczekwianie na polowe okresu zegara
        clk_tb <= '1';				
        wait for CLK_PERIOD/2;
    end process;
    
    -- proces monitorowania i zapisu czasu
    time_monitor_process: process
        variable line_out : line;					-- zmienna do przechowywania lini tekstu
        variable last_seconds : integer := -1;	-- przechowywanie poprzedniej wartoœci sekund, '-1' zeby wartosc róznila sie od aktualnej liczbie sekund (0-59)
    begin
        wait for CLK_PERIOD;							-- czeka na kolejny cykl zegara
        if seconds_tb /= last_seconds then		-- jeœli liczba sekund sie zmienila
            write(line_out, string'("Czas: "));	-- zapis do pliku
            write(line_out, minutes_tb);
            write(line_out, string'(":"));
            if seconds_tb < 10 then					-- dodaje "0" dla jednocyfrowych wartoœci sekund
                write(line_out, string'("0"));	
            end if;
            write(line_out, seconds_tb);
            write(line_out, string'(" [ "));
            write(line_out, stoper_state);		-- zapis stanu stopera
				-- monitorowanie wa¿noœci zapisanych czasów
            write(line_out, string'("] Zapisane czasy: "));
            write(line_out, memory_valid_tb);	-- zapis wartosci zapisanych czasów (czy zapisany czas jest aktualny)
            writeline(output_file, line_out);	-- zapis linii do pliku
            last_seconds := seconds_tb;			-- aktualizacja zmiennej sekund na biezace wartosci sekund
        end if;
    end process;
	 
	     -- proces monitorujacy zdarzenia
    event_monitor_process: process(clk_tb)
        variable line_out : line;					-- zmienna do przechowywania lini tekstu
    begin
        if rising_edge(clk_tb) then					-- monitoruje narastajace zbocze sygnalu zegarowego
            if save_tb = '1' then					-- jeœli sygnal save_tb jest aktywny ('1')
                write(line_out, string'(">>> Zapisano czas: "));
                write(line_out, minutes_tb);
                write(line_out, string'(":"));
                if seconds_tb < 10 then
                    write(line_out, string'("0"));
                end if;
                write(line_out, seconds_tb);
                writeline(output_file, line_out); -- zapis calej linii do pliku wyników
            end if;
        end if;
    end process;
    
    -- proces testowy - pelny test wszystkich funkcji
    stim_proc: process
        variable line_out : line;
    begin
        -- start testu
        write(line_out, string'("=== Test wszystkich funkcji stopera ==="));
        writeline(output_file, line_out);		-- zapis naglówka do pliku
        wait for 100 ns;
        
        -- test 1: Start stopera
        start_pause_tb <= '1';			-- start stopera
        stoper_state <= "RUNNING ";		-- zmiana stanu na "running"
        wait for CLK_PERIOD;
        start_pause_tb <= '0';			
        write(line_out, string'("Uruchomiono stoper"));
        writeline(output_file, line_out);
        wait for 2 sec;
        
        -- test 2: Pierwszy zapis czasu
        save_tb <= '1';						-- wlacza zapis
        wait for CLK_PERIOD;
        save_tb <= '0';						-- wylacza zapis
        write(line_out, string'("Zapisano pierwszy czas"));
        writeline(output_file, line_out);
        wait for 1 sec;
        
        -- test 3: Pauza
        start_pause_tb <= '1';
        stoper_state <= "PAUSED  ";
        wait for CLK_PERIOD;
        start_pause_tb <= '0';
        write(line_out, string'("Stoper wstrzymany"));
        writeline(output_file, line_out);
        wait for 1 sec;
        
        -- test 4: Wznowienie
        start_pause_tb <= '1';
        stoper_state <= "RUNNING ";
        wait for CLK_PERIOD;
        start_pause_tb <= '0';
        write(line_out, string'("Stoper wznowiony"));
        writeline(output_file, line_out);
        wait for 2 sec;
        
        -- test 5: Drugi zapis czasu
        save_tb <= '1';
        wait for CLK_PERIOD;
        save_tb <= '0';
        write(line_out, string'("Zapisano drugi czas"));
        writeline(output_file, line_out);
        wait for 1 sec;
        
        -- test 6: Trzeci zapis czasu
        save_tb <= '1';
        wait for CLK_PERIOD;
        save_tb <= '0';
        write(line_out, string'("Zapisano trzeci czas"));
        writeline(output_file, line_out);
        wait for 1 sec;
        

        
        -- test 8: Reset
        rst_tb <= '1';					-- reset stopera
        stoper_state <= "STOPPED ";
        wait for CLK_PERIOD;
        rst_tb <= '0';
        write(line_out, string'("Wykonano reset stopera"));
        writeline(output_file, line_out);
        wait for 1 sec;
        
        -- zakonczenie testu
        write(line_out, string'("=== Koniec testu stopera ==="));
        writeline(output_file, line_out);
		  
		   -- przeglad zapisanych czasów
		  write(line_out, string'("=== ZAPISANE CZASY ==="));
		  writeline(output_file, line_out);
        memory_select_tb <= "01";  -- pierwszy zapisany czas
        wait for 1 sec;
        memory_select_tb <= "10";  -- drugi zapisany czas
        wait for 1 sec;
        memory_select_tb <= "11";  -- trzeci zapisany czas
        wait for 1 sec;
        
		  
        wait;
    end process;

end Behavioral;
