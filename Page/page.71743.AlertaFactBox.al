page 71743 "AlertaFactBox"
{
    Caption = 'Alertas';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Warehouse Receipt Line";

    layout
    {
        area(Content)
        {
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
}