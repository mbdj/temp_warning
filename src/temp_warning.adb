with Pico;
with RP.Clock;
with RP.GPIO;
with RP.Device;
with RP.ADC; use RP.ADC;

with HAL.UART;
with RP.UART;

with package_Read_Temperature; use package_Read_Temperature;


with Buzzer; use Buzzer;
with Uart_Sending; use UART_Sending;

procedure Temp_Warning is

   use RP.GPIO;

   --  number of times before sending alert
   Number_Of_Measures_Before_Alert : constant Natural := 9;
   Waiting_Delay_Ms                : constant Positive := 10000;  --  10 s

   Temperature, Last_Minimum_Temperature : RP.ADC.Celsius;
   Counter_Elevation_Temperature         : Natural := Number_Of_Measures_Before_Alert;
   Counter_Stabilization_Temperature     : Natural := Number_Of_Measures_Before_Alert;



   --  UART
   UART_TX   : GPIO_Point renames Pico.GP0;
   UART_0    : RP.UART.UART_Port renames RP.Device.UART_0;
   Status    : HAL.UART.UART_Status;


   --  Buzzer
   Alarm_Buzzer : Type_Buzzer;


begin
   --
   --  Initializations
   --

   --  buzzer
   Alarm_Buzzer.Configure (Pin => Pico.GP2);

   --  for Delay_Milliseconds
   RP.Device.Timer.Enable;

   --  for UART
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);

   UART_TX.Configure (Output, Floating, UART);

   --  for temperature reading
   RP.ADC.Enable;  --  après initialisation de Clock sinon plante !

   --  The default config is 115200 8n1, this example just overrides the baud rate
   Uart_0.Configure (Config => (Baud => 115200, others => <>));

   UART_Sending.UART_Send (Message    => Type_Message ("==" & New_Line),
                           Port => UART_0,
                           Status     => Status);


   --  at the start we wait for the temperature to stabilize
   --  because when the Pico is plugged in its temperature can increase
   for I in 1 .. 10 loop
      Temperature := Read_Temperature;

      UART_Sending.UART_Send_Temperature (Temperature   => Temperature,
                                          Port          => UART_0,
                                          Status        => Status);

      RP.Device.Timer.Delay_Milliseconds (Waiting_Delay_Ms);
   end loop;

   UART_Sending.UART_Send (Message => Type_Message ("--" & New_Line),
                           Port => UART_0,
                           Status => Status);

   --  Read the reference temperature
   Last_Minimum_Temperature := Read_Temperature;

   UART_Sending.UART_Send_Temperature (Temperature => Last_Minimum_Temperature,
                                       Port => UART_0,
                                       Status => Status);

   loop
      RP.Device.Timer.Delay_Milliseconds (Waiting_Delay_Ms);
      Temperature := Read_Temperature;

      UART_Sending.UART_Send_Temperature (Temperature   => Temperature,
                                          Port          => UART_0,
                                          Status        => Status);

      --  if temperature decreases we reset the counter and no beep
      if Temperature < Last_Minimum_Temperature then
         Last_Minimum_Temperature := Temperature;

         --  re-init counters
         Counter_Elevation_Temperature := Number_Of_Measures_Before_Alert;
         Counter_Stabilization_Temperature := Number_Of_Measures_Before_Alert;

         --  if the temperature stabilizes but no longer decreases after some times
         --  (Counter_Stabilization_Temperature) then we alert with one beep
      elsif Temperature = Last_Minimum_Temperature then
         Last_Minimum_Temperature := Temperature;

         Counter_Elevation_Temperature := Number_Of_Measures_Before_Alert;
         Counter_Stabilization_Temperature := (if @ > 0 then @ -1 else 0);

         if Counter_Stabilization_Temperature = 0 then
            Alarm_Buzzer.Beep;
         end if;

      else --  Temperature > Last_Minimum_Temperature
         --  if temperature increases we alert with two beeps
         --  until it reachs minimum temperature before Number_Of_Measures_before_alert measures
         --  or otherwise we send warning
         Counter_Elevation_Temperature := @ -1;
         Counter_Stabilization_Temperature := (if @ > 0 then @ -1 else 0);

         Alarm_Buzzer.Beep (Number_Of_Beeps => 2);

      end if;

      UART_Sending.UART_Send_Counter (Counter_Elevation_Temperature,
                                      Port   => UART_0,
                                      Status => Status);

      UART_Sending.UART_Send_Counter (Counter_Stabilization_Temperature,
                                      Port   => UART_0,
                                      Status => Status);

      exit when Counter_Elevation_Temperature = 0;

   end loop;

   --  the temperature has not returned to the minimum temperature after Number_Of_Measures_before_alert measures
   --  so we trigger warning buzzer
   loop
      Alarm_Buzzer.Beep;
      RP.Device.Timer.Delay_Milliseconds (200);
   end loop;

end Temp_Warning;
