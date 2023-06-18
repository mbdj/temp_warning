with Pico;
with RP.Clock;
with RP.GPIO;
with RP.Device;
with RP.ADC; use RP.ADC;

with HAL.UART;
with RP.UART;
with Ada.Characters.Latin_1;  --  for New_Line

procedure Temp_Warning is
   use RP.GPIO;

   --  nombre de mesures à la hausse avant l'alerte
   Nombre_De_Mesures                              : constant Natural := 9;

   Temperature, Last_Minimum_Temperature          : RP.ADC.Celsius;
   Compteur_Elevation_Temperature                 : Natural := Nombre_De_Mesures;

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



   procedure Afficher_Temperature (Temp       : in RP.ADC.Celsius;
                                   Data       : in HAL.UART.UART_Data_8b;
                                   Status     : out HAL.UART.UART_Status) is

      function String_Message (T : RP.ADC.Celsius) return Type_Message is
         use RP.ADC;
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

         if T < 17 then
            Msg := Type_Message ("<<" & New_Line);
         elsif T > 39 then
            Msg := Type_Message (">>" & New_Line);
         end if;

         return Msg;

      end String_Message;

   begin
      Message := String_Message (Temp);
      Port.Transmit (Data, Status, Timeout => 0);
   end;

   procedure Afficher (Msg        : in Type_Message;
                       Data       : in HAL.UART.UART_Data_8b;
                       Status     : out HAL.UART.UART_Status) is
   begin
      Message := Msg;
      Port.Transmit (Data, Status, Timeout => 0);
   end;

   procedure Afficher_Compteur (N          : in Integer;
                                Data       : in HAL.UART.UART_Data_8b;
                                Status     : out HAL.UART.UART_Status) is
   begin
      case N is
         when 0 => Message := Type_Message ("0!" & New_Line);
         when 1 => Message := Type_Message ("1!" & New_Line);
         when 2 => Message := Type_Message ("2!" & New_Line);
         when 3 => Message := Type_Message ("3!" & New_Line);
         when 4 => Message := Type_Message ("4!" & New_Line);
         when 5 => Message := Type_Message ("5!" & New_Line);
         when 6 => Message := Type_Message ("6!" & New_Line);
         when 7 => Message := Type_Message ("7!" & New_Line);
         when 8 => Message := Type_Message ("8!" & New_Line);
         when 9 => Message := Type_Message ("9!" & New_Line);
         when others => Message := Type_Message ("ER" & New_Line);
      end case;

      Port.Transmit (Data, Status, Timeout => 0);
   end;


   --  plusieurs mesures sont faites et la moyenne est retournée
   function Read_Temperature return RP.ADC.Celsius is
      use RP.ADC;
      T : RP.ADC.Celsius := 0;
   begin
      for I in 1 .. 20 loop
         T := T + RP.ADC.Temperature;
         RP.Device.Timer.Delay_Milliseconds (500);
      end loop;

      return RP.ADC.Celsius (Integer (T) / 20);
   end Read_Temperature;


   procedure Beep (Ms : Integer := 100) is
   begin
      --  beep
      Buzzer.Toggle;
      RP.Device.Timer.Delay_Milliseconds (Ms);
      Buzzer.Toggle;
   end;

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

   Afficher (Msg    => Type_Message ("==" & New_Line),
             Data   => Data,
             Status => Status);

   --  at the start we wait for the temperature to stabilize
   --  because when the Pico is plugged in its temperature can increase
   for I in 1 .. 10 loop
      Temperature := Read_Temperature;

      Afficher_Temperature (Temp   => Temperature,
                            Data   => Data,
                            Status => Status);
      RP.Device.Timer.Delay_Milliseconds (1000);
   end loop;

   Afficher (Msg    => Type_Message ("--" & New_Line),
             Data   => Data,
             Status => Status);

   Last_Minimum_Temperature := Read_Temperature;

   Afficher_Temperature (Temp   => Last_Minimum_Temperature,
                         Data   => Data,
                         Status => Status);

   loop
      RP.Device.Timer.Delay_Milliseconds (500);
      Temperature := Read_Temperature;

      Afficher_Temperature (Temp   => Temperature,
                            Data   => Data,
                            Status => Status);

      --  if temperature decreases we reset the counter et no beep
      if Temperature < Last_Minimum_Temperature then
         Last_Minimum_Temperature := Temperature;
         Compteur_Elevation_Temperature := Nombre_De_Mesures;

         --  if the temperature stabilizes but no longer decreases we alert with one beep
      elsif Temperature = Last_Minimum_Temperature then
         Last_Minimum_Temperature := Temperature;
         Compteur_Elevation_Temperature := Nombre_De_Mesures;

         Beep;

      else --  Temperature > Last_Minimum_Temperature
         --  if temperature increases we alert with two beeps
         --  until its reachs minimum temperature before Nombre_De_Mesures measures
         --  or otherwise we send warning
         Compteur_Elevation_Temperature := @ -1;
         Beep;
         RP.Device.Timer.Delay_Milliseconds (100);
         Beep;

      end if;

      Afficher_Compteur (Compteur_Elevation_Temperature,
                         Data   => Data,
                         Status => Status);

      exit when Compteur_Elevation_Temperature = 0;

   end loop;

   --  the temperature has not returned to the minimum temperature after Nombre_De_Mesures measures
   --  so we trigger warning buzzer
   loop
      Buzzer.Toggle;
      RP.Device.Timer.Delay_Milliseconds (200);
   end loop;

end Temp_Warning;
