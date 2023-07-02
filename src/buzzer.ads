with RP.GPIO; use RP.GPIO;

package Buzzer is

   type Type_Buzzer is tagged limited private;

   procedure Configure (This : in out Type_Buzzer;
                        Pin  : in GPIO_Point);

   procedure Beep (This            : in out Type_Buzzer;
                   Ms              : Integer := 100;
                   Number_Of_Beeps : Positive := 1);


private

   type Type_Buzzer is tagged limited record
      Buzzer_Pin : GPIO_Point;
   end record;

end Buzzer;
