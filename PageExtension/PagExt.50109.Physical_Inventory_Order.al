pageextension 50109 Phys_Inv_Order_Laqtia extends "Physical Inventory Order"
{
    actions
    {
        modify(MakeNewRecording)
        {
            Visible = False;
        }
        addafter(MakeNewRecording)
        {
            action(Diario)
            {
                Caption = 'Crear Nuevo Registro Para App Móvil';
                image = Journal;
                Promoted = true;
                PromotedCategory = Process;
                Ellipsis = true;
                ApplicationArea = all;

                trigger OnAction()
                var
                    PhysInvOrderHeader: Record "Phys. Invt. Order Header";
                begin
                    PhysInvOrderHeader.Reset;
                    PhysInvOrderHeader.SetRange("No.", rec."No.");
                    REPORT.RunModal(REPORT::"Make Phys. Invt. Rec. Track", true, false, PhysInvOrderHeader);
                end;
            }
        }
    }
}