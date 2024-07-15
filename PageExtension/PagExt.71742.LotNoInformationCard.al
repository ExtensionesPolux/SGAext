pageextension 71742 "Lot No Information Card" extends "Lot No. Information Card"
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
            field(Proveedor; Rec.Proveedor)
            {
                ApplicationArea = All;
            }
            field("Fecha Caducidad"; Rec."Fecha Caducidad")
            {
                ApplicationArea = All;
            }


        }

    }

}