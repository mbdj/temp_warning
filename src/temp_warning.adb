with Pico;
with RP.Clock;
with RP.GPIO;       use RP.GPIO;
with RP.Device;
with RP.ADC;

with HAL.UART;
with RP.UART;
with Ada.Characters.Latin_1;  --  for New_Line

procedure Temp_Warning is

   --  temperature
   Temperature : RP.ADC.Celsius;

   Buzzer : GPIO_Point renames Pico.GP2;

   --  UART
   UART_TX : GPIO_Point renames Pico.GP0;
   Port    : RP.UART.UART_Port renames RP.Device.UART_0;

   New_Line : constant String := [1 => Ada.Characters.Latin_1.LF , 2 => Ada.Characters.Latin_1.CR];
   type Type_Message is new String (1 .. 4);
   Message  :  Type_Message;

   Data     : HAL.UART.UART_Data_8b (Message'Range)
     with Address => Message'Address;

   Status  : HAL.UART.UART_Status;


   --------------------
   -- String_Message --
   --------------------

   function String_Message (T : RP.ADC.Celsius) return Type_Message is
      Msg : Type_Message;
   begin
      case T is
      when 17 => Msg := Type_Message ("17" & New_Line);
      when 18 => Msg := Type_Message ("18" & New_Line);
      when 19 => Msg := Type_Message ("19" & New_Line);
      when 20 => Msg := Type_Message ("20" & New_Line);
      when 21 => Msg := Type_Message ("21" & New_Line);
      when 22 => Msg := Type_Message ("22" & New_Line);
      when 23 => Msg := Type_Message ("23" & New_Line);
      when 24 => Msg := Type_Message ("24" & New_Line);
      when 25 => Msg := Type_Message ("25" & New_Line);
      when 26 => Msg := Type_Message ("26" & New_Line);
      when 27 => Msg := Type_Message ("27" & New_Line);
      when 28 => Msg := Type_Message ("28" & New_Line);
      when 29 => Msg := Type_Message ("29" & New_Line);
      when 30 => Msg := Type_Message ("30" & New_Line);
      when 31 => Msg := Type_Message ("31" & New_Line);
      when 32 => Msg := Type_Message ("32" & New_Line);
      when 33 => Msg := Type_Message ("33" & New_Line);
      when 34 => Msg := Type_Message ("34" & New_Line);
      when 35 => Msg := Type_Message ("35" & New_Line);
      when 36 => Msg := Type_Message ("36" & New_Line);
      when 37 => Msg := Type_Message ("37" & New_Line);
      when 38 => Msg := Type_Message ("38" & New_Line);
      when 39 => Msg := Type_Message ("39" & New_Line);
      when others => Msg := Type_Message ("99" & New_Line);
      end case;

      if Integer (Temperature) < 17 then
         Msg := Type_Message ("<<" & New_Line);
      elsif Integer (Temperature) > 39 then
         Msg := Type_Message (">>" & New_Line);
      end if;

      return Msg;

   end String_Message;



begin
   --
   --  Initializations
   --

   --  warning buzzer
   Buzzer.Configure
     (Mode       => Output,
      Pull       => Pull_Down,
      Func       => SIO,
      Schmitt    => True,
      Slew_Fast  => False);

   --  for Delay_Milliseconds
   RP.Device.Timer.Enable;

   --  for UART
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);

   UART_TX.Configure (Output, Floating, UART);

   --  for temperature reading
   RP.ADC.Enable;  --  après initialisation de Clock sinon plante !

   --  The default config is 115200 8n1, this example just overrides the baud rate
   Port.Configure (Config => (Baud => 115200, others => <>));


   loop
      Temperature := RP.ADC.Temperature;

      Message := String_Message (Temperature);

      Port.Transmit (Data, Status, Timeout => 0);
      RP.Device.Timer.Delay_Milliseconds (500);
   end loop;

   --  triggers buzzer warning
   loop
      Buzzer.Toggle;
      RP.Device.Timer.Delay_Milliseconds (200);
   end loop;

end Temp_Warning;
