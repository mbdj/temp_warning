with RP.Device;

package body package_Read_Temperature is

   ----------------------
   -- Read_Temperature --
   ----------------------

   function Read_Temperature return RP.ADC.Celsius is
      use RP.ADC;
      T                  : RP.ADC.Celsius := 0;
      Number_Of_Measures : constant Positive := 10;
   begin
      --  some measures are done and the average is returned
      for I in 1 .. Number_Of_Measures loop
         T := T + RP.ADC.Temperature;
         RP.Device.Timer.Delay_Milliseconds (200);
      end loop;

      return RP.ADC.Celsius (Integer (T) / Number_Of_Measures);

   end Read_Temperature;

end package_Read_Temperature;
