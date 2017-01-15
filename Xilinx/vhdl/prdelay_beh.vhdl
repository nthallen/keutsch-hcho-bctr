--
-- VHDL Architecture BCtr_lib.prdelay.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 13:31:16 01/ 8/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY prdelay IS
  GENERIC (
    LFSR_WIDTH : integer range 64 downto 4 := 41;
    OUTPUT_WIDTH : integer range 16 downto 4 := 9;
    RAND_WIDTH : integer range 64 downto 4 := 18;
    LOOKUP_SIZE : integer range 1000 downto 4 := 333
  );
  PORT (
    clk : IN std_logic;
    rst : IN std_logic;
    RE : IN std_logic;
    Nbins : OUT unsigned(OUTPUT_WIDTH-1 DOWNTO 0)
  );
END ENTITY prdelay;

--
ARCHITECTURE beh OF prdelay IS
  component lfsr is
    generic (width : integer := 4);
    port (
      clk : in std_logic;
      rst : in std_logic;
     	set_seed : in std_logic; 
      seed : in std_logic_vector(width-1 downto 0);
      rand_out : out std_logic_vector(width-1 downto 0)  		
    );
  end component;
  SIGNAL set_seed : std_logic;
  SIGNAL seed : std_logic_vector(LFSR_WIDTH-1 DOWNTO 0);
  SIGNAL rand_out : std_logic_vector(LFSR_WIDTH-1 DOWNTO 0);
  SIGNAL R : unsigned(RAND_WIDTH-1 DOWNTO 0);
  SIGNAL Tmid : integer range 3992 DOWNTO 0;
  SIGNAL RgtTmid : std_logic;
  SIGNAL low, mid, high : unsigned(OUTPUT_WIDTH-1 DOWNTO 0);
  TYPE State_t IS (S_INIT, S_LU0, S_LU1, S_LU2);
  SIGNAL cur_state : State_t;
  TYPE T_t is array (1 TO LOOKUP_SIZE) of integer range 3992 DOWNTO 0;
  CONSTANT T : T_t := (
      87,   174,   262,   349,   408,   448,   484,   521,   557,   592,
     627,   662,   697,   731,   765,   798,   832,   864,   897,   929,
     961,   993,  1024,  1055,  1085,  1116,  1146,  1175,  1205,  1234,
    1263,  1291,  1320,  1348,  1375,  1403,  1430,  1457,  1483,  1510,
    1536,  1562,  1587,  1613,  1638,  1663,  1687,  1711,  1736,  1759,
    1783,  1806,  1830,  1852,  1875,  1898,  1920,  1942,  1964,  1985,
    2007,  2028,  2049,  2069,  2090,  2110,  2130,  2150,  2170,  2190,
    2209,  2228,  2247,  2266,  2284,  2303,  2321,  2339,  2357,  2374,
    2392,  2409,  2426,  2443,  2460,  2477,  2493,  2510,  2526,  2542,
    2558,  2573,  2589,  2604,  2619,  2634,  2649,  2664,  2679,  2693,
    2707,  2722,  2736,  2750,  2763,  2777,  2790,  2804,  2817,  2830,
    2843,  2856,  2869,  2881,  2894,  2906,  2918,  2930,  2942,  2954,
    2966,  2977,  2989,  3000,  3012,  3023,  3034,  3045,  3055,  3066,
    3077,  3087,  3098,  3108,  3118,  3128,  3138,  3148,  3158,  3168,
    3177,  3187,  3196,  3205,  3215,  3224,  3233,  3242,  3251,  3259,
    3268,  3277,  3285,  3294,  3302,  3310,  3318,  3327,  3335,  3343,
    3350,  3358,  3366,  3374,  3381,  3389,  3396,  3403,  3411,  3418,
    3425,  3432,  3439,  3446,  3453,  3459,  3466,  3473,  3479,  3486,
    3492,  3499,  3505,  3511,  3517,  3523,  3529,  3535,  3541,  3547,
    3553,  3559,  3565,  3570,  3576,  3581,  3587,  3592,  3598,  3603,
    3608,  3613,  3619,  3624,  3629,  3634,  3639,  3644,  3649,  3653,
    3658,  3663,  3668,  3672,  3677,  3681,  3686,  3690,  3695,  3699,
    3703,  3708,  3712,  3716,  3720,  3724,  3728,  3732,  3736,  3740,
    3744,  3748,  3752,  3756,  3759,  3763,  3767,  3770,  3774,  3778,
    3781,  3785,  3788,  3791,  3795,  3798,  3802,  3805,  3808,  3811,
    3815,  3818,  3821,  3824,  3827,  3830,  3833,  3836,  3839,  3842,
    3845,  3848,  3850,  3853,  3856,  3859,  3862,  3864,  3867,  3870,
    3872,  3875,  3877,  3880,  3882,  3885,  3887,  3890,  3892,  3895,
    3897,  3899,  3902,  3904,  3906,  3908,  3911,  3913,  3915,  3917,
    3919,  3921,  3924,  3926,  3928,  3930,  3932,  3934,  3936,  3938,
    3940,  3942,  3943,  3945,  3947,  3949,  3951,  3953,  3954,  3956,
    3958,  3960,  3961,  3963,  3965,  3966,  3968,  3970,  3971,  3973,
    3975,  3976,  3978,  3979,  3981,  3982,  3984,  3985,  3987,  3988,
    3990,  3991,  3992 );
