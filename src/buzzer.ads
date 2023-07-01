with RP.GPIO; use RP.GPIO;
with Pico;

package Buzzer is

   procedure Beep (Ms : Integer := 100; Number_Of_Beeps : Positive := 1);


private
   Buzzer : GPIO_Point renames Pico.GP2;

end Buzzer;
