with RP.Device;
package body Buzzer is

   ----------
   -- Beep --
   ----------

   procedure Beep (This            : in out Type_Buzzer;
                   Ms              : Integer := 100;
                   Number_Of_Beeps : Positive := 1) is

      Beep_Counter : Natural := 0;

   begin

      loop
         --  beep
         This.Buzzer_Pin.Set;
         RP.Device.Timer.Delay_Milliseconds (Ms);
         This.Buzzer_Pin.Clear;

         Beep_Counter := Beep_Counter + 1;

         exit when Beep_Counter = Number_Of_Beeps;

         RP.Device.Timer.Delay_Milliseconds (Ms);
      end loop;

   end Beep;



   procedure Configure (This : in out Type_Buzzer;
                        Pin  : in GPIO_Point) is

   begin

      This.Buzzer_Pin := Pin;

      --  initialization
      This.Buzzer_Pin.Configure
        (Mode       => Output,
         Pull       => Pull_Down,
         Func       => SIO,
         Schmitt    => True,
         Slew_Fast  => False);

   end Configure;

end Buzzer;
