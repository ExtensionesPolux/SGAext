pageextension 71753 PostedWhseReceiptSubform extends "Posted Whse. Receipt Subform"
{
    layout
    {
        addafter("Bin Code")
        {

            field(Alerta; Rec.Alerta)
            {
                ToolTip = 'Alert', comment = 'ESP="Alerta"';
                ApplicationArea = all;
            }
            field(Foto; Rec.Foto)
            {
                ToolTip = 'Photo', comment = 'ESP="Foto"';
                ApplicationArea = all;
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