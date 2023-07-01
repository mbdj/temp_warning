with RP.Device;
package body Buzzer is

----------
-- Beep --
----------

   procedure Beep (Ms : Integer := 100; Number_Of_Beeps : Positive := 1) is
      Beep_Counter : Natural := 0;
   begin
      loop
         --  beep
         Buzzer.Toggle;
         RP.Device.Timer.Delay_Milliseconds (Ms);
         Buzzer.Toggle;

         Beep_Counter := Beep_Counter + 1;

         exit when Beep_Counter = Number_Of_Beeps;

         RP.Device.Timer.Delay_Milliseconds (Ms);
      end loop;
   end;


begin

   --  initialization
   Buzzer.Configure
     (Mode       => Output,
      Pull       => Pull_Down,
      Func       => SIO,
      Schmitt    => True,
      Slew_Fast  => False);

end Buzzer;
