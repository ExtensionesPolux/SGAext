pageextension 50103 "Item Card" extends "Item Card"
{
    layout
    {
        addafter(Blocked)
        {
            group(App)
            {
                field("Usar Caducidad"; Rec."Usar Caducidad")
                {
                    ApplicationArea = All;
                }
                field("Lot No Serial"; Rec."Lot No Serial")
                {
                    ToolTip = 'Serial number to be used to generate the internal lot number', comment = 'ESP="Número de serie que se utilizará para generar el número de lote interno"';

                    ApplicationArea = all;
                }
            }
        }
    }

}