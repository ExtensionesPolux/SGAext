page 71742 "Lotes Internos Ficha"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Lot No. Information";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Lot No."; Rec."Lot No.")
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
            }
        }
        area(FactBoxes)
        {
            part(AlertaFactBox; AlertaFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Lot No." = FIELD("Lot No.");

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}