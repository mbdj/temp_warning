package body UART_Sending is

   ---------------
   -- UART_Send --
   ---------------

   procedure UART_Send (Message    : in Type_Message;
                        Port       : in out RP.UART.UART_Port ;
                        Status     : out HAL.UART.UART_Status) is
      Msg      : Type_Message;
      Data     : HAL.UART.UART_Data_8b (Msg'Range)
        with Address => Msg'Address;
   begin
      Msg := Message;
      RP.UART.Transmit (This                  => Port,
                        Data                  => Data,
                        Status                => Status,
                        Timeout               => 0);
   end;



   ---------------------------
   -- UART_Send_Temperature --
   ---------------------------

   procedure UART_Send_Temperature (Temperature       : in RP.ADC.Celsius;
                                    Port              : in out RP.UART.UART_Port ;
                                    Status            : out HAL.UART.UART_Status) is

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
      UART_Send (Message      => String_Message (Temperature),
                 Port         => Port,
                 Status       => Status);
   end;



   -----------------------
   -- UART_Send_Counter --
   -----------------------

   procedure UART_Send_Counter (N          : in Integer;
                                Port       : in out RP.UART.UART_Port ;
                                Status     : out HAL.UART.UART_Status) is
      Message : Type_Message;
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

      UART_Send (Message      => Message,
                 Port         => Port,
                 Status       => Status);
   end;

end UART_Sending;
