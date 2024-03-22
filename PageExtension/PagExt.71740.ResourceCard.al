
pageextension 71740 "Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Personal Data")
        {
            group(App)
            {

                Caption = 'Aplicación SGA';

                field(Pin; rec.Pin)
                {
                    ToolTip = 'Pin', comment = 'ESP="Pin"';
                    ApplicationArea = all;
                }
                field("Permite Copiar"; Rec."Permite Copiar")
                {
                    ToolTip = 'Copy Allows', comment = 'ESP="Permite copiar"';
                    ApplicationArea = all;
                }
                field("Permite Regularizar"; Rec."Permite Regularizar")
                {
                    ToolTip = 'Regularize allows', comment = 'ESP="Permite regularizar"';
                    ApplicationArea = all;
                }
                field("Ver cantidad inventario"; Rec."Ver cantidad inventario")
                {
                    ToolTip = 'View inventory quantity', comment = 'ESP="Ver cantidad inventario"';
                    ApplicationArea = all;
                }
            }
        }
    }

}