BEGIN
  lfsr_inst : lfsr
    GENERIC MAP (width => LFSR_WIDTH)
    PORT MAP (
      clk => clk,
      rst => rst,
      set_seed => set_seed,
      seed => seed,
      rand_out => rand_out
    );
    
  PROCESS (R,Tmid) IS
  BEGIN
    IF (R > to_unsigned(Tmid,RAND_WIDTH)) THEN
      RgtTmid <= '1';
    ELSE
      RgtTmid <= '0';
    END IF;
  END PROCESS;
  
  PROCESS (clk) IS
    FUNCTION midpoint(low, high : IN unsigned(OUTPUT_WIDTH-1 DOWNTO 0))
      return unsigned IS
      VARIABLE low1, mid1, high1 : unsigned(OUTPUT_WIDTH DOWNTO 0);
      VARIABLE mid : unsigned(OUTPUT_WIDTH-1 DOWNTO 0);
    BEGIN
      low1 := resize(low,OUTPUT_WIDTH+1);
      high1 := resize(high,OUTPUT_WIDTH+1);
      mid1 := low1+high1;
      mid := mid1(OUTPUT_WIDTH DOWNTO 1);
      return mid;
    END midpoint;
    VARIABLE midv : unsigned(OUTPUT_WIDTH-1 DOWNTO 0);
  BEGIN
    IF (clk'Event AND clk = '1') THEN
      IF (rst = '1') THEN
        Nbins <= (others => '0');
        set_seed <= '0';
        seed <= (others => '0');
        cur_state <= S_INIT;
      ELSE
        CASE cur_state IS
        WHEN S_INIT =>
          IF (RE = '1') THEN
            R <= unsigned(rand_out(RAND_WIDTH-1 DOWNTO 0));
            Tmid <= T(LOOKUP_SIZE);
            low <= to_unsigned(1,OUTPUT_WIDTH);
            high <= to_unsigned(LOOKUP_SIZE,OUTPUT_WIDTH);
            cur_state <= S_LU0;
          ELSE
            cur_state <= S_INIT;
          END IF;
        WHEN S_LU0 =>
          IF (RgtTmid = '1') THEN
            Nbins <= (others => '0');
            IF (RE = '1') THEN
              cur_state <= S_LU0;
            ELSE
              cur_state <= S_INIT;
            END IF;
          ELSE
            cur_state <= S_LU1;
          END IF;
        WHEN S_LU1 =>
          IF (low = high) THEN
            Nbins <= low;
            IF (RE = '1') THEN
              cur_state <= S_LU1;
            ELSE
              cur_state <= S_INIT;
            END IF;
          ELSE
            midv := midpoint(low,high);
            mid <= midv;
            Tmid <= T(to_integer(midv));
            cur_state <= S_LU2;
          END IF;
        WHEN S_LU2 =>
          IF (RgtTmid = '1') THEN
            low <= mid+1;
          ELSE
            high <= mid;
          END IF;
          cur_state <= S_LU1;
        WHEN others =>
          cur_state <= S_INIT;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
      
END ARCHITECTURE beh;

