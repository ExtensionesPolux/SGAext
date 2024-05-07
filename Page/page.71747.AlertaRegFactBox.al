page 71747 "AlertaRegFactBox"
{
    Caption = 'Alertas';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Posted Whse. Receipt Line";

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