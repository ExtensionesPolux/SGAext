pageextension 50105 SerialNoInformationCard extends "Serial No. Information Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("Fecha Recepcion"; Rec."Fecha Recepcion")
            {
                ApplicationArea = All;
            }
            field("Albaran Proveedor"; Rec."Albaran Proveedor")
            {
                ApplicationArea = All;
            }
            field("Lote Proveedor"; Rec."Lote Proveedor")
            {
                ApplicationArea = All;
            }
            field("En Alerta"; Rec."En Alerta")
            {
                ApplicationArea = All;
            }
            field(Alerta; Rec.Alerta)
            {
                ApplicationArea = All;
            }
            field(Foto; Rec.Foto)
            {
                ApplicationArea = All;
            }



        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}