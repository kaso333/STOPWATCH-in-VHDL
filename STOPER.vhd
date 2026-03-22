-----------------------------------------------------------------------------------------------
-- Autor: Kacper Sosnowski 
-- Tytul projektu: STOPER
-- Data: 16.01.2024
-----------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stoper is
    Port ( 
        clk           : in  STD_LOGIC;                    -- sygna³ zegarowy (50MHz)
        rst           : in  STD_LOGIC;                    -- sygna³ resetu
        start_pause   : in  STD_LOGIC;                    -- przycisk start/pauza
        save          : in  STD_LOGIC;                    -- przycisk do zapisu wyniku
        memory_select : in  STD_LOGIC_VECTOR(1 downto 0); -- wybór pamiêci do wyœwietlenia (2 bity)
        minutes       : out INTEGER range 0 to 59;        -- wyœwietlane minuty
        seconds       : out INTEGER range 0 to 59;        -- wyœwietlane sekundy
        memory_valid  : out STD_LOGIC_VECTOR(2 downto 0)  -- flagi wa¿noœci zapisanych czasów (czy czas jest aktualny i dobrze zapisany)
    );
end Stoper;

-- definicja architektury
architecture Behavioral of Stoper is

    -- sta³e
    constant CLK_FREQ : integer := 50_000_000; -- 50MHz (jedna pe³na operacja zajmuje 20ns)
    
    -- typ do przechowywania zapisanych czasów (struktura)
    type stored_time is record
        minutes : integer range 0 to 59;
        seconds : integer range 0 to 59;
        valid   : std_logic;					-- flaga wa¿noœci danych
    end record;

	 -- tablica do przechowywania zapisanych czasów (3 miejsca)
    type memory_array is array (0 to 2) of stored_time;
    
    -- sygna³y wewnêtrzne
    signal running       : std_logic := '0';  								-- status dzia³ania stopera
    signal paused        : std_logic := '0';   								-- status pauzy
    signal min_count     : integer range 0 to 59 := 0;					-- licznik minut
    signal sec_count     : integer range 0 to 59 := 0;					-- licznik sekund
    signal memory        : memory_array := (others => (0, 0, '0'));	-- pamiêæ czasów
    signal memory_index  : integer range 0 to 2 := 0;						-- indeks do zapisu pamiêci (wskazuje, która pamiêæ jest aktualnie u¿ywana do zapisu)
    signal display_mins  : integer range 0 to 59 := 0;					-- minuty do wyœwietlenia
    signal display_secs  : integer range 0 to 59 := 0;					-- sekundy do wyœwietlenia
    
begin
	 -- g³ówny proces steruj¹cy dzia³anie stopera
    process(clk, rst)
        variable clk_counter : integer range 0 to CLK_FREQ-1 := 0; -- zlicznik taktów zegara (zmienna lokalna - aktualizuje sie natychmiast, liczy od 0 do 49_999_999)
    begin
        if rst = '1' then
            -- reset wszystkich stanów
            min_count <= 0;
            sec_count <= 0;
            running <= '0';
            paused <= '0';
            clk_counter := 0;
        elsif rising_edge(clk) then
            -- obs³uga przycisku start/pauza
            if start_pause = '1' then
                if running = '0' and paused = '0' then
                    running <= '1';		-- rozpoczêcie dzia³ania stopera
                elsif running = '1' then
                    running <= '0';		-- pauza
                    paused <= '1';
                else
                    running <= '1';		-- wznowienie z pauzy
                    paused <= '0';
                end if;
            end if;
            
            -- zliczanie czasu gdy stoper dzia³a
            if running = '1' then
                if clk_counter = CLK_FREQ-1 then
                    clk_counter := 0;				-- reset licznika zegara
                    if sec_count = 59 then
                        sec_count <= 0;
                        if min_count = 59 then
                            min_count <= 0;		-- przepe³nienie minut
                        else
                            min_count <= min_count + 1;	-- inkrementacja minut (up³yw 59 sekund)
                        end if;
                    else
                        sec_count <= sec_count + 1;		-- inkrementacja sekund
                    end if;
                else
                    clk_counter := clk_counter + 1;		-- inkrementacja licznika zegara
                end if;
            end if;
            
            -- obs³uga zapisu czasu
            if save = '1' and memory_index < 3 then
                memory(memory_index) <= (min_count, sec_count, '1');	-- zapis czasu do pamiêci, '1' -> valid - wa¿ny zapis
                if memory_index < 2 then
                    memory_index <= memory_index + 1; -- inkrementacja indeksu pamiêci
                end if;
            end if;
        end if;
    end process;

    -- proces wyboru wyœwietlanego czasu
    process(memory_select, min_count, sec_count, memory)
    begin
        case memory_select is
            when "00" =>	-- wyœwietlanie bie¿¹cego czasu
                display_mins <= min_count;
                display_secs <= sec_count;
            when "01" =>	-- wyœwietlanie pierwszego zapisanego czasu
                display_mins <= memory(0).minutes;
                display_secs <= memory(0).seconds;
            when "10" =>	-- wyœwietlanie drugiego zapisanego czasu
                display_mins <= memory(1).minutes;
                display_secs <= memory(1).seconds;
            when others =>	-- wyœwietlanie trzeciego zapisanego czasu
                display_mins <= memory(2).minutes;
                display_secs <= memory(2).seconds;
        end case;
    end process;

    -- przypisanie wyjœæ
    minutes <= display_mins;
    seconds <= display_secs;
	 -- flaga valid wskazuje, czy zapisany czas jest wa¿ny
    memory_valid <= memory(2).valid & memory(1).valid & memory(0).valid;

end Behavioral;