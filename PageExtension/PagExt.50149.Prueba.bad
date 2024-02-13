pageextension 50149 Prueba extends "Warehouse Receipt"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Post and &Print")
        {
            action(RegistroPolux)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    cuWSApliaction: Codeunit WsApplication;
                    RecWhseReceiptLine: Record "Warehouse Receipt Line";
                    cuWhsePostReceipt: Codeunit "Whse.-Post Receipt";
                begin
                    RecWhseReceiptLine.RESET;
                    RecWhseReceiptLine.SETRANGE("No.", Rec."No.");

                    IF RecWhseReceiptLine.FindSet() THEN BEGIN

                        cuWhsePostReceipt.RUN(RecWhseReceiptLine);

                    END ELSE
                        Error('');

                end;
            }
        }
    }

    var
        myInt: Integer;
}