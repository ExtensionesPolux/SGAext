page 50105 "Series Internos"
{
    Caption = 'Series Internos';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Serial No. Information";
    CardPageId = "Series Internos Ficha";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Lot No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
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


            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}