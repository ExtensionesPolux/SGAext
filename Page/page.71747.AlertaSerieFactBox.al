page 71747 "AlertaSerieFactBox"
{
    Caption = 'Alertas';
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Serial No. Information";

    layout
    {
        area(Content)
        {
            field(Foto; Rec.Foto)
            {
                ApplicationArea = All;
            }
        }
    }
}