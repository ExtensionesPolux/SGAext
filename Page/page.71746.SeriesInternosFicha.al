page 71746 "Series Internos Ficha"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Serial No. Information";

    layout
    {
        area(Content)
        {
            group(GroupName)
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
        area(FactBoxes)
        {
            part(AlertaSerieFactBox; AlertaSerieFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "Serial No." = FIELD("Serial No.");

            }
        }
    }
}