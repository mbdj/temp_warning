with HAL.UART;
with RP.ADC;
with RP.UART;
with RP.Device;

with Ada.Characters.Latin_1;  --  for New_Line

package UART_Sending is

   type Type_Message is new String (1 .. 4);  -- 2 characters plus new line (2 chars)
   New_Line : constant String := [1 => Ada.Characters.Latin_1.LF , 2 => Ada.Characters.Latin_1.CR];

   procedure UART_Send (Message    : in Type_Message;
                        Port       : in out RP.UART.UART_Port ;
                        Status     : out HAL.UART.UART_Status);


   procedure UART_Send_Temperature (Temperature       : in RP.ADC.Celsius;
                                    Port              : in out RP.UART.UART_Port ;
                                    Status            : out HAL.UART.UART_Status);


   procedure UART_Send_Counter (N          : in Integer;
                                Port       : in out RP.UART.UART_Port ;
                                Status     : out HAL.UART.UART_Status);

end UART_Sending;
